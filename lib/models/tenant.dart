/// Modelo de Tenant (cliente) del sistema.
class Tenant {
  final String id;
  final String tenantId;
  final String name;
  final String? contactEmail;
  final bool isActive;
  final DateTime? createdAt;

  Tenant({
    required this.id,
    required this.tenantId,
    required this.name,
    this.contactEmail,
    this.isActive = true,
    this.createdAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'] as String? ?? '',
        tenantId: json['tenantId'] as String? ?? '',
        name: json['name'] as String? ?? json['displayName'] as String? ?? '',
        contactEmail: json['contactEmail'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'contactEmail': contactEmail,
        'isActive': isActive,
      };
}
