import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/creator_provider.dart';

class CreatorScreen extends ConsumerWidget {
  const CreatorScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorAsync = ref.watch(creatorProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: creatorAsync.when(
        data: (creator) {
          if (creator == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.bgPrimary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: Text('Tentang Kreator',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              backgroundColor: AppColors.bgSurface,
              body: Center(
                child: Text('Profil kreator belum diatur.',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecond)),
              ),
            );
          }

          final socials = [
            if (creator.instagramUrl != null && creator.instagramUrl!.isNotEmpty)
              _SocialData(
                icon: FontAwesomeIcons.instagram,
                label: 'Instagram',
                handle: _extractHandle(creator.instagramUrl!),
                url: creator.instagramUrl!,
                gradientColors: const [Color(0xFFE1306C), Color(0xFFF77737), Color(0xFF833AB4)],
                bgColor: const Color(0xFFE1306C),
              ),
            if (creator.tiktokUrl != null && creator.tiktokUrl!.isNotEmpty)
              _SocialData(
                icon: FontAwesomeIcons.tiktok,
                label: 'TikTok',
                handle: _extractHandle(creator.tiktokUrl!),
                url: creator.tiktokUrl!,
                gradientColors: const [Color(0xFF010101), Color(0xFF69C9D0)],
                bgColor: const Color(0xFF010101),
              ),
            if (creator.twitterUrl != null && creator.twitterUrl!.isNotEmpty)
              _SocialData(
                icon: FontAwesomeIcons.xTwitter,
                label: 'Twitter / X',
                handle: _extractHandle(creator.twitterUrl!),
                url: creator.twitterUrl!,
                gradientColors: const [Color(0xFF000000), Color(0xFF333333)],
                bgColor: const Color(0xFF000000),
              ),
            if (creator.telegramUrl != null && creator.telegramUrl!.isNotEmpty)
              _SocialData(
                icon: FontAwesomeIcons.telegram,
                label: 'Telegram',
                handle: _extractHandle(creator.telegramUrl!),
                url: creator.telegramUrl!,
                gradientColors: const [Color(0xFF0088CC), Color(0xFF229ED9)],
                bgColor: const Color(0xFF229ED9),
              ),
          ];

          return CustomScrollView(
            slivers: [
              // ── Hero App Bar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Dark gradient bg
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF1D4ED8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Geometric decorations
                      Positioned.fill(child: CustomPaint(painter: _HeroBgPainter())),
                      // Content
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Avatar with ring
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF60A5FA), Color(0xFF818CF8), Color(0xFFA78BFA)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 58,
                                backgroundColor: const Color(0xFF1E3A5F),
                                child: creator.photoUrl != null && creator.photoUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: creator.photoUrl!,
                                          width: 116, height: 116,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, _) => const Icon(Icons.person_rounded, size: 58, color: Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.person_rounded, size: 58, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              creator.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                creator.bio ?? 'Developer Veltrik App',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Socials header
                      if (socials.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 4, height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Ikuti Kreator',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Social cards
                        ...socials.map((s) => _SocialCard(data: s, onTap: () => _launchUrl(s.url))),
                        const SizedBox(height: 28),
                      ],

                      // About section
                      Row(
                        children: [
                          Container(
                            width: 4, height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Tentang Aplikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          children: [
                            _InfoRow(icon: Icons.apps_rounded, label: 'Nama Aplikasi', value: 'Veltrik'),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.code_rounded, label: 'Teknologi', value: 'Flutter + Supabase'),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.person_rounded, label: 'Developer', value: creator.name),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.copyright_rounded, label: 'Hak Cipta', value: '© ${DateTime.now().year} ${creator.name}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
          backgroundColor: AppColors.bgSurface,
          appBar: AppBar(
            backgroundColor: AppColors.bgPrimary, elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text('Tentang Kreator',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          body: Shimmer.fromColors(
            baseColor: AppColors.border,
            highlightColor: AppColors.bgSurface,
            child: Column(
              children: [
                Container(height: 300, color: Colors.white),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                      const SizedBox(height: 12),
                      Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(backgroundColor: AppColors.bgPrimary, elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              )),
          body: Center(child: Text('Error: $err', style: GoogleFonts.plusJakartaSans(color: AppColors.danger))),
        ),
      ),
    );
  }

  String _extractHandle(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return '@${segments.last}';
    } catch (_) {}
    return url;
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _SocialData {
  final IconData icon;
  final String label;
  final String handle;
  final String url;
  final List<Color> gradientColors;
  final Color bgColor;

  const _SocialData({
    required this.icon, required this.label, required this.handle,
    required this.url, required this.gradientColors, required this.bgColor,
  });
}

// ── Social Card ───────────────────────────────────────────────────────────────
class _SocialCard extends StatelessWidget {
  final _SocialData data;
  final VoidCallback onTap;

  const _SocialCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: data.gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: data.bgColor.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: FaIcon(data.icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.label,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(data.handle,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: data.gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Follow',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.accentBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hero background painter ───────────────────────────────────────────────────
class _HeroBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final rand = math.Random(7);
    for (int i = 0; i < 6; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final r = 40.0 + rand.nextDouble() * 80;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
