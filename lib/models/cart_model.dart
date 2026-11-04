import 'package:flutter/foundation.dart';

import '../data/cart_line.dart';
import '../data/product.dart';

// Корзина разделяется между каталогом, деталями, корзиной и оформлением.
class CartModel extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  int get count => _lines.fold(0, (sum, line) => sum + line.quantity);
  double get total => _lines.fold(0, (sum, line) => sum + line.subtotal);
  bool get isEmpty => _lines.isEmpty;

  void add(Product product, {String size = 'M'}) {
    final index = _lines.indexWhere((line) => line.product.id == product.id && line.size == size);
    if (index == -1) {
      _lines.add(CartLine(product: product, size: size, quantity: 1));
    } else {
      _lines[index] = _lines[index].copyWith(quantity: _lines[index].quantity + 1);
    }
    notifyListeners();
  }

  void decrement(String key) {
    final index = _lines.indexWhere((line) => line.key == key);
    if (index == -1) return;
    if (_lines[index].quantity == 1) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].copyWith(quantity: _lines[index].quantity - 1);
    }
    notifyListeners();
  }

  void remove(String key) {
    final oldLength = _lines.length;
    _lines.removeWhere((line) => line.key == key);
    if (oldLength != _lines.length) notifyListeners();
  }

  void removeProduct(int id) {
    final oldLength = _lines.length;
    _lines.removeWhere((line) => line.product.id == id);
    if (oldLength != _lines.length) notifyListeners();
  }

  void replaceProduct(Product product) {
    bool changed = false;
    for (int i = 0; i < _lines.length; i++) {
      if (_lines[i].product.id == product.id) {
        _lines[i] = _lines[i].copyWith(product: product);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }
}
