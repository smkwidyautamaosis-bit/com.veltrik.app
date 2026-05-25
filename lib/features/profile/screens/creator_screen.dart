import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/creator_provider.dart';

class CreatorScreen extends ConsumerWidget {
  const CreatorScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorAsync = ref.watch(creatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Kreator'),
      ),
      body: creatorAsync.when(
        data: (creator) {
          if (creator == null) {
            return const Center(child: Text('Profil kreator belum diatur.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (creator.photoUrl != null && creator.photoUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: CachedNetworkImageProvider(creator.photoUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.bgElevated,
                    child: Icon(Icons.person, size: 60, color: AppColors.textMuted),
                  ),
                const SizedBox(height: 24),
                Text(creator.name, style: AppTextStyles.h1),
                const SizedBox(height: 16),
                if (creator.bio != null)
                  Text(
                    creator.bio!,
                    style: AppTextStyles.bodyRegular,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 32),
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: 16),
                const Text('Ikuti Saya:', style: AppTextStyles.bodyEmphasis),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: creator.links.map((linkData) {
                    final platform = linkData['platform'] ?? 'Link';
                    final url = linkData['url'] ?? '';
                    IconData icon = Icons.link;
                    
                    if (platform.toString().toLowerCase().contains('instagram')) icon = Icons.camera_alt;
                    if (platform.toString().toLowerCase().contains('tiktok')) icon = Icons.music_note;
                    if (platform.toString().toLowerCase().contains('twitter') || platform.toString().toLowerCase().contains('x')) icon = Icons.flutter_dash;
                    if (platform.toString().toLowerCase().contains('telegram')) icon = Icons.send;

                    return IconButton(
                      icon: Icon(icon, color: AppColors.accentBlue),
                      iconSize: 32,
                      onPressed: () => _launchUrl(url),
                      tooltip: platform,
                    );
                  }).toList(),
                )
              ],
            ),
          );
        },
        loading: () => Center(
          child: Shimmer.fromColors(
            baseColor: AppColors.bgCard,
            highlightColor: AppColors.bgElevated,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(height: 24),
                Container(width: 200, height: 24, color: Colors.white),
                const SizedBox(height: 16),
                Container(width: 300, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 280, height: 16, color: Colors.white),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
