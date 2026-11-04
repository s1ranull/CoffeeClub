import 'order.dart';
import 'result.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> fetchAll();
  Future<Result<Order>> fetchById(int id);
  Future<Result<Order>> create(Order order);
  Future<Result<Order>> update(Order order);
  Future<Result<void>> delete(int id);
}
