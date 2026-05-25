import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _send() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await SupabaseService.instance.client.functions.invoke(
        'send-notification',
        body: {
          'title': _titleController.text,
          'body': _bodyController.text,
          'target': 'all',
          'notification_type': 'announcement',
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent successfully!')));
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Broadcast Notification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextField(controller: _bodyController, decoration: const InputDecoration(labelText: 'Message Body'), maxLines: 4),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _send,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Send Broadcast'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
