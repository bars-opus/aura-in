// lib/features/shops/creation/utils/amenity_icon_helper.dart

import 'package:flutter/material.dart';

class AmenityIconHelper {
  static IconData? getIconData(String? iconName) {
    if (iconName == null) return null;
    switch (iconName) {
      case 'wifi': return Icons.wifi;
      case 'local_parking': return Icons.local_parking;
      case 'credit_card': return Icons.credit_card;
      case 'attach_money': return Icons.attach_money;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'online_prediction': return Icons.online_prediction;
      case 'directions_walk': return Icons.directions_walk;
      case 'ac_unit': return Icons.ac_unit;
      case 'music_note': return Icons.music_note;
      case 'tv': return Icons.tv;
      case 'accessible': return Icons.accessible;
      case 'pets': return Icons.pets;
      case 'free_breakfast': return Icons.free_breakfast;
      case 'local_drink': return Icons.local_drink;
      case 'cookie': return Icons.cookie;
      case 'wine_bar': return Icons.wine_bar;
      case 'sports_bar': return Icons.sports_bar;
      case 'wc': return Icons.wc;
      case 'lock': return Icons.lock;
      case 'meeting_room': return Icons.meeting_room;
      case 'chair': return Icons.chair;
      case 'child_care': return Icons.child_care;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'spa': return Icons.spa;
      case 'hair_dryer': return Icons.headset_sharp;
      case 'air': return Icons.air;
      case 'bed': return Icons.bed;
      case 'whatshot': return Icons.whatshot;
      case 'hot_tub': return Icons.hot_tub;
      case 'highlight': return Icons.highlight;
      case 'build': return Icons.build;
      case 'bathtub': return Icons.bathtub;
      case 'local_laundry_service': return Icons.local_laundry_service;
      case 'content_cut': return Icons.content_cut;
      case 'face': return Icons.face;
      case 'light': return Icons.light;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'visibility': return Icons.visibility;
      case 'eco': return Icons.eco;
      case 'recycling': return Icons.recycling;
      case 'masks': return Icons.masks;
      case 'sanitizer': return Icons.sanitizer;
      case 'social_distance': return Icons.social_distance;
      case 'contactless': return Icons.contactless;
      case 'dry': return Icons.dry;
      case 'menu_book': return Icons.menu_book;
      default: return Icons.check_circle_outline;
    }
  }
}
