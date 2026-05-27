import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _totalDocsRead = 0;
  int _totalDocsAvailable = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final viewsRes = await SupabaseService.instance.client
          .from('document_views')
          .select('id')
          .eq('user_id', user.id);

      final docsRes = await SupabaseService.instance.client
          .from('documents')
          .select('id');

      if (mounted) {
        setState(() {
          _totalDocsRead = (viewsRes as List).length;
          _totalDocsAvailable = (docsRes as List).length;
          _statsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoaded = true);
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar Aplikasi',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecond)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecond, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: Text('Keluar',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final avatarState = ref.watch(profileAvatarProvider);
    final isUploadingAvatar = avatarState is AsyncLoading;

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

    final expiresStr = user != null ? AppDateUtils.toWIBDateOnly(user.expiresAt) : '-';
    final codeFragment = user?.inviteCode.substring(math.max(0, (user.inviteCode.length) - 4)) ?? 'XXXX';

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ─── Hero Header ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    // AppBar row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/logo.png', height: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Veltrik',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                          onPressed: () => _confirmLogout(context, ref),
                          tooltip: 'Keluar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar
                    GestureDetector(
                      onTap: isUploadingAvatar
                          ? null
                          : () => ref.read(profileAvatarProvider.notifier).pickAndUploadAvatar(),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: const Color(0xFF1D4ED8),
                              child: isUploadingAvatar
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : user?.avatarUrl != null
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: user!.avatarUrl!,
                                            width: 104, height: 104,
                                            fit: BoxFit.cover,
                                            placeholder: (context, _) => Shimmer.fromColors(
                                              baseColor: const Color(0xFF1D4ED8),
                                              highlightColor: Colors.white24,
                                              child: Container(color: Colors.white),
                                            ),
                                            errorWidget: (context, url, _) => const Icon(
                                              Icons.person_rounded, size: 52, color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.person_rounded, size: 52, color: Colors.white),
                            ),
                          ),
                          // Camera badge
                          Positioned(
                            bottom: 2, right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      user?.fullName ?? 'Member',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Invite code badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        user?.inviteCode ?? 'VLTK-XXXX-XXXX',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    if (user?.email != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        user!.email!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.white70,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          _buildStatCell('📖', _statsLoaded ? '$_totalDocsRead' : '...', 'Dibaca'),
                          _buildStatDivider(),
                          _buildStatCell('📚', _statsLoaded ? '$_totalDocsAvailable' : '...', 'Tersedia'),
                          _buildStatDivider(),
                          _buildStatCell('⏳', '$daysLeft', 'Hari Aktif'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Body Content ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error state for upload
                if (avatarState is AsyncError)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gagal upload foto. Pastikan bucket "avatars" sudah dibuat di Supabase.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ─── Veltrik Pass Card ───────────────────────────────
                InkWell(
                  onTap: () => context.push('/admin/veltrik-pass', extra: {
                    'memberName': user?.fullName ?? 'Member',
                    'inviteCode': user?.inviteCode ?? '',
                    'expiresAt': expiresStr,
                  }),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0F7FF), Color(0xFFDBEAFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.credit_card_rounded, color: Color(0xFF2563EB), size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Veltrik Pass',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'VLTK-••••-$codeFragment  •  Berlaku hingga $expiresStr',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Masa Aktif Card ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('⏱  Masa Aktif Keanggotaan',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$daysLeft Hari',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: progressColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berlaku hingga: $expiresStr',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Device Binding ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (user?.deviceId != null ? AppColors.success : AppColors.textMuted).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          user?.deviceId != null ? Icons.lock_rounded : Icons.lock_open_rounded,
                          color: user?.deviceId != null ? AppColors.success : AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Device Binding',
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(
                              user?.deviceName ?? 'Belum ada device yang terikat',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecond),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text('Menu',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.textMuted, letterSpacing: 0.5)),
                const SizedBox(height: 10),

                // ─── Menu ────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFF8B5CF6),
                        label: 'Ganti Foto Profil',
                        onTap: isUploadingAvatar
                            ? null
                            : () => ref.read(profileAvatarProvider.notifier).pickAndUploadAvatar(),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        color: AppColors.accentBlue,
                        label: 'Tentang Kreator',
                        onTap: () => context.push('/creator'),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        color: AppColors.danger,
                        label: 'Keluar',
                        onTap: () => _confirmLogout(context, ref),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: isDestructive ? AppColors.danger : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: onTap == null
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
