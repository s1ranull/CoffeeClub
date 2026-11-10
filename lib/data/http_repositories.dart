import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'loyalty_point.dart';
import 'loyalty_repository.dart';
import 'order.dart';
import 'order_repository.dart';
import 'product.dart';
import 'product_repository.dart';
import 'result.dart';

class _HttpCollection<T> {
  _HttpCollection(this.api, this.path, this.fromJson, this.toJson, this.idOf);

  final Api api;
  final String path;
  final T Function(Json) fromJson;
  final Json Function(T) toJson;
  final int Function(T) idOf;

  T _record(http.Response response) =>
      fromJson(jsonDecode(response.body) as Json);

  Future<Result<(List<T>, int)>> _page(
    int page,
    int limit, {
    String? search,
    String? category,
  }) => api.request(
    'GET',
    path,
    status: 200,
    query: {
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.isNotEmpty) 'search': search,
      'category': ?category,
    },
    decode: (response) {
      final json = jsonDecode(response.body) as Json;
      final items = (json['items'] as List).map(
        (item) => fromJson(item as Json),
      );
      return (items.toList(), json['total'] as int);
    },
  );

  Future<Result<List<T>>> all() async {
    final records = <T>[];
    for (var page = 1; ; page++) {
      switch (await _page(page, 100)) {
        case Ok(value: (final items, final total)):
          records.addAll(items);
          if (records.length >= total || items.isEmpty) return Ok(records);
        case Err(:final msg):
          return Err(msg);
      }
    }
  }

  Future<Result<T>> fetchById(int id) =>
      api.request('GET', '$path/$id', status: 200, decode: _record);

  Future<Result<T>> create(T item) => api.request(
    'POST',
    path,
    status: 201,
    body: toJson(item),
    decode: _record,
  );

  Future<Result<T>> update(T item) => api.request(
    'PUT',
    '$path/${idOf(item)}',
    status: 200,
    body: toJson(item),
    decode: _record,
  );

  Future<Result<void>> delete(int id) =>
      api.request<void>('DELETE', '$path/$id', status: 204, decode: (_) {});
}

class HttpProductRepository extends _HttpCollection<Product>
    implements ProductRepository {
  HttpProductRepository(Api api)
    : super(
        api,
        '/products',
        Product.fromJson,
        (item) => item.toJson(),
        (item) => item.id,
      );

  @override
  Future<Result<List<Product>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    return switch (await _page(
      page,
      limit,
      search: search,
      category: category,
    )) {
      Ok(value: (final items, _)) => Ok(items),
      Err(:final msg) => Err(msg),
    };
  }
}

class HttpOrderRepository extends _HttpCollection<Order>
    implements OrderRepository {
  HttpOrderRepository(Api api)
    : super(
        api,
        '/orders',
        Order.fromJson,
        (item) => item.toJson(),
        (item) => item.id,
      );

  @override
  Future<Result<List<Order>>> fetchAll() => all();
}

class HttpLoyaltyRepository extends _HttpCollection<LoyaltyPoint>
    implements LoyaltyRepository {
  HttpLoyaltyRepository(Api api)
    : super(
        api,
        '/loyalty-points',
        LoyaltyPoint.fromJson,
        (item) => item.toJson(),
        (item) => item.id,
      );

  @override
  Future<Result<List<LoyaltyPoint>>> fetchAll() => all();
}
