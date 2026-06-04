// test/dashboard/presentation/controllers/business_hours_edit_controller_test.dart
//
// BusinessHoursEditController contract tests. The controller is the
// load-bearing piece that ensures the Tools-tab editor does NOT touch
// any creation-flow state.
//
// We mock both repositories with mocktail. The ShopDetailsDTO surface
// is wide enough that constructing fixtures inline drifts on every
// model change; we Mock the DTO too and stub only the `openingHours`
// getter the controller actually reads.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/opening_hours_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/repositories/shop_repository.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockShopDetailsDTO extends Mock implements ShopDetailsDTO {}

void main() {
  setUpAll(() {
    registerFallbackValue(<OpeningHoursDraft>[]);
  });

  late _MockDashboardRepository dashboardRepo;
  late _MockShopRepository shopRepo;

  setUp(() {
    dashboardRepo = _MockDashboardRepository();
    shopRepo = _MockShopRepository();
  });

  /// Wait for any pending microtasks (the controller's async load).
  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  /// Stub the shop repo to return a DTO whose openingHours getter
  /// yields the given list. Other DTO fields aren't read by the
  /// controller — Mock returns null for them, which is fine.
  void stubShopWithHours(List<OpeningHoursDTO> hours) {
    final dto = _MockShopDetailsDTO();
    when(() => dto.openingHours).thenReturn(hours);
    when(() => shopRepo.getShopDetailsById('shop-a'))
        .thenAnswer((_) async => dto);
  }

  test('load hydrates state to AsyncValue.data with 7 rows', () async {
    stubShopWithHours(const [
      OpeningHoursDTO(
        id: 'h-1',
        dayOfWeek: 1,
        opensAt: '09:00 AM',
        closesAt: '05:00 PM',
        isClosed: false,
      ),
    ]);

    final controller = BusinessHoursEditController(
      shopId: 'shop-a',
      dashboardRepo: dashboardRepo,
      shopRepo: shopRepo,
    );
    await settle();
    addTearDown(controller.dispose);

    expect(controller.state.hasValue, isTrue);
    expect(controller.state.value!.length, 7);
    expect(controller.state.value!.first.dayOfWeek, 1);
  });

  test('updateDay mutates only the targeted day', () async {
    stubShopWithHours(const []);
    final controller = BusinessHoursEditController(
      shopId: 'shop-a',
      dashboardRepo: dashboardRepo,
      shopRepo: shopRepo,
    );
    await settle();
    addTearDown(controller.dispose);

    controller.updateDay(3, closesAt: '08:00 PM');
    final updated = controller.state.value!;
    expect(updated.firstWhere((r) => r.dayOfWeek == 3).closesAt, '08:00 PM');
    expect(updated.firstWhere((r) => r.dayOfWeek == 1).closesAt, '05:00 PM');
  });

  test('save() with valid ranges calls the repo exactly once', () async {
    stubShopWithHours(const []);
    when(() => dashboardRepo.rebuildShopOpeningHours(
          shopId: any(named: 'shopId'),
          hours: any(named: 'hours'),
        )).thenAnswer((_) async {});

    final controller = BusinessHoursEditController(
      shopId: 'shop-a',
      dashboardRepo: dashboardRepo,
      shopRepo: shopRepo,
    );
    await settle();
    addTearDown(controller.dispose);

    await controller.save();
    verify(() => dashboardRepo.rebuildShopOpeningHours(
          shopId: 'shop-a',
          hours: any(named: 'hours'),
        )).called(1);
  });

  test('save() with closes <= opens on a non-closed day throws before repo',
      () async {
    stubShopWithHours(const []);
    final controller = BusinessHoursEditController(
      shopId: 'shop-a',
      dashboardRepo: dashboardRepo,
      shopRepo: shopRepo,
    );
    await settle();
    addTearDown(controller.dispose);

    controller.updateDay(3, opensAt: '09:00 PM', closesAt: '08:00 AM');
    await expectLater(
      controller.save(),
      throwsA(isA<InvalidHoursPayloadException>()),
    );
    verifyNever(() => dashboardRepo.rebuildShopOpeningHours(
          shopId: any(named: 'shopId'),
          hours: any(named: 'hours'),
        ));
  });

  test('discard() re-fetches from server', () async {
    stubShopWithHours(const []);
    final controller = BusinessHoursEditController(
      shopId: 'shop-a',
      dashboardRepo: dashboardRepo,
      shopRepo: shopRepo,
    );
    await settle();
    addTearDown(controller.dispose);

    await controller.discard();
    await settle();
    verify(() => shopRepo.getShopDetailsById('shop-a')).called(2);
  });

  test('repo throw surfaces as AsyncValue.error with typed exception',
      () async {
    when(() => shopRepo.getShopDetailsById('shop-a'))
        .thenThrow(HoursNotFoundException('shop-a'));
    final controller = BusinessHoursEditController(
      shopId: 'shop-a',
      dashboardRepo: dashboardRepo,
      shopRepo: shopRepo,
    );
    await settle();
    addTearDown(controller.dispose);

    // Use when() to extract the error without depending on a specific
    // Riverpod internal type name.
    final captured = controller.state.when<Object?>(
      data: (_) => null,
      loading: () => null,
      error: (e, _) => e,
    );
    expect(captured, isA<HoursNotFoundException>());
  });
}
