import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';

class AdminCreatorEditorScreen extends StatefulWidget {
  const AdminCreatorEditorScreen({super.key});

  @override
  State<AdminCreatorEditorScreen> createState() => _AdminCreatorEditorScreenState();
}

class _AdminCreatorEditorScreenState extends State<AdminCreatorEditorScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _isLoading = true;
  String? _id;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await SupabaseService.instance.client
          .from('creator_profile')
          .select('*')
          .limit(1)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _id = data['id'];
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _photoUrlController.text = data['photo_url'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final payload = {
      'name': _nameController.text,
      'bio': _bioController.text,
      'photo_url': _photoUrlController.text,
    };
    
    try {
      if (_id != null) {
        await SupabaseService.instance.client.from('creator_profile').update(payload).eq('id', _id!);
      } else {
        await SupabaseService.instance.client.from('creator_profile').insert(payload);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Creator Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 16),
                  TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 4),
                  const SizedBox(height: 16),
                  TextField(controller: _photoUrlController, decoration: const InputDecoration(labelText: 'Photo URL')),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
