class DeliveryModel {
  final String id;
  final String type;
  final String? customerId;
  final String? merchantId;
  final String? riderId;
  final String? loadingStationId;
  final String? businessHubId;
  final String? pickupAddress;
  final String? dropoffAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final double? distanceKm;
  final double? deliveryFee;
  final double? commissionRider;
  final double? commissionLoading;
  final double? commissionHub;
  final String status;
  final DateTime createdAt;
  
  // Additional info
  final String? customerName;
  final String? merchantName;
  final String? riderName;

  DeliveryModel({
    required this.id,
    required this.type,
    this.customerId,
    this.merchantId,
    this.riderId,
    this.loadingStationId,
    this.businessHubId,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.distanceKm,
    this.deliveryFee,
    this.commissionRider,
    this.commissionLoading,
    this.commissionHub,
    required this.status,
    required this.createdAt,
    this.customerName,
    this.merchantName,
    this.riderName,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as String,
      type: json['type'] as String,
      customerId: json['customer_id'] as String?,
      merchantId: json['merchant_id'] as String?,
      riderId: json['rider_id'] as String?,
      loadingStationId: json['loading_station_id'] as String?,
      businessHubId: json['business_hub_id'] as String?,
      pickupAddress: json['pickup_address'] as String?,
      dropoffAddress: json['dropoff_address'] as String?,
      pickupLatitude: json['pickup_latitude'] as double?,
      pickupLongitude: json['pickup_longitude'] as double?,
      dropoffLatitude: json['dropoff_latitude'] as double?,
      dropoffLongitude: json['dropoff_longitude'] as double?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      commissionRider: (json['commission_rider'] as num?)?.toDouble(),
      commissionLoading: (json['commission_loading'] as num?)?.toDouble(),
      commissionHub: (json['commission_hub'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      customerName: json['customer_name'] as String?,
      merchantName: json['merchant_name'] as String?,
      riderName: json['rider_name'] as String?,
    );
  }
}

