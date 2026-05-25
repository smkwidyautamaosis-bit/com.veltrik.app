import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/notifications_provider.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_document': return Icons.description;
      case 'expiry_warning': return Icons.warning_amber;
      default: return Icons.campaign;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'new_document': return AppColors.info;
      case 'expiry_warning': return AppColors.warning;
      default: return AppColors.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsyncValue = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
      ),
      body: notifsAsyncValue.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off, size: 80, color: AppColors.borderLight),
                  const SizedBox(height: 16),
                  Text('Belum ada pemberitahuan', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecond)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final notif = notifs[index];
              final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(notif.createdAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: notif.isRead ? AppColors.bgCard : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: notif.isRead ? null : Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                  boxShadow: notif.isRead ? null : [
                    BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
                  ]
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: notif.isRead ? AppColors.bgPrimary : _getIconColor(notif.notificationType).withValues(alpha: 0.2),
                    child: Icon(_getIcon(notif.notificationType), color: notif.isRead ? AppColors.textMuted : _getIconColor(notif.notificationType)),
                  ),
                  title: Text(
                    notif.title, 
                    style: AppTextStyles.bodyEmphasis.copyWith(
                      color: notif.isRead ? AppColors.textSecond : AppColors.textPrimary,
                    )
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        notif.body, 
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: notif.isRead ? AppColors.textMuted : AppColors.textSecond,
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 8),
                      Text(dateStr, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                onTap: () {
                  if (!notif.isRead) {
                    ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                  }
                  // Show full message in dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.bgCard,
                      title: Text(notif.title, style: AppTextStyles.h2),
                      content: Text(notif.body, style: AppTextStyles.bodyRegular),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup', style: TextStyle(color: AppColors.accentBlue)),
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
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Shimmer.fromColors(
                baseColor: AppColors.bgCard,
                highlightColor: AppColors.bgElevated,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: double.infinity, height: 16, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(width: 200, height: 12, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(width: 100, height: 10, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.danger))),
      ),
    );
  }
}
