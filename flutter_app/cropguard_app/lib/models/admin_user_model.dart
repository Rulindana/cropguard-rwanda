class AdminUserModel {
  final String id;
  final String email;
  final String name;
  final String role; // admin | editor | viewer
  final bool isActive;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';
  bool get isEditor => role == 'editor' || role == 'admin';

  factory AdminUserModel.fromMap(Map<String, dynamic> d) => AdminUserModel(
    id: d['id'] ?? '',
    email: d['email'] ?? '',
    name: d['name'] ?? '',
    role: d['role'] ?? 'viewer',
    isActive: d['isActive'] ?? true,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'email': email, 'name': name,
    'role': role, 'isActive': isActive,
  };

  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
