class BannerModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int order;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.order,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'order': order,
    };
  }
}
