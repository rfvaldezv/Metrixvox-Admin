class AdminUser {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        role: json['role'] as String? ?? 'Viewer',
        isActive: json['isActive'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
      );

  String get roleLabel {
    switch (role) {
      case 'SuperAdmin':
        return 'Super Administrador';
      case 'TenantAdmin':
        return 'Administrador';
      case 'Analyst':
        return 'Analista';
      case 'Viewer':
        return 'Visualizador';
      default:
        return role;
    }
  }
}
