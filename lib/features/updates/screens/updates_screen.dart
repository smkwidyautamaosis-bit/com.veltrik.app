import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/notifications_provider.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_document': return Icons.picture_as_pdf_rounded;
      case 'document': return Icons.description_rounded;
      case 'expiry_warning': return Icons.warning_amber_rounded;
      default: return Icons.campaign_rounded;
    }
  }

  List<Color> _getGradient(String type) {
    switch (type) {
      case 'new_document': return [const Color(0xFF2563EB), const Color(0xFF60A5FA)];
      case 'document': return [const Color(0xFF7C3AED), const Color(0xFFA78BFA)];
      case 'expiry_warning': return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      default: return [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)];
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'new_document': return 'Dokumen Baru';
      case 'document': return 'Dokumen';
      case 'expiry_warning': return 'Peringatan';
      default: return 'Pengumuman';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsyncValue = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veltrik',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecond),
                ),
                Text(
                  'Updates',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          notifsAsyncValue.when(
            data: (notifs) {
              final unread = notifs.where((n) => !n.isRead).length;
              if (unread == 0) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unread Baru',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notifsAsyncValue.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentBlue.withValues(alpha: 0.1), AppColors.accentBlue.withValues(alpha: 0.05)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, size: 52, color: AppColors.accentBlue),
                  ),
                  const SizedBox(height: 20),
                  Text('Belum ada pemberitahuan',
                      style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Notifikasi dari admin akan muncul di sini.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            );
          }

          // Group by date
          final today = DateTime.now();
          final todayNotifs = notifs.where((n) {
            final d = n.createdAt;
            return d.year == today.year && d.month == today.month && d.day == today.day;
          }).toList();
          final olderNotifs = notifs.where((n) {
            final d = n.createdAt;
            return !(d.year == today.year && d.month == today.month && d.day == today.day);
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (todayNotifs.isNotEmpty) ...[
                _sectionHeader('Hari Ini'),
                const SizedBox(height: 10),
                ...todayNotifs.map((n) => _NotifCard(
                  notif: n,
                  gradient: _getGradient(n.notificationType),
                  icon: _getIcon(n.notificationType),
                  typeLabel: _getTypeLabel(n.notificationType),
                  onTap: () {
                    if (!n.isRead) ref.read(notificationsProvider.notifier).markAsRead(n.id);
                    _showDetail(context, n);
                  },
                )),
                const SizedBox(height: 8),
              ],
              if (olderNotifs.isNotEmpty) ...[
                _sectionHeader('Sebelumnya'),
                const SizedBox(height: 10),
                ...olderNotifs.map((n) => _NotifCard(
                  notif: n,
                  gradient: _getGradient(n.notificationType),
                  icon: _getIcon(n.notificationType),
                  typeLabel: _getTypeLabel(n.notificationType),
                  onTap: () {
                    if (!n.isRead) ref.read(notificationsProvider.notifier).markAsRead(n.id);
                    _showDetail(context, n);
                  },
                )),
              ],
            ],
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Shimmer.fromColors(
              baseColor: AppColors.border,
              highlightColor: AppColors.bgSurface,
              child: Container(
                height: 90,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: GoogleFonts.plusJakartaSans(color: AppColors.danger)),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }

  void _showDetail(BuildContext context, dynamic notif) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 20),
            Text(notif.title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(AppDateUtils.toWIB(notif.createdAt), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(notif.body, style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.7, color: AppColors.textSecond)),
          ],
        ),
      ),
    );
  }
}

// ── Notif Card ────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final dynamic notif;
  final List<Color> gradient;
  final IconData icon;
  final String typeLabel;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notif,
    required this.gradient,
    required this.icon,
    required this.typeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = notif.isRead as bool;
    final dateStr = AppDateUtils.toWIB(notif.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead ? AppColors.border : AppColors.accentBlue.withValues(alpha: 0.35),
            width: isRead ? 0.8 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isRead ? Colors.black.withValues(alpha: 0.03) : AppColors.accentBlue.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar for unread
              if (!isRead)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
                  ),
                ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isRead ? 16 : 12, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient icon
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: gradient.first.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  typeLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9, fontWeight: FontWeight.w700,
                                    color: gradient.first, letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              color: isRead ? AppColors.textSecond : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.body,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.5, color: AppColors.textMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Text(dateStr, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
