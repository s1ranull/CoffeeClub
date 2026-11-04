import 'package:flutter/foundation.dart';

import '../data/product.dart';
import '../data/product_repository.dart';
import '../data/result.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel(this._repository);
  final ProductRepository _repository;

  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _loading;
  String? get error => _error;
  Product? byId(int id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      switch (await _repository.fetchAll()) {
        case Ok(:final value): _products = value;
        case Err(:final msg): _error = msg;
      }
    } catch (_) {
      _error = 'Не удалось загрузить меню';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> add(Product draft) async {
    try {
      switch (await _repository.create(draft)) {
        case Ok(:final value):
          _products = [..._products, value];
          notifyListeners();
          return null;
        case Err(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось добавить товар'; }
  }

  Future<String?> update(Product product) async {
    try {
      switch (await _repository.update(product)) {
        case Ok(:final value):
          _products = [for (final p in _products) if (p.id == value.id) value else p];
          notifyListeners();
          return null;
        case Err(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось обновить товар'; }
  }

  Future<String?> remove(int id) async {
    try {
      switch (await _repository.delete(id)) {
        case Ok<void>():
          _products = _products.where((p) => p.id != id).toList();
          notifyListeners();
          return null;
        case Err<void>(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось удалить товар'; }
  }
}
