import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/supabase_service.dart';
import '../../../app/widgets/geometric_background.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _totalDocs = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final usersRes = await SupabaseService.instance.client.from('users').select('status');
      final docsRes = await SupabaseService.instance.client.from('documents').select('id');
      
      int active = 0;
      for (var u in usersRes) {
        if (u['status'] == 'active') active++;
      }
      
      if (mounted) {
        setState(() {
          _totalUsers = usersRes.length;
          _activeUsers = active;
          _totalDocs = docsRes.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: AppColors.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.2), blurRadius: 12)
                ]
              ),
              child: Icon(icon, size: 40, color: AppColors.accentBlue),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.h1),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textSecond)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.danger),
            onPressed: () => context.go('/splash'),
          )
        ],
      ),
      body: GeometricBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('Overview', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard('Total Users', '$_totalUsers', Icons.people_alt, AppColors.accentBlue),
                      const SizedBox(width: 16),
                      _buildStatCard('Active Users', '$_activeUsers', Icons.verified_user, AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard('Total Documents', '$_totalDocs', Icons.picture_as_pdf, AppColors.warning),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()), // Placeholder for layout balance
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Management', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildCard(context, 'Users', Icons.people, '/admin/users'),
                      _buildCard(context, 'Content', Icons.my_library_books, '/admin/content'),
                      _buildCard(context, 'Notifications', Icons.campaign, '/admin/notifications'),
                      _buildCard(context, 'Creator Profile', Icons.person_pin, '/admin/creator'),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
