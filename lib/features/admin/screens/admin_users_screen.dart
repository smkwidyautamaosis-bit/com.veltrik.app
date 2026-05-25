import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';

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
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentBlue), 
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
                final dateStr = expiresAt != null ? "${expiresAt.day}/${expiresAt.month}/${expiresAt.year}" : 'No Expiry';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.bgElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.bgPrimary,
                          child: Icon(Icons.person, color: AppColors.accentBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(user['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                  _buildBadge(user['status'] ?? 'inactive', expiresAt),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${user['invite_code'] ?? 'No Code'} • $dateStr', style: const TextStyle(color: AppColors.textSecond, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Device: ${user['device_name'] ?? 'Unbound'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                user['status'] == 'active' ? Icons.block : Icons.check_circle_outline,
                                color: user['status'] == 'active' ? AppColors.danger : AppColors.success,
                              ),
                              onPressed: () => _toggleStatus(user['id'], user['status'] ?? 'inactive'),
                              tooltip: user['status'] == 'active' ? 'Deactivate User' : 'Activate User',
                            ),
                            if (user['device_id'] != null)
                              IconButton(
                                icon: const Icon(Icons.phonelink_erase, color: AppColors.warning),
                                onPressed: () => _resetDevice(user['id']),
                                tooltip: 'Reset Device Binding',
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
