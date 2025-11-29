class BusinessHubModel {
  final String id;
  final String name;
  final String? bhcode;
  final double balance;
  final DateTime createdAt;
  
  // User info
  final String? fullName;
  final String? email;
  final String? phone;
  final bool? isActive;

  BusinessHubModel({
    required this.id,
    required this.name,
    this.bhcode,
    required this.balance,
    required this.createdAt,
    this.fullName,
    this.email,
    this.phone,
    this.isActive,
  });

  factory BusinessHubModel.fromJson(Map<String, dynamic> json) {
    return BusinessHubModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bhcode: json['bh_code'] as String? ?? json['bhcode'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }
}

