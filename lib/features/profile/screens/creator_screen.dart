import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/creator_provider.dart';

class CreatorScreen extends ConsumerWidget {
  const CreatorScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorAsync = ref.watch(creatorProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text(
          'Tentang Kreator',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: creatorAsync.when(
        data: (creator) {
          if (creator == null) {
            return Center(
              child: Text(
                'Profil kreator belum diatur.',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecond),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo
                if (creator.photoUrl != null && creator.photoUrl!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.accentRoyal],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: CachedNetworkImageProvider(creator.photoUrl!),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.accentBlue.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 60, color: AppColors.accentBlue),
                  ),

                const SizedBox(height: 20),
                Text(
                  creator.name,
                  style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                if (creator.bio != null) ...[
                  Text(
                    creator.bio!,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecond, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),

                // Social Links
                if ([
                  creator.instagramUrl,
                  creator.tiktokUrl,
                  creator.twitterUrl,
                  creator.telegramUrl,
                ].any((url) => url != null && url.isNotEmpty)) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ikuti Saya',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecond,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            if (creator.instagramUrl != null && creator.instagramUrl!.isNotEmpty)
                              _SocialButton(
                                icon: Icons.camera_alt_rounded,
                                label: 'Instagram',
                                color: const Color(0xFFE1306C),
                                onTap: () => _launchUrl(creator.instagramUrl!),
                              ),
                            if (creator.tiktokUrl != null && creator.tiktokUrl!.isNotEmpty)
                              _SocialButton(
                                icon: Icons.music_note_rounded,
                                label: 'TikTok',
                                color: const Color(0xFF010101),
                                onTap: () => _launchUrl(creator.tiktokUrl!),
                              ),
                            if (creator.twitterUrl != null && creator.twitterUrl!.isNotEmpty)
                              _SocialButton(
                                icon: Icons.alternate_email_rounded,
                                label: 'Twitter/X',
                                color: const Color(0xFF1DA1F2),
                                onTap: () => _launchUrl(creator.twitterUrl!),
                              ),
                            if (creator.telegramUrl != null && creator.telegramUrl!.isNotEmpty)
                              _SocialButton(
                                icon: Icons.send_rounded,
                                label: 'Telegram',
                                color: const Color(0xFF229ED9),
                                onTap: () => _launchUrl(creator.telegramUrl!),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Shimmer.fromColors(
            baseColor: AppColors.border,
            highlightColor: AppColors.bgSurface,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(height: 24),
                Container(width: 200, height: 24, color: Colors.white),
                const SizedBox(height: 16),
                Container(width: 300, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 280, height: 16, color: Colors.white),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: GoogleFonts.plusJakartaSans(color: AppColors.danger)),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
