import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMedia {
  String id;
  final String name;
  final String link;

  SocialMedia({
    required this.id,
    required this.name,
    required this.link,
  });

  // Get social media platform from link
  String get platform {
    final uri = Uri.tryParse(link);
    if (uri == null) return 'website';

    final host = uri.host.toLowerCase();

    if (host.contains('instagram.com')) return 'Instagram';
    if (host.contains('facebook.com')) return 'Facebook';
    if (host.contains('twitter.com') || host.contains('x.com'))
      return 'Twitter';
    if (host.contains('linkedin.com')) return 'LinkedIn';
    if (host.contains('youtube.com')) return 'YouTube';
    if (host.contains('tiktok.com')) return 'TikTok';
    if (host.contains('pinterest.com')) return 'Pinterest';
    if (host.contains('snapchat.com')) return 'Snapchat';
    if (host.contains('whatsapp.com')) return 'WhatsApp';
    if (host.contains('telegram.org')) return 'Telegram';
    if (host.contains('github.com')) return 'GitHub';
    if (host.contains('behance.net')) return 'Behance';
    if (host.contains('dribbble.com')) return 'Dribbble';
    if (host.contains('medium.com')) return 'Medium';

    return 'Website';
  }

  // Get platform icon
  IconData get icon {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return FontAwesomeIcons.twitter; // or Icons.twitter
      case 'linkedin':
        return Icons.linked_camera; // Use appropriate icon
      case 'youtube':
        return Icons.youtube_searched_for; // or Icons.play_circle_filled;
      case 'tiktok':
        return Icons.music_note;
      case 'pinterest':
        return Icons.picture_in_picture;
      case 'snapchat':
        return Icons.camera_alt;
      case 'whatsapp':
        return Icons.chat;
      case 'telegram':
        return Icons.send;
      case 'github':
        return Icons.code;
      case 'behance':
        return Icons.palette;
      case 'dribbble':
        return Icons.sports_basketball;
      case 'medium':
        return Icons.article;
      default:
        return Icons.link;
    }
  }

  // Get platform color
  Color get color {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'pinterest':
        return const Color(0xFFBD081C);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'github':
        return const Color(0xFF181717);
      case 'behance':
        return const Color(0xFF1769FF);
      case 'dribbble':
        return const Color(0xFFEA4C89);
      case 'medium':
        return const Color(0xFF000000);
      default:
        return Colors.blue;
    }
  }

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      id: json['id'],
      name: json['name'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'link': link,
    };
  }
}
