/// Modelo de Kiosco.
class Kiosk {
  final String id;
  final String tenantId;
  final String name;
  final String branchName;
  final String surveyCode;
  final String kioskToken;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;

  Kiosk({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.branchName,
    required this.surveyCode,
    required this.kioskToken,
    required this.isActive,
    this.createdAt,
    this.lastSeenAt,
  });

  factory Kiosk.fromJson(Map<String, dynamic> json) => Kiosk(
        id: json['id'] as String? ?? '',
        tenantId: json['tenantId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        branchName: json['branchName'] as String? ?? '',
        surveyCode: json['surveyCode'] as String? ?? '',
        kioskToken: json['kioskToken'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        lastSeenAt: DateTime.tryParse(json['lastSeenAt'] as String? ?? ''),
      );

  bool get isOnline {
    if (lastSeenAt == null) return false;
    return DateTime.now().difference(lastSeenAt!).inMinutes < 10;
  }
}

/// Modelo de respuesta al crear un kiosco (incluye el token).
class CreateKioskResult {
  final Kiosk kiosk;
  final String kioskToken;
  final String message;

  CreateKioskResult({
    required this.kiosk,
    required this.kioskToken,
    required this.message,
  });

  factory CreateKioskResult.fromJson(Map<String, dynamic> json) =>
      CreateKioskResult(
        kiosk: Kiosk.fromJson(json['kiosk'] as Map<String, dynamic>? ?? {}),
        kioskToken: json['kioskToken'] as String? ?? '',
        message: json['message'] as String? ?? '',
      );
}
