class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
  });
}

class Order {
  final int id;
  final int userId;
  final String items;
  final double total;
  final String status;
  final String createdAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}

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
}

const mockProducts = [
  Product(
    id: 1,
    name: 'Cappuccino',
    price: 48,
    category: 'Кофе',
    imageUrl: '',
    description:
        'Классический эспрессо с горячим молоком и нежной молочной пеной.',
  ),
  Product(
    id: 2,
    name: 'Caramel Latte',
    price: 55,
    category: 'Кофе',
    imageUrl: '',
    description:
        'Мягкий молочный кофе с эспрессо и карамельным сиропом.',
  ),
  Product(
    id: 3,
    name: 'Espresso',
    price: 32,
    category: 'Кофе',
    imageUrl: '',
    description:
        'Насыщенный классический эспрессо из свежемолотых кофейных зёрен.',
  ),
  Product(
    id: 4,
    name: 'Americano',
    price: 38,
    category: 'Кофе',
    imageUrl: '',
    description:
        'Эспрессо с добавлением горячей воды для более мягкого вкуса.',
  ),
  Product(
    id: 5,
    name: 'Green Tea',
    price: 35,
    category: 'Чай',
    imageUrl: '',
    description:
        'Ароматный зелёный чай с мягким и освежающим вкусом.',
  ),
  Product(
    id: 6,
    name: 'Matcha Latte',
    price: 58,
    category: 'Чай',
    imageUrl: '',
    description:
        'Японская матча с горячим молоком и мягкой сливочной текстурой.',
  ),
  Product(
    id: 7,
    name: 'New York Cheesecake',
    price: 62,
    category: 'Десерты',
    imageUrl: '',
    description:
        'Классический сливочный чизкейк на хрустящей основе.',
  ),
  Product(
    id: 8,
    name: 'Chocolate Croissant',
    price: 42,
    category: 'Десерты',
    imageUrl: '',
    description:
        'Свежий хрустящий круассан с шоколадной начинкой.',
  ),
];

const mockOrders = [
  Order(
    id: 1058,
    userId: 1,
    items: 'Cappuccino, Cheesecake',
    total: 110,
    status: 'Готов',
    createdAt: '06.10.2026 · 15:40',
  ),
  Order(
    id: 1052,
    userId: 1,
    items: 'Caramel Latte, Croissant',
    total: 97,
    status: 'Готовится',
    createdAt: '05.10.2026 · 12:15',
  ),
  Order(
    id: 1047,
    userId: 1,
    items: 'Americano, Cheesecake',
    total: 100,
    status: 'Завершён',
    createdAt: '03.10.2026 · 09:20',
  ),
  Order(
    id: 1039,
    userId: 1,
    items: 'Matcha Latte',
    total: 58,
    status: 'Завершён',
    createdAt: '01.10.2026 · 14:50',
  ),
  Order(
    id: 1031,
    userId: 1,
    items: 'Espresso, Croissant',
    total: 74,
    status: 'Завершён',
    createdAt: '29.09.2026 · 08:35',
  ),
  Order(
    id: 1024,
    userId: 1,
    items: 'Green Tea, Cheesecake',
    total: 97,
    status: 'Завершён',
    createdAt: '27.09.2026 · 17:10',
  ),
];

const mockLoyaltyHistory = [
  LoyaltyPoint(
    id: 1,
    userId: 1,
    orderId: 1058,
    points: 11,
    description: 'Начислено за заказ #1058',
    earnedAt: '06.10.2026',
  ),
  LoyaltyPoint(
    id: 2,
    userId: 1,
    points: -50,
    description: 'Скидка за бонусные баллы',
    earnedAt: '05.10.2026',
  ),
  LoyaltyPoint(
    id: 3,
    userId: 1,
    orderId: 1052,
    points: 9,
    description: 'Начислено за заказ #1052',
    earnedAt: '05.10.2026',
  ),
  LoyaltyPoint(
    id: 4,
    userId: 1,
    orderId: 1047,
    points: 10,
    description: 'Начислено за заказ #1047',
    earnedAt: '03.10.2026',
  ),
  LoyaltyPoint(
    id: 5,
    userId: 1,
    orderId: 1039,
    points: 6,
    description: 'Начислено за заказ #1039',
    earnedAt: '01.10.2026',
  ),
  LoyaltyPoint(
    id: 6,
    userId: 1,
    orderId: 1031,
    points: 7,
    description: 'Начислено за заказ #1031',
    earnedAt: '29.09.2026',
  ),
];