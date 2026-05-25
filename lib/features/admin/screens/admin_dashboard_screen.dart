import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: AppColors.bgElevated,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.accentBlue),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/splash'),
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard(context, 'Users', Icons.people, '/admin/users'),
          _buildCard(context, 'Content', Icons.picture_as_pdf, '/admin/content'),
          _buildCard(context, 'Notifications', Icons.campaign, '/admin/notifications'),
          _buildCard(context, 'Creator Profile', Icons.person_pin, '/admin/creator'),
        ],
      ),
    );
  }
}
