// lib/core/widgets/search_form_field.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Universal search field with FormField benefits (validation, form integration)
///

class SearchFormField extends FormField<String> {
  SearchFormField({
    super.key,
    TextEditingController? controller,
    String hintText = 'Search...',
    bool autofocus = false,
    bool showClearButton = true,
    bool showSearchIcon = true,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: Spacing.md,
      vertical: Spacing.xs,
    ),
    double borderRadius = BorderRadiusTokens.full,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    Color? hintColor,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    VoidCallback? onCancelPressed,
    VoidCallback? onClearPressed,
    FocusNode? focusNode,
    List<String>? autofillHints,
    TextInputAction textInputAction = TextInputAction.search,
    int? maxLines = 1,
    int? minLines = 1,

    // FORM FIELD SPECIFIC PARAMETERS
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    String? initialValue,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    InputDecoration? decoration,
  }) : super(
         initialValue: controller?.text ?? initialValue ?? '',
         onSaved: onSaved,
         validator: validator,
         enabled: enabled,
         autovalidateMode: autovalidateMode,
         builder: (FormFieldState<String> field) {
           final effectiveController =
               controller ?? TextEditingController(text: field.value);

           // Connect controller to form field
           if (controller == null) {
             effectiveController.addListener(() {
               field.didChange(effectiveController.text);
             });
           }

           // Determine error state
           final hasError = field.hasError;
           final errorText = field.errorText;

           return _SearchFormFieldContent(
             controller: effectiveController,
             hintText: hintText,
             autofocus: autofocus,
             showClearButton: showClearButton,
             showSearchIcon: showSearchIcon,
             isLoading: isLoading,
             padding: padding,
             borderRadius: borderRadius,
             backgroundColor: backgroundColor,
             iconColor: iconColor,
             textColor: textColor,
             hintColor: hintColor,
             textStyle: textStyle,
             hintStyle: hintStyle,
             onChanged: (value) {
               field.didChange(value);
               onChanged?.call(value);
             },
             onSubmitted: onFieldSubmitted,
             onCancelPressed: onCancelPressed,
             onClearPressed: () {
               effectiveController.clear();
               field.didChange('');
               onClearPressed?.call();
             },
             focusNode: focusNode,
             autofillHints: autofillHints,
             textInputAction: textInputAction,
             maxLines: maxLines,
             minLines: minLines,
             hasError: hasError,
             errorText: errorText,
             decoration: decoration,
           );
         },
       );
}

// Content widget (reusable)
class _SearchFormFieldContent extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final bool showClearButton;
  final bool showSearchIcon;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? hintColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onClearPressed;
  final FocusNode? focusNode;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final bool hasError;
  final String? errorText;
  final InputDecoration? decoration;

  const _SearchFormFieldContent({
    required this.controller,
    required this.hintText,
    required this.autofocus,
    required this.showClearButton,
    required this.showSearchIcon,
    required this.isLoading,
    required this.padding,
    required this.borderRadius,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.hintColor,
    this.textStyle,
    this.hintStyle,
    this.onChanged,
    this.onSubmitted,
    this.onCancelPressed,
    this.onClearPressed,
    this.focusNode,
    this.autofillHints,
    this.textInputAction,
    this.maxLines,
    this.minLines,
    this.hasError = false,
    this.errorText,
    this.decoration,
  });

  @override
  State<_SearchFormFieldContent> createState() =>
      __SearchFormFieldContentState();
}

