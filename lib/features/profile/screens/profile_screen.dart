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
    
    int daysLeft = 0;
    double progress = 1.0;
    Color progressColor = AppColors.success;
    
    if (user != null) {
      daysLeft = user.expiresAt.difference(DateTime.now()).inDays;
      if (daysLeft < 0) daysLeft = 0;
      
      progress = (daysLeft / 365).clamp(0.0, 1.0);
      
      if (daysLeft <= 7) {
        progressColor = AppColors.danger;
      } else if (daysLeft <= 30) {
        progressColor = AppColors.warning;
      } else {
        progressColor = AppColors.success;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.bgPrimary,
                    child: Icon(Icons.person, size: 40, color: AppColors.accentBlue),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?.fullName ?? 'Member', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(user?.inviteCode ?? 'VLTK-XXXX-XXXX', style: AppTextStyles.code),
                if (user?.email != null) ...[
                  const SizedBox(height: 8),
                  Text(user!.email!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecond)),
                ],
                const SizedBox(height: 24),
                
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sisa Masa Aktif', style: AppTextStyles.caption),
                        Text('$daysLeft Hari', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.bgPrimary,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Device Binding Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    user?.deviceId != null ? Icons.lock : Icons.lock_open,
                    color: user?.deviceId != null ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Device Binding', style: AppTextStyles.bodyEmphasis),
                      const SizedBox(height: 4),
                      Text(
                        user?.deviceName ?? 'Belum ada device yang terikat',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text('Menu', style: AppTextStyles.bodyEmphasis),
          const SizedBox(height: 16),
          
          // Menu List
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.info_outline, color: AppColors.accentBlue),
                  title: const Text('Tentang Kreator', style: AppTextStyles.bodyRegular),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => context.push('/creator'),
                ),
                const Divider(height: 1, color: AppColors.borderLight, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text('Keluar', style: TextStyle(color: AppColors.danger, fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
