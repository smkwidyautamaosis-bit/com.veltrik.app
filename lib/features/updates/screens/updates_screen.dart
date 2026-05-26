import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/notifications_provider.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_document': return Icons.description_rounded;
      case 'document': return Icons.picture_as_pdf_rounded;
      case 'expiry_warning': return Icons.warning_amber_rounded;
      default: return Icons.campaign_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'new_document': return AppColors.info;
      case 'document': return AppColors.accentBlue;
      case 'expiry_warning': return AppColors.warning;
      default: return AppColors.accentBlue;
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
        title: Text(
          'Updates',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: notifsAsyncValue.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pemberitahuan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecond),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi dari admin akan muncul di sini.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final notif = notifs[index];
              final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(notif.createdAt);
              final iconColor = _getIconColor(notif.notificationType);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: notif.isRead ? AppColors.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif.isRead ? AppColors.border : AppColors.accentBlue.withValues(alpha: 0.3),
                    width: notif.isRead ? 0.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: notif.isRead
                          ? Colors.black.withValues(alpha: 0.03)
                          : AppColors.accentBlue.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIcon(notif.notificationType), color: iconColor, size: 22),
                  ),
                  title: Text(
                    notif.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: notif.isRead ? AppColors.textSecond : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notif.body,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: notif.isRead ? AppColors.textMuted : AppColors.textSecond,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  trailing: !notif.isRead
                      ? Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                        )
                      : null,
                  onTap: () {
                    if (!notif.isRead) {
                      ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                    }
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.bgCard,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text(notif.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        content: SingleChildScrollView(child: Text(notif.body, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecond))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tutup', style: GoogleFonts.plusJakartaSans(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: AppColors.border,
              highlightColor: AppColors.bgSurface,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
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
}
