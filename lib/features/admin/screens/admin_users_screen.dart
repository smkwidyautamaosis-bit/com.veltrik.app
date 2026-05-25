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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/admin/users/create').then((_) => _fetchUsers())),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['full_name'] ?? 'Unknown'),
                  subtitle: Text('${user['invite_code'] ?? 'No Code'}\nDevice: ${user['device_name'] ?? 'Unbound'}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.phonelink_erase, color: AppColors.warning),
                    onPressed: () => _resetDevice(user['id']),
                    tooltip: 'Reset Device Binding',
                  ),
                );
              },
            ),
    );
  }
}
