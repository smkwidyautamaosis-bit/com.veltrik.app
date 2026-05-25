import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/documents_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final docsAsyncValue = ref.watch(documentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari dokumen...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: docsAsyncValue.when(
        data: (docs) {
          final filteredDocs = docs.where((d) => d.title.toLowerCase().contains(_searchQuery)).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 80, color: AppColors.borderLight),
                  const SizedBox(height: 16),
                  Text('Belum ada dokumen tersedia', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecond)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final isNew = DateTime.now().difference(doc.createdAt).inDays < 3;
              final dateStr = DateFormat('dd MMM yyyy').format(doc.createdAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.push('/pdf-viewer/${doc.id}', extra: doc.title);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: doc.thumbnailUrl != null && doc.thumbnailUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: doc.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: AppColors.bgElevated,
                                      highlightColor: AppColors.borderLight,
                                      child: Container(color: Colors.white),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.picture_as_pdf, color: AppColors.textMuted),
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf, size: 40, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isNew)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text('New', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  Expanded(
                                    child: Text(
                                      doc.title,
                                      style: AppTextStyles.bodyEmphasis.copyWith(fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (doc.description != null)
                                Text(
                                  doc.description!,
                                  style: AppTextStyles.caption,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 8),
                              Text(dateStr, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: AppColors.bgCard,
            highlightColor: AppColors.bgElevated,
            child: Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.bodyRegular.copyWith(color: AppColors.danger))),
      ),
    );
  }
}
