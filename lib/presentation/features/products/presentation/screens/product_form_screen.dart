// lib/features/products/presentation/screens/product_form_screen.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/constants/shop_types.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/image_cropper_platform.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/input_sanitizer.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/no_image_added.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/image_source_dialog.dart';
import 'package:nano_embryo/core/repositories/models/media_upload.dart';

import '../../../../../core/providers/media_ service_providers.dart';

enum FormMode { create, edit }

class ProductFormScreen extends ConsumerStatefulWidget {
  final String shopId;
  final FormMode mode;
  final ProductModel? product;

  const ProductFormScreen({
    super.key,
    required this.shopId,
    required this.mode,
    this.product,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');

  String? _selectedCategory;
  bool _isActive = true;
  List<String> _selectedShopTypes = [];
  String? _shopCurrencySymbol;

  // Image handling
  final List<String> _existingImageUrls = [];
  final List<File> _newImageFiles = [];
  bool _isUploadingImages = false;
  // Local guard against double-submit. The notifier's isLoading flips only
  // after the first await; this covers the tap-twice race before then.
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == FormMode.edit && widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _selectedCategory = widget.product!.category;
      _isActive = widget.product!.isActive;
      _existingImageUrls.addAll(widget.product!.images);
      _selectedShopTypes = List.of(widget.product!.shopTypes);
    }
    _loadShopCurrency();
  }

