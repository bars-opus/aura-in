// Generic widget that works with any type
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

class SimpleProviderTabs<T> extends StatelessWidget {
  final List<SimpleProviderTabItem<T>> tabs;
  final T selectedValue;
  final void Function(T) onValueSelected;
  final double height;
  final double iconSize;
  final double fontSize;

  const SimpleProviderTabs({
    super.key,
    required this.tabs,
    required this.selectedValue,
    required this.onValueSelected,
    this.height = 80,
    this.iconSize = 30,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: height.h,
      padding: EdgeInsets.only(top: Spacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            tabs.map((tab) {
              final isSelected = tab.value == selectedValue;

              return GestureDetector(
                onTap: () => onValueSelected(tab.value),
                child: Container(
                  width: MediaQuery.of(context).size.width / tabs.length,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          isSelected ? tab.selectedIcon : tab.icon,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withOpacity(0.6),
                          size: iconSize,
                        ),
                      ),
                      Gap(Spacing.xs.h),
                      Text(
                        tab.label,
                        style: textTheme.labelMedium?.copyWith(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withOpacity(0.6),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: fontSize,
                        ),
                      ),
                      Gap(Spacing.sm),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        height: 2.h,
                        width: isSelected ? 40.w : 0,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class SimpleProviderTabItem<T> {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final T value;

  const SimpleProviderTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.value,
  });
}
