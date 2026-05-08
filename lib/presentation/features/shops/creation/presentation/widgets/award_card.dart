// lib/features/shop/creation/presentation/widgets/award_card.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/widgets/info_row.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

class AwardCard extends StatelessWidget {
  final AwardDTO award;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDraggable;

  const AwardCard({
    super.key,
    required this.award,
    required this.onEdit,
    required this.onDelete,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      elevation: isDraggable ? null : 0,
      margin: EdgeInsets.only(bottom: Spacing.xs),
      onTap: () {
        BottomSheetUtils.showDocumentationBottomSheet(
          context: context,
          widget: _details(theme),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  award.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (award.link != null)
                GestureDetector(
                  onTap: () {
                    _launchLink(award.link!);
                  },
                  child: Icon(
                    Icons.open_in_new,
                    size: IconSizes.sm.h,
                    color: colorScheme.onBackground.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          if (award.description != null)
            Text(
              award.description ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          Gap(Spacing.sm),

          InfoRow(label: 'Issued By', value: award.issuer ?? "", maxline: 1),
          InfoRow(
            label: 'Received',
            maxline: 1,
            value:
                award.dateReceived == null
                    ? ''
                    : MyDateFormat.toDate(DateTime.parse(award.dateReceived!)),
          ),
        ],
      ),
    );
  }

  _details(ThemeData theme) {
    var _labeStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onBackground,
    );
    var _valueeStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold,
    );
    return ListView(
      children: [
        BottomSheetHeader(title: ''),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Name\n', style: _labeStyle),
              TextSpan(text: award.name, style: _valueeStyle),
            ],
          ),
        ),
        Gap(Spacing.md),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Issued by\n', style: _labeStyle),
              TextSpan(text: award.issuer, style: _valueeStyle),
            ],
          ),
        ),
        Gap(Spacing.md),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Date received\n', style: _labeStyle),
              TextSpan(
                text:
                    award.dateReceived == null
                        ? ''
                        : MyDateFormat.toDate(
                          DateTime.parse(award.dateReceived!),
                        ),
                style: _valueeStyle,
              ),
            ],
          ),
        ),
        Gap(Spacing.md),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Description\n', style: _labeStyle),
              TextSpan(text: award.name, style: _valueeStyle),
            ],
          ),
        ),
        Gap(Spacing.xl),
        Center(
          child: GestureDetector(
            onTap: () {
              _launchLink(award.link!);
            },
            child: Text(
              'See verification webstie',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
