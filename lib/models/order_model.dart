class OrderModel {
  final String? id;
  final String type; // Pakaian / Sepatu
  final String service; // Cuci Kering, dll
  final String pickupMethod;
  final String status;
  final double price;
  final DateTime? createdAt;

  OrderModel({
    this.id,
    required this.type,
    required this.service,
    required this.pickupMethod,
    required this.status,
    required this.price,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'service': service,
      'pickup_method': pickupMethod,
      'status': status,
      'total_price': price,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      type: json['type'] ?? '',
      service: json['service'] ?? '',
      pickupMethod: json['pickup_method'] ?? '',
      status: json['status'] ?? 'Pending',
      price: (json['total_price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}