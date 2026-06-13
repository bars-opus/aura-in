// lib/features/shop/creation/presentation/screens/manage_contacts_screen.dart

import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/contact_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/contacts_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class ManageContactsScreen extends ConsumerStatefulWidget {
  const ManageContactsScreen({super.key});

  @override
  ConsumerState<ManageContactsScreen> createState() =>
      _ManageContactsScreenState();
}

class _ManageContactsScreenState extends ConsumerState<ManageContactsScreen> {
  @override
  Widget build(BuildContext context) {
    // final contacts = ref.watch(contactsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final draft = ref.watch(shopCreationProvider);
    final contacts = ref.watch(contactsProvider);
    // Add this to verify rebuilds

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          AppIconButton(icon: Icons.add, onPressed: _showAddContactModal),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        children: [
          SemanticContainerWidget(
            content: 'Add phone numbers, email addresses, and website',
            icon: Icons.call,
            title: 'How customers reach you',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.md.h),

          Expanded(
            child:
                contacts.isEmpty
                    ? _buildEmptyState()
                    : SizedBox(
                      height: contacts.length * 100.h,
                      child: ReorderableListView.builder(
                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: contacts.length,
                        key: ValueKey('contacts_list_${contacts.length}'),
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(contactsProvider.notifier)
                              .reorderContacts(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ContactTile(
                            key: ValueKey(contact.id),
                            contact: contact,
                            onEdit: () => _editContact(index),
                            onDelete: () => _deleteContact(index),
                            isDraggable: true,
                          );
                        },
                      ),
                    ),
          ),

          // Add button
        ],
      ),
      bottomNavigationBar:
          draft.isContactComplete
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to socila links',
                    center: false,
                    iconData: Icons.share,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    onPressed: _saveAndContinue,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : null,
    );
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/manageSocialLinks'); // Use your navigation method
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStateWidget(
        actionLabel: 'Add',
        onAction: _showAddContactModal,
        icon: Icons.phone,
        title: 'No contacts yet',
        subtitle: 'Add phone, email, or website',
      ),
    );
  }

  String? _isoCodeFromCurrencyCode(String? code) {
    const m = {
      'GHS': 'GH', 'NGN': 'NG', 'GBP': 'GB',
      'USD': 'US', 'ZAR': 'ZA', 'KES': 'KE',
    };
    return code == null ? null : m[code];
  }

  void _showAddContactModal() {
    final draft = ref.read(shopCreationProvider);
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: AddContactModal(
        shopCountryIsoCode: _isoCodeFromCurrencyCode(draft.currencyCode),
        onSave: (contact) {
          ref.read(contactsProvider.notifier).addContact(contact);
        },
      ),
    );
  }

  void _editContact(int index) {
    final contact = ref.read(contactsProvider)[index];
    final draft = ref.read(shopCreationProvider);
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: AddContactModal(
        initialContact: contact,
        shopCountryIsoCode: _isoCodeFromCurrencyCode(draft.currencyCode),
        onSave: (updatedContact) {
          setState(() {});
          ref
              .read(contactsProvider.notifier)
              .updateContact(index, updatedContact);
        },
      ),
    );
  }

  void _deleteContact(int index) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      widget: ConfirmationDialog(
        icon: Icons.delete,
        type: ConfirmationType.warning,
        title: 'Remove Contact?',
        message: 'Are you sure you want to remove this contact?',
        confirmText: 'Remove',
        onConfirm: () {
          ref.read(contactsProvider.notifier).removeContact(index);
        },
      ),
    );
  }
}
