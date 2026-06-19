import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  // ConnectionNotifier's constructor registers a WidgetsBindingObserver, which
  // requires the test binding to be initialized first.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectionNotifier Tests', () {
    late ProviderContainer container;
    late MockChatRepository mockRepository;

    setUp(() {
      mockRepository = MockChatRepository();

      // Mock the stream to return an empty stream
      when(
        () => mockRepository.watchConnectionStatus(),
      ).thenAnswer((_) => Stream.empty());
      when(() => mockRepository.isConnected()).thenAnswer((_) async => false);

      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(mockRepository),
          // The notifier reads ChatConfig (for the token function name /
          // timeouts); supply a test config so it doesn't hit the unimplemented
          // default provider.
          chatConfigProvider.overrideWithValue(
            const ChatConfig(appId: 'test_app'),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be disconnected (false)', () async {
      // Wait for initialization
      await Future.delayed(Duration.zero);
      final connectionState = container.read(connectionProvider);
      expect(connectionState, false);
    });

    test('connect should set state to true on success', () async {
      when(
        () => mockRepository.connect(
          any(),
          nickname: any(named: 'nickname'),
          accessToken: any(named: 'accessToken'),
        ),
      ).thenAnswer((_) async => {});
      when(() => mockRepository.isConnected()).thenAnswer((_) async => true);

      final notifier = container.read(connectionProvider.notifier);

      await notifier.connect('user123', nickname: 'TestUser');

      // Allow time for state to update
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(connectionProvider);
      expect(state, true);
    });

    test('disconnect should set state to false', () async {
      when(() => mockRepository.disconnect()).thenAnswer((_) async => {});
      when(() => mockRepository.isConnected()).thenAnswer((_) async => false);

      final notifier = container.read(connectionProvider.notifier);

      await notifier.disconnect();

      // Allow time for state to update
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(connectionProvider);
      expect(state, false);
    });
  });
}