  Future<void> _loadShopCurrency() async {
    final row = await ref
        .read(supabaseClientProvider)
        .from('shops')
        .select('currency_symbol')
        .eq('id', widget.shopId)
        .maybeSingle();
    if (mounted) setState(() => _shopCurrencySymbol = row?['currency_symbol'] as String?);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 300.h,
      widget: ImageSourceDialog(
        currentCount: _existingImageUrls.length + _newImageFiles.length,
        onCameraSelected: () {
          Navigator.pop(context);
          _addImage(fromCamera: true);
        },
        onGallerySelected: () {
          Navigator.pop(context);
          _addImage(fromCamera: false);
        },
      ),
    );
  }

  // Pick an image into local state. Upload happens on save via
  // MediaUploadService (see _uploadImageFile). We pick the File here rather
  // than pickAndUpload so images aren't uploaded until the product is saved.
  Future<void> _addImage({required bool fromCamera}) async {
    final pickedFile = await ref
        .read(imagePickerServiceProvider)
        .pickImage(
          fromCamera: fromCamera,
          crop: true,
          cropRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        );

    if (pickedFile != null && mounted) {
      setState(() {
        _newImageFiles.add(pickedFile);
      });
    }
  }

  // Remove image (either existing URL or new file)
  void _removeImage(int index, {bool isExisting = false}) {
    setState(() {
      if (isExisting) {
        _existingImageUrls.removeAt(index);
      } else {
        _newImageFiles.removeAt(index);
      }
    });
  }

  /// Uploads one image via the shared MediaUploadService to the same
  /// `product-images` bucket/path the app already uses. Returns the public URL,
  /// or null on failure (the service catches its own errors).
  Future<String?> _uploadImageFile(File imageFile, String productId) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final result = await ref
        .read(mediaUploadServiceProvider)
        .uploadFile(
          request: MediaUploadRequest(
            file: imageFile,
            mediaType: MediaType.image,
            bucket: 'product-images',
            customPath: 'products/${widget.shopId}/$productId/$fileName',
          ),
          userId: widget.shopId,
        );
    return result?.publicUrl;
  }

  // Upload all new images and return URLs. Throws on any failed upload so the
  // caller can abort the save instead of persisting a product with missing images.
  Future<List<String>> _uploadNewImages(String productId) async {
    if (_newImageFiles.isEmpty) return [];

    setState(() => _isUploadingImages = true);
    final List<String> uploadedUrls = [];
    try {
      for (final imageFile in _newImageFiles) {
        final url = await _uploadImageFile(imageFile, productId);
        if (url == null) {
          throw ProductImageUploadException('Failed to upload image.');
        }
        uploadedUrls.add(url);
      }
      return uploadedUrls;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImages = false);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_selectedShopTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category type')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null) return;

    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    setState(() => _isSaving = true);
    final notifier = ref.read(productFormNotifierProvider.notifier);

    final allImageUrls = [..._existingImageUrls];

    try {
      if (widget.mode == FormMode.create) {
        if (_newImageFiles.isNotEmpty) {
          try {
            final newUrls = await _uploadNewImages(
              'temp_${DateTime.now().millisecondsSinceEpoch}',
            );
            allImageUrls.addAll(newUrls);
          } on ProductImageUploadException catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.message)));
            }
            return;
          }
        }

        final cleanedDescription = InputSanitizer.clean(
          _descriptionController.text,
        );
        await notifier.createProduct(
          shopId: widget.shopId,
          name: InputSanitizer.clean(_nameController.text),
          description: cleanedDescription.isEmpty ? null : cleanedDescription,
          price: price,
          images: allImageUrls,
          category: _selectedCategory!,
          shopTypes: _selectedShopTypes,
          stockQuantity: stock,
        );
      } else {
        if (_newImageFiles.isNotEmpty) {
          try {
            final newUrls = await _uploadNewImages(widget.product!.id);
            allImageUrls.addAll(newUrls);
          } on ProductImageUploadException catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.message)));
            }
            return;
          }
        }

        final cleanedDescription = InputSanitizer.clean(
          _descriptionController.text,
        );
        await notifier.updateProduct(
          productId: widget.product!.id,
          name: InputSanitizer.clean(_nameController.text),
          description: cleanedDescription.isEmpty ? null : cleanedDescription,
          price: price,
          images: allImageUrls,
          category: _selectedCategory,
          isActive: _isActive,
          shopTypes: _selectedShopTypes,
          stockQuantity: stock,
        );
      }

      if (!mounted) return;
      final result = ref.read(productFormNotifierProvider);
      if (result.success) {
        Navigator.pop(context, true);
      } else if (result.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error!)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.mode == FormMode.create ? 'Add Product' : 'Edit Product',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),

      body:
          state.isLoading || _isUploadingImages
              ? Center(child: const CircularLoadingIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images Section
                      CardInkWell(
                        child: Column(
                          children: [
                            // Image Grid
                            _buildImageGrid(), Gap(Spacing.lg.h),

                            // Add Image Button
                            if (_existingImageUrls.length +
                                    _newImageFiles.length <
                                5)
                              AppButton(
                                height: 40.h,
                                iconData: Icons.add_a_photo,
                                label: 'Add Image',
                                onPressed: _showImageSourceDialog,
                                padding: Spacing.horizontalMd,
                                variant: ButtonVariant.outline,
                                size: ButtonSize.small,
                                width: double.infinity,
                              ),
                          ],
                        ),
                      ),

                      // Product Name
                      CardInkWell(
                        child: Column(
                          children: [
                            AppTextFormField(
                              controller: _nameController,
                              label: 'Product Name',
                              hintText: 'e.g., Premium Hair Pomade',
                              maxLength: InputSanitizer.maxName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter product name';
                                }
                                if (value.trim().length < 3) {
                                  return 'Name must be at least 3 characters';
                                }
                                if (value.length > InputSanitizer.maxName) {
                                  return 'Name cannot exceed ${InputSanitizer.maxName} characters';
                                }
                                return null;
                              },
                            ),
                            // Description
                            AppTextFormField(
                              controller: _descriptionController,
                              label: 'Description',
                              hintText: 'Describe your product...',
                              maxLines: 4,
                              maxLength: InputSanitizer.maxDescription,
                              validator: InputSanitizer.optionalLength(
                                InputSanitizer.maxDescription,
                                fieldName: 'Description',
                              ),
                            ),

                            // Shop-type chips
                            Gap(Spacing.sm.h),
                            Text(
                              'Shop Type',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            Gap(Spacing.xs.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: ShopTypes.all.map((type) {
                                final selected = _selectedShopTypes.contains(type);
                                return AppFilterChip(
                                  label: type,
                                  selected: selected,
                                  onSelected: (sel) => setState(() {
                                    if (sel) {
                                      _selectedShopTypes.add(type);
                                    } else {
                                      _selectedShopTypes.remove(type);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                            Gap(Spacing.sm.h),

                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              items:
                                  ProductCategory.values.map((category) {
                                    return DropdownMenuItem(
                                      value: category.name,
                                      child: Text(
                                        category.displayName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.8),
                                            ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      // Price
                      CardInkWell(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: AppTextFormField(
                                controller: _priceController,
                                label: 'Price (${_shopCurrencySymbol ?? Currency.symbol})',
                                hintText: '0.00',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter price';
                                  }
                                  final price = double.tryParse(value);
                                  if (price == null || price <= 0) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Gap(Spacing.sm.w),
                            // Stock Quantity — REQUIRED for checkout to succeed.
                            // The DB sets stock_quantity NOT NULL DEFAULT 0, so a
                            // product saved with 0 here will reject every order
                            // attempt with "insufficient stock".
                            Expanded(
                              flex: 1,
                              child: AppTextFormField(
                                controller: _stockController,
                                label: 'Stock quantity',
                                hintText: '0',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter stock quantity';
                                  }
                                  final n = int.tryParse(value.trim());
                                  if (n == null || n < 0) {
                                    return 'Stock must be 0 or more';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Active Status (Edit mode only)
                      if (widget.mode == FormMode.edit)
                        SwitchListTile(
                          title: Text('Product Active'),
                          subtitle: Text(
                            'Inactive products won\'t appear in marketplace',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),

                      // Save Button
                      Gap(Spacing.xl),
                      AppButton(
                        elevation: 0,
                        label:
                            _isSaving
                                ? 'Saving...'
                                : (widget.mode == FormMode.create
                                    ? 'Create Product'
                                    : 'Save Changes'),
                        onPressed: _isSaving ? null : _saveProduct,

                        size: ButtonSize.small,
                        width: double.infinity,
                        padding: Spacing.horizontalMd,
                        height: 40.h,
                      ),
                      Gap(Spacing.xl),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImageUrls.length + _newImageFiles.length;

    if (totalImages == 0) {
      return NoImageAdded();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: totalImages,
      itemBuilder: (context, index) {
        final isExisting = index < _existingImageUrls.length;
        final imageIndex =
            isExisting ? index : index - _existingImageUrls.length;

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child:
                  isExisting
                      ? Image.network(
                        _existingImageUrls[imageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      )
                      : Image.file(
                        _newImageFiles[imageIndex],
                        fit: BoxFit.cover,
                      ),
            ),
            Positioned(
              top: 4.w,
              right: 4.w,
              child: GestureDetector(
                onTap: () => _removeImage(imageIndex, isExisting: isExisting),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20.w, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text(
              'Are you sure you want to delete this product? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref
                      .read(productFormNotifierProvider.notifier)
                      .deleteProduct(widget.product!.id);
                  if (!mounted) return;
                  if (ref.read(productFormNotifierProvider).success) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
