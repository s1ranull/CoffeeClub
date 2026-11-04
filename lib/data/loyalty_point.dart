class LoyaltyPoint {
  final int id;
  final int userId;
  final int? orderId;
  final int points;
  final String description;
  final String earnedAt;

  const LoyaltyPoint({
    required this.id,
    required this.userId,
    this.orderId,
    required this.points,
    required this.description,
    required this.earnedAt,
  });

  LoyaltyPoint copyWith({int? id, int? userId, int? orderId,
      int? points, String? description, String? earnedAt}) => LoyaltyPoint(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        orderId: orderId ?? this.orderId,
        points: points ?? this.points,
        description: description ?? this.description,
        earnedAt: earnedAt ?? this.earnedAt,
      );
}
