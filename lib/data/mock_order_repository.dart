import 'mock_data.dart';
import 'mock_network.dart';
import 'order.dart';
import 'order_repository.dart';
import 'result.dart';

class MockOrderRepository implements OrderRepository {
  MockOrderRepository(this._network);
  final MockNetwork _network;
  final List<Order> _orders = List.of(mockOrders);

  @override
  Future<Result<List<Order>>> fetchAll() async {
    final failure = await _network.check<List<Order>>();
    if (failure != null) return failure;
    return Ok(List.unmodifiable(_orders));
  }

  @override
  Future<Result<Order>> fetchById(int id) async {
    final failure = await _network.check<Order>();
    if (failure != null) return failure;
    for (final order in _orders) {
      if (order.id == id) return Ok(order);
    }
    return const Err('Заказ не найден');
  }

  @override
  Future<Result<Order>> create(Order order) async {
    final failure = await _network.check<Order>();
    if (failure != null) return failure;
    final nextId = _orders.fold<int>(1000, (max, o) => o.id > max ? o.id : max) + 1;
    final saved = order.copyWith(id: nextId);
    _orders.insert(0, saved);
    return Ok(saved);
  }

  @override
  Future<Result<Order>> update(Order order) async {
    final failure = await _network.check<Order>();
    if (failure != null) return failure;
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index < 0) return const Err('Заказ не найден');
    _orders[index] = order;
    return Ok(order);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final failure = await _network.check<void>();
    if (failure != null) return failure;
    if (!_orders.any((o) => o.id == id)) return const Err('Заказ не найден');
    _orders.removeWhere((o) => o.id == id);
    return const Ok<void>(null);
  }
}
