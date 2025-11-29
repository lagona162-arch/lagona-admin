class LoadingStationModel {
  final String id;
  final String name;
  final String? lscode;
  final String? businessHubId;
  final String? bhcode;
  final double balance;
  final DateTime createdAt;
  
  // User info
  final String? fullName;
  final String? email;
  final String? phone;
  final bool? isActive;
  final String? businessHubName;

  LoadingStationModel({
    required this.id,
    required this.name,
    this.lscode,
    this.businessHubId,
    this.bhcode,
    required this.balance,
    required this.createdAt,
    this.fullName,
    this.email,
    this.phone,
    this.isActive,
    this.businessHubName,
  });

  factory LoadingStationModel.fromJson(Map<String, dynamic> json) {
    return LoadingStationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lscode: json['ls_code'] as String? ?? json['lscode'] as String?,
      businessHubId: json['business_hub_id'] as String?,
      bhcode: json['bh_code'] as String? ?? json['bhcode'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool?,
      businessHubName: json['business_hub_name'] as String?,
    );
  }
}

