class Order {
  final int id;
  final int userId;
  final String items;
  final double total;
  final String status;
  final String createdAt;
  final String customerName;
  final String phone;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.customerName = '',
    this.phone = '',
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int,
    userId: json['userId'] as int,
    items: json['items'] as String,
    total: (json['total'] as num).toDouble(),
    status: json['status'] as String,
    createdAt: json['createdAt'] as String,
    customerName: json['customerName'] as String,
    phone: json['phone'] as String,
  );

  Map<String, dynamic> toJson() => {
    'items': items,
    'total': total,
    'status': status,
    'customerName': customerName,
    'phone': phone,
  };

  Order copyWith({int? id, int? userId, String? items, double? total,
      String? status, String? createdAt, String? customerName, String? phone}) =>
      Order(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        items: items ?? this.items,
        total: total ?? this.total,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        customerName: customerName ?? this.customerName,
        phone: phone ?? this.phone,
      );
}
