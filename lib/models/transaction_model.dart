class TransactionModel {
  final String id;
  final String? deliveryId;
  final String? payerId;
  final String? payeeId;
  final double amount;
  final String? description;
  final DateTime createdAt;
  
  // Additional info from joins
  final String? payerName;
  final String? payeeName;

  TransactionModel({
    required this.id,
    this.deliveryId,
    this.payerId,
    this.payeeId,
    required this.amount,
    this.description,
    required this.createdAt,
    this.payerName,
    this.payeeName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      deliveryId: json['delivery_id'] as String?,
      payerId: json['payer_id'] as String?,
      payeeId: json['payee_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      payerName: json['payer_name'] as String?,
      payeeName: json['payee_name'] as String?,
    );
  }
}

