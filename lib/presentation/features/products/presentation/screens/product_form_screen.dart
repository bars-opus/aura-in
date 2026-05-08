// lib/features/products/presentation/screens/product_form_screen.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/image_cropper_stub.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';

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

  String? _selectedCategory;
  bool _isActive = true;

  // Image handling
  final List<String> _existingImageUrls = [];
  final List<File> _newImageFiles = [];
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == FormMode.edit && widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _selectedCategory = widget.product!.category;
      _isActive = widget.product!.isActive;
      _existingImageUrls.addAll(widget.product!.images);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Pick image using your existing image picker service
  Future<void> _pickImage() async {
    final imagePickerService = ref.read(imagePickerServiceProvider);

    // Show source dialog (camera/gallery)
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => _buildImageSourceDialog(),
    );

    if (source == null) return;

    final pickedFile = await imagePickerService.pickImage(
      fromCamera: source == ImageSource.camera,
      crop: true,
      cropRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (pickedFile != null) {
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

  // Upload all new images and return URLs
  Future<List<String>> _uploadNewImages() async {
    if (_newImageFiles.isEmpty) return [];

    setState(() => _isUploadingImages = true);

    final repository = ref.read(productRepositoryProvider);
    final List<String> uploadedUrls = [];

    try {
      for (final imageFile in _newImageFiles) {
        // For new products, we'll use a temporary ID or create product first
        // Option 1: Create product first without images, then update
        // Option 2: Use shopId only and associate later
        // We'll do Option 2: Use shopId and a placeholder, then update after product creation

        // For now, if we have a product ID (edit mode), use it
        // For create mode, we'll handle differently in _saveProduct
        final productId =
            widget.mode == FormMode.edit && widget.product != null
                ? widget.product!.id
                : 'temp'; // Temporary - will be updated after product creation

        final url = await repository.uploadProductImage(
          shopId: widget.shopId,
          productId: productId,
          imageFile: imageFile,
        );
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null) return;

    final notifier = ref.read(productFormNotifierProvider.notifier);

    // Combine existing image URLs with newly uploaded ones
    final allImageUrls = [..._existingImageUrls];

    if (widget.mode == FormMode.create) {
      // For create mode: Upload images first, then create product with URLs
      if (_newImageFiles.isNotEmpty) {
        setState(() => _isUploadingImages = true);
        try {
          final repository = ref.read(productRepositoryProvider);
          for (final imageFile in _newImageFiles) {
            // Use shopId only for now, productId will be assigned
            final url = await repository.uploadProductImage(
              shopId: widget.shopId,
              productId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
              imageFile: imageFile,
            );
            allImageUrls.add(url);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload images: $e')),
            );
          }
          setState(() => _isUploadingImages = false);
          return;
        }
        setState(() => _isUploadingImages = false);
      }

      await notifier.createProduct(
        shopId: widget.shopId,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        price: price,
        images: allImageUrls,
        category: _selectedCategory!,
      );
    } else {
      // For edit mode: Upload new images first
      if (_newImageFiles.isNotEmpty) {
        final newUrls = await _uploadNewImages();
        allImageUrls.addAll(newUrls);
      }

      await notifier.updateProduct(
        productId: widget.product!.id,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        price: price,
        images: allImageUrls,
        category: _selectedCategory,
        isActive: _isActive,
      );
    }

    if (mounted && notifier.state.success) {
      Navigator.pop(context, true);
    } else if (mounted && notifier.state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(notifier.state.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormNotifierProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == FormMode.create ? 'Add Product' : 'Edit Product',
        ),
        actions:
            widget.mode == FormMode.edit
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed:
                        state.isLoading
                            ? null
                            : () => _showDeleteConfirmation(context),
                  ),
                ]
                : null,
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
                      Text(
                        'Product Images',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Image Grid
                      _buildImageGrid(),

                      // Add Image Button
                      if (_existingImageUrls.length + _newImageFiles.length < 5)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text('Add Image'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: 24.h),

                      // Product Name
                      AppTextFormField(
                        controller: _nameController,
                        label: 'Product Name',
                        hintText: 'e.g., Premium Hair Pomade',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          if (value.length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Description
                      AppTextFormField(
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Describe your product...',
                        maxLines: 4,
                      ),
                      SizedBox(height: 16.h),

                      // Price
                      AppTextFormField(
                        controller: _priceController,
                        label: 'Price (₦)',
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
                      SizedBox(height: 16.h),

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
                                child: Text(category.displayName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a category';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Active Status (Edit mode only)
                      if (widget.mode == FormMode.edit)
                        SwitchListTile(
                          title: Text('Product Active'),
                          subtitle: Text(
                            'Inactive products won\'t appear in marketplace',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
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

                      SizedBox(height: 24.h),

                      // Save Button
                      AppButton(
                        label:
                            widget.mode == FormMode.create
                                ? 'Create Product'
                                : 'Save Changes',
                        onPressed: _saveProduct,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImageUrls.length + _newImageFiles.length;

    if (totalImages == 0) {
      return Container(
        height: 120.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 48.w,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 8.h),
              Text(
                'No images added',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
              Text(
                'Tap "Add Image" to upload',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      );
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
                    color: Colors.black.withOpacity(0.6),
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

  Widget _buildImageSourceDialog() {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
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
                  final notifier = ref.read(
                    productFormNotifierProvider.notifier,
                  );
                  await notifier.deleteProduct(widget.product!.id);
                  if (mounted && notifier.state.success) {
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
