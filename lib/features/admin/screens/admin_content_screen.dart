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
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Manage Content'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: AppColors.accentBlue), 
            onPressed: () => context.push('/admin/content/upload').then((_) => _fetchDocs())
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _docs.length,
              itemBuilder: (context, index) {
                final doc = _docs[index];
                final isActive = doc['is_active'] == true;
                final createdAt = doc['created_at'] != null ? DateTime.tryParse(doc['created_at']) : null;
                final dateStr = createdAt != null ? "${createdAt.day}/${createdAt.month}/${createdAt.year}" : '';
                final sizeKb = doc['file_size_kb'];
                final sizeStr = sizeKb != null ? "${(sizeKb / 1024).toStringAsFixed(2)} MB" : '';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.bgElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: AppColors.accentBlue),
                    ),
                    title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(doc['file_path'], style: const TextStyle(color: AppColors.textSecond, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (dateStr.isNotEmpty) ...[
                              const Icon(Icons.calendar_today, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              const SizedBox(width: 12),
                            ],
                            if (sizeStr.isNotEmpty) ...[
                              const Icon(Icons.storage, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(sizeStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: Switch(
                      value: isActive,
                      onChanged: (val) => _toggleActive(doc['id'], isActive),
                      activeThumbColor: AppColors.success,
                      inactiveThumbColor: AppColors.textMuted,
                      inactiveTrackColor: AppColors.bgPrimary,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
