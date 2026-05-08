import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/contact_tile.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';

class ContactBottomSheet extends ConsumerStatefulWidget {
  final String shopId;
  final String? shopName;

  const ContactBottomSheet({super.key, required this.shopId, this.shopName});

  @override
  ConsumerState<ContactBottomSheet> createState() => _ContactBottomSheetState();
}

class _ContactBottomSheetState extends ConsumerState<ContactBottomSheet> {
  late Future<List<ContactDraft>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(bookingRepositoryProvider);
    _contactsFuture = repository.getShopContacts(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomSheetHeader(title: 'Contact'),

        // Header
        AppDivider(),

        // Contacts List
        FutureBuilder<List<ContactDraft>>(
          future: _contactsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingStateWidget(type: LoadingStateType.inline);
            }

            if (snapshot.hasError) {
              return Center(
                child: ErrorStateWidget(
                  title: '',

                  subtitle: 'Failed to load contacts',
                  onPrimaryAction: () {
                    setState(() {
                      final repository = ref.read(bookingRepositoryProvider);
                      _contactsFuture = repository.getShopContacts(
                        widget.shopId,
                      );
                    });
                  },
                ),
              );
            }

            final contacts = snapshot.data ?? [];

            if (contacts.isEmpty) {
              return Center(
                child: EmptyStateWidget(
                  icon: Icons.phone,
                  title: '',
                  subtitle: 'No contact information available',
                ),
              );
            }
            // Group contacts by type
            final groupedContacts = _groupContactsByType(contacts);
            return ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
              children:
                  groupedContacts.entries.map((entry) {
                    return _buildContactSection(
                      context,
                      type: entry.key,
                      contacts: entry.value,
                    );
                  }).toList(),
            );
          },
        ),

        Gap(Spacing.lg.h),
      ],
    );
  }

  Widget _buildContactSection(
    BuildContext context, {
    required ContactType type,
    required List<ContactDraft> contacts,
  }) {
    return ShopDetailsSection(
      showCard: false,
      title: type.displayName.toUpperCase(),
      seeAllOnperssed: null,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Items
          ...contacts.map((contact) => _buildContactItem(context, contact)),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, ContactDraft contact) {
    return ContactTile(
      key: ValueKey(contact.id),
      contact: contact,
      onEdit: null,
      onDelete: null,
      isDraggable: false,
    );
  }

  Map<ContactType, List<ContactDraft>> _groupContactsByType(
    List<ContactDraft> contacts,
  ) {
    final grouped = <ContactType, List<ContactDraft>>{};

    for (final type in ContactType.values) {
      final filtered = contacts.where((c) => c.type == type).toList();
      if (filtered.isNotEmpty) {
        grouped[type] = filtered;
      }
    }

    return grouped;
  }
}
