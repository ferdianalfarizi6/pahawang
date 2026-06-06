class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatar;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.fullName,
    this.phone,
    this.avatar,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firebaseUid: json['firebase_uid'] ?? json['firebaseUid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'],
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
