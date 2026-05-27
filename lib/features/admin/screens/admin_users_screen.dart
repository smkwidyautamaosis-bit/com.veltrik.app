import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_utils.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.instance.client
          .from('users')
          .select('*')
          .order('expires_at', ascending: false);
      setState(() {
        _users = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error fetching users: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _resetDevice(String id) async {
    try {
      await SupabaseService.instance.client
          .from('users')
          .update({'device_id': null, 'device_name': null})
          .eq('id', id);
      _fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device reset successfully')));
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error resetting device: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleStatus(String id, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
      await SupabaseService.instance.client
          .from('users')
          .update({'status': newStatus})
          .eq('id', id);
      _fetchUsers();
    } catch (e) {
      if (mounted) {
        debugPrint('Error toggling status: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildBadge(String status, DateTime? expiresAt) {
    bool isExpired = expiresAt != null && expiresAt.isBefore(DateTime.now());
    
    String label = status.toUpperCase();
    Color bgColor = AppColors.bgElevated;
    Color textColor = AppColors.textSecond;

    if (isExpired) {
      label = 'EXPIRED';
      bgColor = AppColors.warning.withValues(alpha: 0.2);
      textColor = AppColors.warning;
    } else if (status == 'active') {
      bgColor = AppColors.success.withValues(alpha: 0.2);
      textColor = AppColors.success;
    } else {
      label = 'INACTIVE';
      bgColor = AppColors.danger.withValues(alpha: 0.2);
      textColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text('Manage Users', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.accentBlue), 
            onPressed: () => context.push('/admin/users/create').then((_) => _fetchUsers())
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final expiresAt = user['expires_at'] != null ? DateTime.tryParse(user['expires_at']) : null;
                final dateStr = expiresAt != null ? AppDateUtils.toWIBDateOnly(expiresAt) : 'No Expiry';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.accentBlue.withValues(alpha: 0.1),
                          child: const Icon(Icons.person_rounded, color: AppColors.accentBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(user['full_name'] ?? 'Unknown', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary))),
                                  _buildBadge(user['status'] ?? 'inactive', expiresAt),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('${user['invite_code'] ?? 'No Code'} • $dateStr', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecond, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('Device: ${user['device_name'] ?? 'Unbound'}', style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                user['status'] == 'active' ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                                color: user['status'] == 'active' ? AppColors.danger : AppColors.success,
                              ),
                              onPressed: () => _toggleStatus(user['id'], user['status'] ?? 'inactive'),
                              tooltip: user['status'] == 'active' ? 'Nonaktifkan' : 'Aktifkan',
                            ),
                            if (user['device_id'] != null)
                              IconButton(
                                icon: const Icon(Icons.phonelink_erase_rounded, color: AppColors.warning),
                                onPressed: () => _resetDevice(user['id']),
                                tooltip: 'Reset Device',
                              ),
                            // Veltrik Pass button
                            IconButton(
                              icon: const Icon(Icons.credit_card_rounded, color: Color(0xFF2563EB)),
                              tooltip: 'Veltrik Pass',
                              onPressed: () {
                                context.push('/admin/veltrik-pass', extra: {
                                  'memberName': user['full_name'] ?? 'Member',
                                  'inviteCode': user['invite_code'] ?? '',
                                  'expiresAt': expiresAt != null ? AppDateUtils.toWIBDateOnly(expiresAt) : '',
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
