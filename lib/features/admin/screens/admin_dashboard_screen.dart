import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';

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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecond),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, String route, Color color) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Panel', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            Text('Dashboard', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.danger),
            onPressed: () => context.go('/splash'),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats Row
                Text('Overview', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('Total Users', '$_totalUsers', Icons.people_alt_outlined, AppColors.accentBlue),
                    const SizedBox(width: 12),
                    _buildStatCard('Active Users', '$_activeUsers', Icons.verified_user_outlined, AppColors.success),
                    const SizedBox(width: 12),
                    _buildStatCard('Documents', '$_totalDocs', Icons.picture_as_pdf_outlined, AppColors.warning),
                  ],
                ),

                const SizedBox(height: 28),

                // Management Grid
                Text('Management', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(context, 'Analytics', 'Statistik pembacaan', Icons.insights_rounded, '/admin/analytics', const Color(0xFFEAB308)),
                    _buildMenuCard(context, 'Users', 'Kelola akun member', Icons.people_rounded, '/admin/users', AppColors.accentBlue),
                    _buildMenuCard(context, 'Konten', 'Upload & atur dokumen', Icons.my_library_books_rounded, '/admin/content', AppColors.success),
                    _buildMenuCard(context, 'Notifikasi', 'Kirim pengumuman', Icons.campaign_rounded, '/admin/notifications', AppColors.warning),
                    _buildMenuCard(context, 'Banner', 'Kelola banner carousel', Icons.view_carousel_rounded, '/admin/banners', const Color(0xFF8B5CF6)),
                    _buildMenuCard(context, 'Creator', 'Edit profil kreator', Icons.person_pin_rounded, '/admin/creator', const Color(0xFFEC4899)),
                    _buildMenuCard(context, 'Tambah User', 'Buat akun member baru', Icons.person_add_rounded, '/admin/create-user', AppColors.info),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
