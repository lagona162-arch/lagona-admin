class RiderModel {
  final String id;
  final String? loadingStationId;
  final String? plateNumber;
  final String? vehicleType;
  final double balance;
  final double commissionRate;
  final String status;
  final String? currentAddress;
  final double? latitude;
  final double? longitude;
  final DateTime? lastActive;
  final DateTime createdAt;
  final String? licenseCardUrl;
  final String? profilePictureUrl;
  final String? driversLicenseUrl;
  final String? officialReceiptUrl;
  final String? certificateOfRegistrationUrl;
  final String? vehicleFrontPictureUrl;
  final String? vehicleSidePictureUrl;
  final String? vehicleBackPictureUrl;
  final String? accessStatus;
  
  // User info
  final String? fullName;
  final String? email;
  final String? phone;
  final bool? isActive;

  RiderModel({
    required this.id,
    this.loadingStationId,
    this.plateNumber,
    this.vehicleType,
    required this.balance,
    required this.commissionRate,
    required this.status,
    this.currentAddress,
    this.latitude,
    this.longitude,
    this.lastActive,
    required this.createdAt,
    this.licenseCardUrl,
    this.profilePictureUrl,
    this.driversLicenseUrl,
    this.officialReceiptUrl,
    this.certificateOfRegistrationUrl,
    this.vehicleFrontPictureUrl,
    this.vehicleSidePictureUrl,
    this.vehicleBackPictureUrl,
    this.accessStatus,
    this.fullName,
    this.email,
    this.phone,
    this.isActive,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] as String,
      loadingStationId: json['loading_station_id'] as String?,
      plateNumber: json['plate_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'available',
      currentAddress: json['current_address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      lastActive: json['last_active'] != null 
          ? DateTime.parse(json['last_active'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      licenseCardUrl: json['license_card_url'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      driversLicenseUrl: json['drivers_license_url'] as String?,
      officialReceiptUrl: json['official_receipt_url'] as String?,
      certificateOfRegistrationUrl: json['certificate_of_registration_url'] as String?,
      vehicleFrontPictureUrl: json['vehicle_front_picture_url'] as String?,
      vehicleSidePictureUrl: json['vehicle_side_picture_url'] as String?,
      vehicleBackPictureUrl: json['vehicle_back_picture_url'] as String?,
      accessStatus: json['access_status'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }
}

