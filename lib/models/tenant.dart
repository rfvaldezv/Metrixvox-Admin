/// Modelo de Tenant (cliente) del sistema.
class Tenant {
  final String tenantId;
  final String name;

  Tenant({
    required this.tenantId,
    required this.name,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        tenantId: json['tenantId'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'name': name,
      };
}
