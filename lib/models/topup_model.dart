class TopupModel {
  final String id;
  final String? initiatedBy;
  final String? loadingStationId;
  final String? businessHubId;
  final String? riderId;
  final double amount;
  final double bonusAmount;
  final double totalCredited;
  final DateTime createdAt;
  
  // Additional info
  final String? initiatorName;
  final String? recipientName;

  TopupModel({
    required this.id,
    this.initiatedBy,
    this.loadingStationId,
    this.businessHubId,
    this.riderId,
    required this.amount,
    required this.bonusAmount,
    required this.totalCredited,
    required this.createdAt,
    this.initiatorName,
    this.recipientName,
  });

  factory TopupModel.fromJson(Map<String, dynamic> json) {
    return TopupModel(
      id: json['id'] as String,
      initiatedBy: json['initiated_by'] as String?,
      loadingStationId: json['loading_station_id'] as String?,
      businessHubId: json['business_hub_id'] as String?,
      riderId: json['rider_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      bonusAmount: (json['bonus_amount'] as num?)?.toDouble() ?? 0.0,
      totalCredited: (json['total_credited'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      initiatorName: json['initiator_name'] as String?,
      recipientName: json['recipient_name'] as String?,
    );
  }
}

