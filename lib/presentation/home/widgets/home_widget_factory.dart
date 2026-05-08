// lib/core/widgets/home_widget_factory.dart
import 'package:nano_embryo/core/utils/exports/export_packages.dart';
import 'package:nano_embryo/presentation/home/widgets/home_widget.dart';
import 'package:nano_embryo/presentation/home/widgets/home_tab.dart';

class HomeWidgetFactory {
  // Standard mobile home
  static HomeWidget mobile({
    required List<HomeTab> tabs,
    int initialTabIndex = 0,
  }) {
    return HomeWidget(
      tabs: tabs,
      initialTabIndex: initialTabIndex,
      navigationBarHeight: 64.h,
      iconSize: 22.h,
      activeIconSize: 24.h,
      showLabels: true,
    );
  }

  // Tablet/desktop home (larger)
  static HomeWidget tablet({
    required List<HomeTab> tabs,
    int initialTabIndex = 0,
    Widget? floatingActionButton,
  }) {
    return HomeWidget(
      tabs: tabs,
      initialTabIndex: initialTabIndex,
      navigationBarHeight: 72.h,
      iconSize: 26.h,
      activeIconSize: 28.h,
      showLabels: true,
    );
  }

  // Minimal (icons only)
  static HomeWidget minimal({
    required List<HomeTab> tabs,
    int initialTabIndex = 0,
    Widget? floatingActionButton,
  }) {
    return HomeWidget(
      tabs: tabs,
      initialTabIndex: initialTabIndex,
      navigationBarHeight: 30.h,
      iconSize: 24.h,
      activeIconSize: 26.h,
      showLabels: false,
    );
  }
}
