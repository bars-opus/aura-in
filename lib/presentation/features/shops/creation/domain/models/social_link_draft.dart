// lib/features/shop/creation/domain/entities/social_link_draft.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

enum SocialPlatform {
  instagram('Instagram', FontAwesomeIcons.instagram),
  facebook('Facebook', FontAwesomeIcons.facebook),
  twitter('Twitter', FontAwesomeIcons.twitter),
  tiktok('TikTok', FontAwesomeIcons.tiktok),
  youtube('YouTube', FontAwesomeIcons.youtube),
  linkedin('LinkedIn', FontAwesomeIcons.linkedinIn),
  pinterest('Pinterest', FontAwesomeIcons.pinterest),
  snapchat('Snapchat', FontAwesomeIcons.snapchat),
  whatsapp('WhatsApp', FontAwesomeIcons.whatsapp),
  website('Website', FontAwesomeIcons.language),
  other('Other', FontAwesomeIcons.link);

  const SocialPlatform(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  static SocialPlatform fromString(String value) {
    final lower = value.toLowerCase();
    return values.firstWhere(
      (p) => p.name == lower || p.displayName.toLowerCase() == lower,
      orElse: () => SocialPlatform.other,
    );
  }
}

class SocialLinkDraft extends Equatable {
  final String id; // ✅ Add this field
  final SocialPlatform platform;
  final String url;
  final bool isActive;

  SocialLinkDraft({
    String? id,
    required this.platform,
    required this.url,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  /// Validate URL based on platform
  String? validate() {
    if (url.isEmpty) return 'URL is required';

    // Basic URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }

    // Platform-specific validation
    switch (platform) {
      case SocialPlatform.instagram:
        if (!url.contains('instagram.com')) {
          return 'Must be a valid Instagram URL';
        }
        break;
      case SocialPlatform.facebook:
        if (!url.contains('facebook.com')) {
          return 'Must be a valid Facebook URL';
        }
        break;
      case SocialPlatform.twitter:
        if (!url.contains('twitter.com') && !url.contains('x.com')) {
          return 'Must be a valid Twitter/X URL';
        }
        break;
      case SocialPlatform.tiktok:
        if (!url.contains('tiktok.com')) {
          return 'Must be a valid TikTok URL';
        }
        break;
      // Add more platform validations as needed
      default:
        break;
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id, // ✅ Include id in JSON
    'platform': platform.name,
    'url': url,
    'isActive': isActive,
  };

  factory SocialLinkDraft.fromJson(Map<String, dynamic> json) {
    return SocialLinkDraft(
      id: json['id'] as String?, // ✅ Read id from JSON (optional)
      platform: SocialPlatform.fromString(json['platform'] as String),
      url: json['url'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, platform, url, isActive]; // ✅ Add id to props
}
