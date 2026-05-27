import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../features/updates/providers/notifications_provider.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/app/library')) return 0;
    if (location.startsWith('/app/updates')) return 1;
    if (location.startsWith('/app/security')) return 2;
    if (location.startsWith('/app/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/app/library');
        break;
      case 1:
        GoRouter.of(context).go('/app/updates');
        break;
      case 2:
        GoRouter.of(context).go('/app/security');
        break;
      case 3:
        GoRouter.of(context).go('/app/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final notifsAsync = ref.watch(notificationsProvider);
    int unreadCount = 0;
    
    if (notifsAsync.hasValue) {
      unreadCount = notifsAsync.value!.where((n) => !n.isRead).length;
    }

    return Scaffold(
      backgroundColor: AppColors.bgSurface, // Keep scaffold background
      extendBody: true, // Allows body content to flow behind the floating navbar
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary, // Veltrik white bar
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Now we have 4 tabs
              final tabWidth = constraints.maxWidth / 4;
              final double activeCenter = (currentIndex * tabWidth) + (tabWidth / 2);
              
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Animated Bulge (Convex effect)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    top: -24, // Float outside the top edge
                    left: activeCenter - 32, // 32 is half of the 64 width
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.bgPrimary, // Bulge matches navbar background
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        // Inner Blue Gradient Bubble
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentRoyal, AppColors.accentBlue],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Icons Row
                  Row(
                    children: [
                      _buildTabItem(0, Icons.my_library_books_rounded, currentIndex, context, 0),
                      _buildTabItem(1, Icons.notifications_rounded, currentIndex, context, unreadCount),
                      _buildTabItem(2, Icons.security_rounded, currentIndex, context, 0),
                      _buildTabItem(3, Icons.person_rounded, currentIndex, context, 0),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, int currentIndex, BuildContext context, int badgeCount) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          // Move the icon up when active to perfectly center it inside the floating blue bubble
          transform: Matrix4.translationValues(0, isActive ? -24 : 0, 0),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  // White icon inside blue bubble when active, muted slate when inactive
                  color: isActive ? Colors.white : AppColors.textMuted,
                  size: isActive ? 26 : 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
