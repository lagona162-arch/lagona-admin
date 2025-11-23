class MerchantModel {
  final String id;
  final String? loadingStationId;
  final String businessName;
  final String? dtiNumber;
  final String? mayorPermit;
  final String? gcashQrUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? mapPlaceId;
  final bool verified;
  final DateTime createdAt;
  final String? previewImage;
  final int? rating;
  final String? status;
  final String? slogan;
  final String accessStatus; // New field: pending, approved, rejected, suspended
  
  // User info
  final String? fullName;
  final String? email;
  final String? phone;
  final bool? isActive;
  final String? loadingStationName;

  MerchantModel({
    required this.id,
    this.loadingStationId,
    required this.businessName,
    this.dtiNumber,
    this.mayorPermit,
    this.gcashQrUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.mapPlaceId,
    required this.verified,
    required this.createdAt,
    this.previewImage,
    this.rating,
    this.status,
    this.slogan,
    required this.accessStatus,
    this.fullName,
    this.email,
    this.phone,
    this.isActive,
    this.loadingStationName,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] as String,
      loadingStationId: json['loading_station_id'] as String?,
      businessName: json['business_name'] as String,
      dtiNumber: json['dti_number'] as String?,
      mayorPermit: json['mayor_permit'] as String?,
      gcashQrUrl: json['gcash_qr_url'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      mapPlaceId: json['map_place_id'] as String?,
      verified: json['verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      previewImage: json['preview_image'] as String?,
      rating: json['rating'] as int?,
      status: json['status'] as String?,
      slogan: json['slogan'] as String?,
      accessStatus: json['access_status'] as String? ?? 'pending',
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool?,
      loadingStationName: json['loading_station_name'] as String?,
    );
  }
}

