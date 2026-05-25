import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    debugPrint('Splash: _initAuth started');
    // 1.5 second artificial delay for the splash animation
    await Future.delayed(const Duration(milliseconds: 1500));
    debugPrint('Splash: Artificial delay finished');

    // Check if token exists first to avoid unnecessary Edge Function calls
    debugPrint('Splash: Checking secure storage for token');
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: AppConstants.sessionTokenKey);
    debugPrint('Splash: Token read result: ${token != null ? "Found" : "Null or Empty"}');
    
    if (token == null || token.isEmpty) {
      debugPrint('Splash: No token, preparing redirect to /login');
      if (mounted) {
        debugPrint('Splash: context is mounted, calling context.go(/login)');
        context.go('/login');
      } else {
        debugPrint('Splash: context unmounted, skipping redirect');
      }
      return;
    }

    // Validate session with a 5-second timeout
    debugPrint('Splash: Token exists, validating session...');
    try {
      await ref.read(authProvider.notifier).validateSession().timeout(const Duration(seconds: 5));
      debugPrint('Splash: Session validation completed');
    } catch (e) {
      debugPrint('Splash: Session validation timeout or error: $e');
    }
    
    final authState = ref.read(authProvider);
    debugPrint('Splash: Current auth status: ${authState.status}');

    if (mounted) {
      if (authState.status == AuthStatus.authenticated && authState.user != null) {
        debugPrint('Splash: Authenticated, fetching FCM token in background...');
        // Do not await this so we don't delay the redirect
        NotificationService.instance.fetchAndSaveToken(userId: authState.user!.id);
        
        debugPrint('Splash: Redirecting to /app/library');
        context.go('/app/library');
      } else {
        debugPrint('Splash: Unauthenticated or Error, redirecting to /login');
        context.go('/login');
      }
    } else {
      debugPrint('Splash: mounted check failed before final redirect');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
