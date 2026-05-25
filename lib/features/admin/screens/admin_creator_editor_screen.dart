import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/supabase_service.dart';
import '../../../app/theme/app_colors.dart';

class AdminCreatorEditorScreen extends StatefulWidget {
  const AdminCreatorEditorScreen({super.key});

  @override
  State<AdminCreatorEditorScreen> createState() => _AdminCreatorEditorScreenState();
}

class _AdminCreatorEditorScreenState extends State<AdminCreatorEditorScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _instagramController = TextEditingController();
  final _telegramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _twitterController = TextEditingController();
  
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
          _instagramController.text = data['instagram_url'] ?? '';
          _telegramController.text = data['telegram_url'] ?? '';
          _tiktokController.text = data['tiktok_url'] ?? '';
          _twitterController.text = data['twitter_url'] ?? '';
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
      'instagram_url': _instagramController.text.isEmpty ? null : _instagramController.text,
      'telegram_url': _telegramController.text.isEmpty ? null : _telegramController.text,
      'tiktok_url': _tiktokController.text.isEmpty ? null : _tiktokController.text,
      'twitter_url': _twitterController.text.isEmpty ? null : _twitterController.text,
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
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Edit Creator Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.bgElevated,
                      backgroundImage: _photoUrlController.text.isNotEmpty
                          ? CachedNetworkImageProvider(_photoUrlController.text)
                          : null,
                      child: _photoUrlController.text.isEmpty
                          ? const Icon(Icons.person, size: 60, color: AppColors.textMuted)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController, 
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController, 
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _photoUrlController, 
                    decoration: InputDecoration(
                      labelText: 'Photo URL',
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 32),
                  const Text('Social Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _instagramController, 
                    decoration: InputDecoration(
                      labelText: 'Instagram URL',
                      prefixIcon: const Icon(Icons.link, color: AppColors.textSecond),
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tiktokController, 
                    decoration: InputDecoration(
                      labelText: 'TikTok URL',
                      prefixIcon: const Icon(Icons.link, color: AppColors.textSecond),
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _twitterController, 
                    decoration: InputDecoration(
                      labelText: 'Twitter/X URL',
                      prefixIcon: const Icon(Icons.link, color: AppColors.textSecond),
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telegramController, 
                    decoration: InputDecoration(
                      labelText: 'Telegram URL',
                      prefixIcon: const Icon(Icons.link, color: AppColors.textSecond),
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    )
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _save,
                      child: const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }
}
