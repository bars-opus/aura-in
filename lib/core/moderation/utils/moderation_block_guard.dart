import 'package:nano_embryo/core/moderation/data/moderation_models.dart';

bool moderationBlockGuard(ModerationCheckResult? result) {
  return result?.isBlocked == true;
}
