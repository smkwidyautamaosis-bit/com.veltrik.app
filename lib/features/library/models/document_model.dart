class DocumentModel {
  final String id;
  final String title;
  final String? description;
  final String filePath;
  final String? thumbnailUrl;
  final String category;
  final bool isActive;
  final String accessType;
  final int? pageCount;
  final int? fileSizeKb;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    this.description,
    required this.filePath,
    this.thumbnailUrl,
    required this.category,
    required this.isActive,
    required this.accessType,
    this.pageCount,
    this.fileSizeKb,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      filePath: json['file_path'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: json['category'] as String? ?? 'general',
      isActive: json['is_active'] as bool? ?? true,
      accessType: json['access_type'] as String? ?? 'all',
      pageCount: json['page_count'] as int?,
      fileSizeKb: json['file_size_kb'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
