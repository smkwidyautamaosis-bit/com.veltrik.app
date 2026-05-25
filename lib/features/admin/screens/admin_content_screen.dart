import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  List<dynamic> _docs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDocs();
  }

  Future<void> _fetchDocs() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.instance.client
          .from('documents')
          .select('*')
          .order('created_at', ascending: false);
      setState(() {
        _docs = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleActive(String id, bool currentStatus) async {
    try {
      await SupabaseService.instance.client
          .from('documents')
          .update({'is_active': !currentStatus})
          .eq('id', id);
      _fetchDocs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Content'),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file), onPressed: () => context.push('/admin/content/upload').then((_) => _fetchDocs())),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _docs.length,
              itemBuilder: (context, index) {
                final doc = _docs[index];
                final isActive = doc['is_active'] == true;
                return ListTile(
                  title: Text(doc['title']),
                  subtitle: Text(doc['file_path']),
                  trailing: Switch(
                    value: isActive,
                    onChanged: (val) => _toggleActive(doc['id'], isActive),
                    activeThumbColor: AppColors.accentBlue,
                  ),
                );
              },
            ),
    );
  }
}
