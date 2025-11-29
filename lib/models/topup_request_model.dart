class TopupRequestModel {
  final String id;
  final String requestedBy;
  final String? businessHubId;
  final String? loadingStationId;
  final double requestedAmount;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? rejectionReason;
  
  // Additional info
  final String? requesterName;
  final String? businessHubName;
  final String? loadingStationName;
  final double? bonusRate;
  final double? bonusAmount;
  final double? totalCredited;

  TopupRequestModel({
    required this.id,
    required this.requestedBy,
    this.businessHubId,
    this.loadingStationId,
    required this.requestedAmount,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
    this.requesterName,
    this.businessHubName,
    this.loadingStationName,
    this.bonusRate,
    this.bonusAmount,
    this.totalCredited,
  });

  factory TopupRequestModel.fromJson(Map<String, dynamic> json) {
    return TopupRequestModel(
      id: json['id'] as String,
      requestedBy: json['requested_by'] as String,
      businessHubId: json['business_hub_id'] as String?,
      loadingStationId: json['loading_station_id'] as String?,
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'] as String) 
          : null,
      processedBy: json['processed_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      requesterName: json['requester_name'] as String?,
      businessHubName: json['business_hub_name'] as String?,
      loadingStationName: json['loading_station_name'] as String?,
      bonusRate: json['bonus_rate'] != null 
          ? (json['bonus_rate'] as num).toDouble() 
          : null,
      bonusAmount: json['bonus_amount'] != null 
          ? (json['bonus_amount'] as num).toDouble() 
          : null,
      totalCredited: json['total_credited'] != null 
          ? (json['total_credited'] as num).toDouble() 
          : null,
    );
  }
}

