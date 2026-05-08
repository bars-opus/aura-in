// lib/core/providers/routing_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/routing/routing_notifier.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

final routingNotifierProvider = ChangeNotifierProvider<RoutingNotifier>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final appRouterProvider = Provider<GoRouter>((ref) {
  throw UnimplementedError('Must be overridden in main');
});
