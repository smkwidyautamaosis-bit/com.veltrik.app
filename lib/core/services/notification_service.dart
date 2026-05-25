import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Handle messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });

    // 4. Handle notification tap when app is in background but running
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _navigateToUpdates();
    });

    // 5. Handle notification tap when app is completely terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      // Delay navigation slightly to let router initialize
      Future.delayed(const Duration(milliseconds: 2000), () {
        _navigateToUpdates();
      });
    }

    // Generate token
    await fetchAndSaveToken();

    // Listen to token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
      _saveTokenToSupabase(newToken);
    });
  }

  Future<void> fetchAndSaveToken({String? userId}) async {
    String? token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
    
    if (token != null) {
      await _saveTokenToSupabase(token, userId: userId);
    }
  }

  Future<void> _saveTokenToSupabase(String token, {String? userId}) async {
    final targetUserId = userId ?? SupabaseService.instance.client.auth.currentUser?.id;
    if (targetUserId != null) {
      try {
        await SupabaseService.instance.client
            .from('users')
            .update({'fcm_token': token})
            .eq('id', targetUserId);
        debugPrint('FCM Token successfully saved to Supabase users table for user $targetUserId.');
      } catch (e) {
        debugPrint('Failed to save FCM Token to Supabase: $e');
      }
    } else {
      debugPrint('Skipping FCM token save: No user is currently logged in.');
    }
  }

  void _navigateToUpdates() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('/app/updates');
    }
  }
}
