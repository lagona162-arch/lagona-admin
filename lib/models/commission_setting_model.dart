class CommissionSettingModel {
  final String id;
  final String role;
  final double percentage;
  final DateTime createdAt;

  CommissionSettingModel({
    required this.id,
    required this.role,
    required this.percentage,
    required this.createdAt,
  });

  factory CommissionSettingModel.fromJson(Map<String, dynamic> json) {
    return CommissionSettingModel(
      id: json['id'] as String,
      role: json['role'] as String,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'percentage': percentage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

