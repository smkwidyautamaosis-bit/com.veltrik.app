import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Keluar Aplikasi', style: AppTextStyles.h2),
        content: const Text('Apakah Anda yakin ingin keluar?', style: AppTextStyles.bodyRegular),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecond)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.bgPrimary,
                  child: Icon(Icons.person, size: 40, color: AppColors.accentBlue),
                ),
                const SizedBox(height: 16),
                Text(user?.fullName ?? 'Member', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(user?.inviteCode ?? 'VLTK-XXXX-XXXX', style: AppTextStyles.code),
                if (user?.email != null) ...[
                  const SizedBox(height: 8),
                  Text(user!.email!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Menu', style: AppTextStyles.bodyEmphasis),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.textPrimary),
            title: const Text('Tentang Kreator', style: AppTextStyles.bodyRegular),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () => context.push('/creator'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Keluar', style: TextStyle(color: AppColors.danger, fontSize: 16)),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
