
// Supporting DTOs
import 'package:equatable/equatable.dart';

class SocialLinkDTO extends Equatable {
  final String platform;
  final String url;

  const SocialLinkDTO({required this.platform, required this.url});

  factory SocialLinkDTO.fromJson(Map<String, dynamic> json) => SocialLinkDTO(
    platform: json['platform'] as String,
    url: json['url'] as String,
  );

  @override
  List<Object?> get props => [platform, url];
}
