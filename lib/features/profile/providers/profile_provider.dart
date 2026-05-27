import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/supabase_service.dart';

class ProfileAvatarNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileAvatarNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  final _picker = ImagePicker();

  Future<void> pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    state = const AsyncValue.loading();

    try {
      final user = _ref.read(authProvider).user;
      if (user == null) throw Exception('User tidak ditemukan');

      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final fileName = 'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload ke Supabase Storage bucket 'avatars'
      await SupabaseService.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      // Get public URL
      final publicUrl = SupabaseService.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update di tabel users
      await SupabaseService.instance.client
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      // Update state lokal agar langsung tampil
      _ref.read(authProvider.notifier).updateAvatarUrl(publicUrl);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileAvatarProvider =
    StateNotifierProvider<ProfileAvatarNotifier, AsyncValue<void>>((ref) {
  return ProfileAvatarNotifier(ref);
});
