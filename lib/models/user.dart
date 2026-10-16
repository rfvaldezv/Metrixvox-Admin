/// Modelo de usuario del sistema.
class User {
  final String id;
  final String email;
  final String fullName;
  final String tenantId;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.tenantId,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        tenantId: json['tenantId'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'tenantId': tenantId,
        'role': role,
      };

  bool get isSuperAdmin => role == 'SuperAdmin';
  bool get isTenantAdmin => role == 'TenantAdmin';
  bool get isAnalyst => role == 'Analyst';
  bool get isViewer => role == 'Viewer';

  /// ¿Puede crear/editar kioscos?
  bool get canManageKiosks => isSuperAdmin || isTenantAdmin;

  /// ¿Puede ver dashboard?
  bool get canViewDashboard => true;

  /// ¿Puede ver respuestas?
  bool get canViewResponses => true;

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
