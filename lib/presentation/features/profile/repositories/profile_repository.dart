import 'package:nano_embryo/presentation/features/profile/models/profile.dart';
import 'package:nano_embryo/presentation/features/profile/repositories/profile_repository_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository(this._client);

  @override
  Future<Profile> getProfile(String userId) async {
    final response =
        await _client.from('profiles').select().eq('id', userId).single();

    return Profile.fromJson(response);
  }

  /// Fetch profile by user id — userId MUST be passed in
  @override
  Future<Profile?> fetchProfile(String userId) async {
    final response =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (response == null) return null;
    return Profile.fromJson(response);
  }

  /// Create empty profile for new user
  @override
  Future<void> createProfile(String userId) async {
    await _client.from('profiles').insert({
      'id': userId,
      'username': null,
      'bio': null,
      'avatar_url': null,
    });
  }

  /// Update username
  @override
  Future<Profile> updateUsername(String userId, String username) async {
    final response =
        await _client
            .from('profiles')
            .update({
              'username': username.toLowerCase(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId)
            .select() // 👈 Add this to get the updated record
            .single(); // 👈 Add this to get a single object

    return Profile.fromJson(response);
  }

  /// Check username availability (no userId needed)
  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final normalized = username.trim().toLowerCase();
      final response =
          await _client
              .from('profiles')
              .select('username')
              .ilike('username', normalized)
              .maybeSingle();
      final isAvailable = response == null;
      return isAvailable;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Profile> updateAvatar(String userId, String avatarUrl) async {
    final response =
        await _client
            .from('profiles')
            .update({
              'avatar_url': avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId)
            .select()
            .single();

    return Profile.fromJson(response);
  }

  @override
  Future<Profile> updateBio(String userId, String bio) async {
    final response =
        await _client
            .from('profiles')
            .update({
              'bio': bio,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId)
            .select()
            .single();

    return Profile.fromJson(response);
  }

  /// Optional: Combined update for multiple fields

  @override
  Future<Profile> updateProfile({
    required String userId,
    String? displayName,
    String? username,
    String? bio,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (displayName != null) updates['display_name'] = displayName;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;

    final response =
        await _client
            .from('profiles')
            .update(updates)
            .eq('id', userId)
            .select()
            .single();

    return Profile.fromJson(response);
  }

  @override
  Future<Profile> updateDisplayName(String userId, String displayName) async {
    final response =
        await _client
            .from('profiles')
            .update({
              'display_name': displayName,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId)
            .select()
            .single();

    return Profile.fromJson(response);
  }
}
