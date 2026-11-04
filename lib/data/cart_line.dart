import 'product.dart';

class CartLine {
  final Product product;
  final String size;
  final int quantity;

  const CartLine({required this.product, required this.size, required this.quantity});

  String get key => '${product.id}:$size';
  double get subtotal => product.price * quantity;

  CartLine copyWith({Product? product, String? size, int? quantity}) =>
      CartLine(
        product: product ?? this.product,
        size: size ?? this.size,
        quantity: quantity ?? this.quantity,
      );
}
