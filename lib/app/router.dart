import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/first_login_notice_screen.dart';
import '../features/auth/providers/auth_provider.dart';

import '../features/library/screens/library_screen.dart';
import '../features/library/screens/pdf_viewer_screen.dart';
import '../features/updates/screens/updates_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/creator_screen.dart';

import '../features/admin/screens/admin_login_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_create_user_screen.dart';
import '../features/admin/screens/admin_content_screen.dart';
import '../features/admin/screens/admin_upload_pdf_screen.dart';
import '../features/admin/screens/admin_notifications_screen.dart';
import '../features/admin/screens/admin_creator_editor_screen.dart';
import '../features/admin/screens/admin_banners_screen.dart';

import 'widgets/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isGoingToAuth = loc == '/login' || loc == '/splash' || loc.startsWith('/admin');
      
      if (authState.status == AuthStatus.unauthenticated && !isGoingToAuth) {
        return '/login';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/first-notice',
        builder: (context, state) => const FirstLoginNoticeScreen(),
      ),
      GoRoute(
        path: '/creator',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreatorScreen(),
      ),
      GoRoute(
        path: '/pdf-viewer/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final title = state.extra as String? ?? 'Dokumen';
          return PdfViewerScreen(documentId: id, title: title);
        },
      ),
      // Admin Routes
      GoRoute(
        path: '/admin/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/users/create',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminCreateUserScreen(),
      ),
      GoRoute(
        path: '/admin/content',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminContentScreen(),
      ),
      GoRoute(
        path: '/admin/content/upload',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminUploadPdfScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/creator',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminCreatorEditorScreen(),
      ),
      GoRoute(
        path: '/admin/banners',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminBannersScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/app/library',
            pageBuilder: (context, state) => const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: '/app/updates',
            pageBuilder: (context, state) => const NoTransitionPage(child: UpdatesScreen()),
          ),
          GoRoute(
            path: '/app/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});
