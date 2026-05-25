class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String target;
  final String? userId;
  final bool isRead;
  final String notificationType;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    this.userId,
    required this.isRead,
    required this.notificationType,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      target: json['target'] as String? ?? 'all',
      userId: json['user_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      notificationType: json['notification_type'] as String? ?? 'announcement',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
