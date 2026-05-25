import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';

class CreatorProfile {
  final String id;
  final String name;
  final String? bio;
  final String? photoUrl;
  final String? instagramUrl;
  final String? telegramUrl;
  final String? tiktokUrl;
  final String? twitterUrl;

  CreatorProfile({
    required this.id,
    required this.name,
    this.bio,
    this.photoUrl,
    this.instagramUrl,
    this.telegramUrl,
    this.tiktokUrl,
    this.twitterUrl,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    return CreatorProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      telegramUrl: json['telegram_url'] as String?,
      tiktokUrl: json['tiktok_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
    );
  }
}

final creatorProvider = FutureProvider<CreatorProfile?>((ref) async {
  final data = await SupabaseService.instance.client
      .from('creator_profile')
      .select('*')
      .limit(1)
      .maybeSingle();

  if (data != null) {
    return CreatorProfile.fromJson(data);
  }
  return null;
});
