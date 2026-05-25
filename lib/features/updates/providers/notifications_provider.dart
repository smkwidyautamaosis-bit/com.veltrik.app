import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/notification_model.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final userId = ref.watch(authProvider).user?.id;
  return NotificationsNotifier(userId);
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final String? userId;
  RealtimeChannel? _subscription;

  NotificationsNotifier(this.userId) : super(const AsyncValue.loading()) {
    if (userId != null) {
      _loadNotifications();
      _subscribeToRealtime();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await SupabaseService.instance.client
          .from('notifications')
          .select('*')
          .or('user_id.eq.$userId,target.eq.all')
          .order('created_at', ascending: false);

      final List<NotificationModel> notifs = (data as List).map((json) => NotificationModel.fromJson(json)).toList();
      state = AsyncValue.data(notifs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _subscribeToRealtime() {
    _subscription = SupabaseService.instance.client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            _loadNotifications();
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      
      if (state.hasValue) {
        final current = state.value!;
        final updated = current.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id, title: n.title, body: n.body, target: n.target, 
              userId: n.userId, isRead: true, notificationType: n.notificationType, createdAt: n.createdAt
            );
          }
          return n;
        }).toList();
        state = AsyncValue.data(updated);
      }
    } catch (e) {
      debugPrint('Failed to mark as read: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
