import 'mock_data.dart';
import 'mock_network.dart';

import 'package:coffee_club/data/product.dart';
import 'package:coffee_club/data/product_repository.dart';
import 'package:coffee_club/data/result.dart';

class MockProductRepository implements ProductRepository {
  MockProductRepository(this._network);
  final MockNetwork _network;
  final List<Product> _products = List.of(mockProducts);

  @override
  Future<Result<List<Product>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final failure = await _network.check<List<Product>>();
    if (failure != null) return failure;
    final query = search?.toLowerCase() ?? '';
    final products = _products.where(
      (item) =>
          (category == null || item.category == category) &&
          item.name.toLowerCase().contains(query),
    );
    return Ok(List.unmodifiable(products.skip((page - 1) * limit).take(limit)));
  }

  @override
  Future<Result<Product>> fetchById(int id) async {
    final failure = await _network.check<Product>();
    if (failure != null) return failure;
    for (final product in _products) {
      if (product.id == id) return Ok(product);
    }
    return const Err('Товар не найден');
  }

  @override
  Future<Result<Product>> create(Product product) async {
    final failure = await _network.check<Product>();
    if (failure != null) return failure;
    final nextId =
        _products.fold<int>(0, (max, p) => p.id > max ? p.id : max) + 1;
    final saved = product.copyWith(id: nextId);
    _products.add(saved);
    return Ok(saved);
  }

  @override
  Future<Result<Product>> update(Product product) async {
    final failure = await _network.check<Product>();
    if (failure != null) return failure;
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index < 0) return const Err('Товар не найден');
    _products[index] = product;
    return Ok(product);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final failure = await _network.check<void>();
    if (failure != null) return failure;
    if (!_products.any((p) => p.id == id)) return const Err('Товар не найден');
    _products.removeWhere((p) => p.id == id);
    return const Ok<void>(null);
  }
}