class __SearchFormFieldContentState extends State<_SearchFormFieldContent> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onClearPressed?.call();
    _focusNode.requestFocus();
  }

  void _cancelSearch() {
    widget.controller.clear();
    widget.onCancelPressed?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build error-aware styling
    final errorColor = colorScheme.error;
    final effectiveBackgroundColor =
        widget.hasError
            ? errorColor.withOpacity(0.1)
            : widget.backgroundColor ?? colorScheme.surfaceVariant;

    final effectiveIconColor =
        widget.hasError
            ? errorColor
            : widget.iconColor ?? colorScheme.onSurface.withOpacity(0.5);

    final effectiveHintColor =
        widget.hasError
            ? errorColor.withOpacity(0.7)
            : widget.hintColor ?? colorScheme.onSurface.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                  border: Border.all(
                    color: widget.hasError ? errorColor : Colors.grey,
                    width: .3,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.sm.h,
                ),
                child: Row(
                  children: [
                    // Search Icon
                    if (widget.showSearchIcon) ...[
                      widget.isLoading
                          ? CircularLoadingIndicator(
                           
                          )
                          : Icon(
                            Icons.search,
                            size: 20.h,
                            color: effectiveIconColor,
                          ),
                      SizedBox(width: Spacing.sm.w),
                    ],

                    // TextFormField
                    Expanded(
                      child: TextFormField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus,
                        maxLines: widget.maxLines,
                        minLines: widget.minLines,
                        textInputAction: widget.textInputAction,
                        autofillHints: widget.autofillHints,
                        decoration: (widget.decoration ??
                                InputDecoration(
                                  hintText: widget.hintText,
                                  hintStyle:
                                      widget.hintStyle ??
                                      theme.textTheme.bodyMedium?.copyWith(
                                        color: effectiveHintColor,
                                      ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                ))
                            .copyWith(
                              errorText: null, // Handle error outside
                            ),
                        style:
                            widget.textStyle ??
                            theme.textTheme.bodyMedium?.copyWith(
                              color: widget.textColor ?? colorScheme.onSurface,
                            ),
                        onChanged: widget.onChanged,
                        onFieldSubmitted: widget.onSubmitted,
                      ),
                    ),

                    // Clear Button
                    if (widget.showClearButton &&
                        widget.controller.text.isNotEmpty &&
                        !widget.isLoading) ...[
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Icon(
                          Icons.clear,
                          size: 20.h,
                          color: effectiveIconColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Cancel Button
            if (widget.onCancelPressed != null) ...[
              SizedBox(width: Spacing.xs.w),
              TextButton(
                onPressed: _cancelSearch,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancel',
                  style:
                      widget.textStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        color: widget.textColor ?? colorScheme.primary,
                      ),
                ),
              ),
            ],
          ],
        ),

        // Error message
        if (widget.hasError && widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(left: Spacing.md.w, top: Spacing.xs.h),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: errorColor),
            ),
          ),
      ],
    );
  }
}

// ========== ENHANCED FILTERABLE VERSION ==========

// lib/core/widgets/filterable_search_form_field.dart

class FilterableSearchFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final List<String> filterChips;
  final List<String> selectedFilters;
  final ValueChanged<List<String>> onFiltersChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  // Add this parameter for custom icons
  final Map<String, IconData>? filterIcons;

  // Form field properties
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final String? initialValue;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final VoidCallback? onCancelPressed;
  final bool autofocus;
  final FocusNode? focusNode;

  const FilterableSearchFormField({
    super.key,
    this.controller,
    this.hintText = 'Search and filter...',
    required this.filterChips,
    required this.selectedFilters,
    required this.onFiltersChanged,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSaved,
    this.validator,
    this.initialValue,
    this.onCancelPressed,
    this.enabled = true,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.filterIcons, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Form Field
        SearchFormField(
          controller: controller,
          onCancelPressed: onCancelPressed,
          hintText: hintText,
          onChanged: onSearchChanged,
          onFieldSubmitted: onSearchSubmitted,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          autofocus: autofocus,
          focusNode: focusNode,
        ),

        // Filter Chips
        if (filterChips.isNotEmpty) ...[
          SizedBox(height: Spacing.sm.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  filterChips.map((filter) {
                    final isSelected = selectedFilters.contains(filter);
                    final icon = filterIcons?[filter];

                    return Padding(
                      padding: EdgeInsets.only(right: Spacing.xs.w),
                      child: AppFilterChip(
                        avatarIcon: icon,
                        label: filter,
                        borderWidth: 0.3,
                        selected: isSelected,
                        onSelected: (selected) {
                          final newFilters = List<String>.from(selectedFilters);
                          if (selected) {
                            newFilters.add(filter);
                          } else {
                            newFilters.remove(filter);
                          }
                          onFiltersChanged(newFilters);
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
