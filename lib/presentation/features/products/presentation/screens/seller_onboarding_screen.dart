// lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart
//
// First-time product seller onboarding. Phone verification has already passed
// (gate runs before navigation). If the user already owns a shop, we route
// straight to its product form. Otherwise we collect a shop overview + a
// business document, create a minimal seller-shop, and open the product form.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/upload_document_image.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

class SellerOnboardingScreen extends ConsumerStatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  ConsumerState<SellerOnboardingScreen> createState() =>
      _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState
    extends ConsumerState<SellerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _overviewController = TextEditingController();
  final List<DocumentDraft> _documents = [];
  bool _checkingExisting = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkExistingShop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingShop() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      setState(() => _checkingExisting = false);
      return;
    }
    try {
      final shops =
          await ref.read(shopRepositoryProvider).getShopsByProfileId(userId);
      if (!mounted) return;
      if (shops.isNotEmpty) {
        // Already a shop owner — go straight to the product form.
        _openProductForm(shops.first.id);
        return;
      }
    } catch (_) {
      // Fall through to onboarding form on lookup failure.
    }
    if (mounted) setState(() => _checkingExisting = false);
  }

  void _openProductForm(String shopId) {
    context.pushReplacement(
      '/productForm',
      extra: {'shopId': shopId, 'mode': FormMode.create},
    );
  }

  void _pickDocument() {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: DocumentPickerSheet(
        onDocumentPicked: (doc) => setState(() => _documents.add(doc)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_documents.isEmpty) {
      setState(() => _error = 'Please upload at least one business document.');
      return;
    }
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      // 1. Upload documents (reuse the shop document uploader).
      final uploader = ref.read(uploadDocumentImageProvider);
      final documentUrls = <String>[];
      for (final doc in _documents) {
        final url = await uploader.execute(
          document: doc,
          profileId: userId,
          shopId: 'temp',
        );
        if (url != null) documentUrls.add(url);
      }

      // 2. Create a minimal seller-shop.
      final draft = ShopDraft(
        profileId: userId,
        shopName: _nameController.text.trim(),
        overview: _overviewController.text.trim(),
        shopType: 'product_seller',
      );
      final shopId = await ref.read(shopCreationRepositoryProvider).createShop(
            profileId: userId,
            draft: draft,
            imageUrls: const [],
            documentUrls: documentUrls,
            logoUrl: null,
          );

      if (!mounted) return;
      _openProductForm(shopId);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not start selling. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_checkingExisting) {
      return const Scaffold(body: Center(child: CircularLoadingIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Sell a product',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            AppTextFormField(
              controller: _nameController,
              label: 'Shop name',
              hintText: 'e.g., Kwame Beauty Supplies',
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Enter a shop name' : null,
            ),
            const Gap(Spacing.md),
            AppTextFormField(
              controller: _overviewController,
              label: 'Shop overview',
              hintText: 'Tell buyers what you sell...',
              maxLines: 4,
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Add a short overview'
                  : null,
            ),
            const Gap(Spacing.lg),
            Text(
              'Business document',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(Spacing.xs),
            Text(
              'Upload a business registration or any verification document.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const Gap(Spacing.sm),
            ..._documents.asMap().entries.map(
                  (e) => ListTile(
                    leading: Icon(e.value.type.icon),
                    title: Text(e.value.fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _documents.removeAt(e.key)),
                    ),
                  ),
                ),
            OutlinedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Add document'),
            ),
            if (_error != null) ...[
              const Gap(Spacing.md),
              Text(
                _error!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.error),
              ),
            ],
            const Gap(Spacing.xl),
            AppButton(
              label: _submitting ? 'Please wait...' : 'Continue',
              onPressed: _submitting ? null : _submit,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
