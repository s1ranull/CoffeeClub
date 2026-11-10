import 'package:flutter/foundation.dart';

import '../data/product.dart';
import '../data/product_repository.dart';
import '../data/result.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel(this._repository);
  final ProductRepository _repository;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<Product> _products = [];
  bool _loading = false;
  String? _error;
  static const _limit = 20;
  String _search = '';
  String? _category;
  int _page = 1;
  int _generation = 0;
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _moreError;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;
  String? get moreError => _moreError;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _loading;
  String? get error => _error;
  Product? byId(int id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> load({String? search, String? category}) async {
    if (search != null) _search = search.trim();
    if (category != null) _category = category == 'Все' ? null : category;
    final generation = ++_generation;
    _loading = true;
    _loadingMore = false;
    _hasMore = false;
    _error = null;
    _moreError = null;
    notifyListeners();
    final result = await _repository.fetchAll(
      limit: _limit, search: _search, category: _category,
    );
    if (_disposed || generation != _generation) return;
    switch (result) {
      case Ok(:final value):
        _products = value;
        _page = 1;
        _hasMore = value.length == _limit;
      case Err(:final msg):
        _products = [];
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final generation = _generation;
    _loadingMore = true;
    _moreError = null;
    notifyListeners();
    final result = await _repository.fetchAll(
      page: _page + 1, limit: _limit, search: _search, category: _category,
    );
    if (_disposed || generation != _generation) return;
    switch (result) {
      case Ok(:final value):
        _products = {
          for (final product in [..._products, ...value]) product.id: product,
        }.values.toList();
        _page++;
        _hasMore = value.length == _limit;
      case Err(:final msg):
        _moreError = msg;
    }
    _loadingMore = false;
    notifyListeners();
  }

  Future<String?> add(Product draft) async {
    try {
      switch (await _repository.create(draft)) {
        case Ok():
          if (!_disposed) await load();
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
          if (!_disposed) notifyListeners();
          return null;
        case Err(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось обновить товар'; }
  }

  Future<String?> remove(int id) async {
    try {
      switch (await _repository.delete(id)) {
        case Ok<void>():
          if (!_disposed) await load();
          return null;
        case Err<void>(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось удалить товар'; }
  }
}
