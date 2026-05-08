// lib/features/shop/creation/utils/social_link_validator.dart
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';

class SocialLinkValidator {
  static String? validateUrl(String url, SocialPlatform platform) {
    if (url.isEmpty) return 'URL is required';

    // Check URL format
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }

    // Platform-specific validation
    switch (platform) {
      case SocialPlatform.instagram:
        if (!url.contains('instagram.com')) {
          return 'Please enter a valid Instagram URL (instagram.com/username)';
        }
        break;
      case SocialPlatform.facebook:
        if (!url.contains('facebook.com')) {
          return 'Please enter a valid Facebook URL (facebook.com/pagename)';
        }
        break;
      case SocialPlatform.twitter:
        if (!url.contains('twitter.com') && !url.contains('x.com')) {
          return 'Please enter a valid Twitter/X URL (twitter.com/username)';
        }
        break;
      case SocialPlatform.tiktok:
        if (!url.contains('tiktok.com')) {
          return 'Please enter a valid TikTok URL (tiktok.com/@username)';
        }
        break;
      case SocialPlatform.youtube:
        if (!url.contains('youtube.com') && !url.contains('youtu.be')) {
          return 'Please enter a valid YouTube URL';
        }
        break;
      case SocialPlatform.linkedin:
        if (!url.contains('linkedin.com')) {
          return 'Please enter a valid LinkedIn URL';
        }
        break;
      case SocialPlatform.pinterest:
        if (!url.contains('pinterest.com')) {
          return 'Please enter a valid Pinterest URL';
        }
        break;
      case SocialPlatform.snapchat:
        if (!url.contains('snapchat.com')) {
          return 'Please enter a valid Snapchat URL';
        }
        break;
      case SocialPlatform.whatsapp:
        if (!url.contains('wa.me') && !url.contains('whatsapp.com')) {
          return 'Please enter a valid WhatsApp URL (wa.me/phone)';
        }
        break;
      case SocialPlatform.website:
        // Only basic URL validation for websites
        break;
      case SocialPlatform.other:
        // Only basic URL validation for other platforms
        break;
    }

    return null;
  }

  static String? validateUsername(String username, SocialPlatform platform) {
    if (username.isEmpty) return 'Username is required';

    // Remove @ if present
    username = username.replaceAll('@', '');

    // Platform-specific username validation
    switch (platform) {
      case SocialPlatform.instagram:
        if (!RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(username)) {
          return 'Invalid Instagram username';
        }
        break;
      case SocialPlatform.twitter:
        if (!RegExp(r'^[a-zA-Z0-9_]{1,15}$').hasMatch(username)) {
          return 'Invalid Twitter username (max 15 characters)';
        }
        break;
      case SocialPlatform.tiktok:
        if (!RegExp(r'^[a-zA-Z0-9._]{1,24}$').hasMatch(username)) {
          return 'Invalid TikTok username';
        }
        break;
      default:
        break;
    }

    return null;
  }

  static String buildUrl(String input, SocialPlatform platform) {
    // If it's already a full URL, return as-is
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }

    // Remove @ if present
    input = input.replaceAll('@', '');

    // Build platform-specific URL
    switch (platform) {
      case SocialPlatform.instagram:
        return 'https://instagram.com/$input';
      case SocialPlatform.facebook:
        return 'https://facebook.com/$input';
      case SocialPlatform.twitter:
        return 'https://twitter.com/$input';
      case SocialPlatform.tiktok:
        return 'https://tiktok.com/@$input';
      case SocialPlatform.youtube:
        return 'https://youtube.com/@$input';
      case SocialPlatform.linkedin:
        return 'https://linkedin.com/in/$input';
      case SocialPlatform.pinterest:
        return 'https://pinterest.com/$input';
      case SocialPlatform.snapchat:
        return 'https://snapchat.com/add/$input';
      case SocialPlatform.whatsapp:
        return 'https://wa.me/$input';
      default:
        return input; // Return as-is for website/other
    }
  }
}
