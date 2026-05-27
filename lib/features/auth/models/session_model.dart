class UserModel {
  final String id;
  final String inviteCode;
  final String fullName;
  final String? email;
  final String status;
  final String? deviceId;
  final String? deviceName;
  final DateTime expiresAt;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.inviteCode,
    required this.fullName,
    this.email,
    required this.status,
    this.deviceId,
    this.deviceName,
    required this.expiresAt,
    this.avatarUrl,
  });

  UserModel copyWith({String? avatarUrl}) {
    return UserModel(
      id: id,
      inviteCode: inviteCode,
      fullName: fullName,
      email: email,
      status: status,
      deviceId: deviceId,
      deviceName: deviceName,
      expiresAt: expiresAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      inviteCode: json['invite_code'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'active',
      deviceId: json['device_id'] as String?,
      deviceName: json['device_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : DateTime.now().add(const Duration(days: 365)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code': inviteCode,
      'full_name': fullName,
      'email': email,
      'status': status,
      'device_id': deviceId,
      'device_name': deviceName,
      'expires_at': expiresAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }
}

