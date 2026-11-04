import 'package:flutter/foundation.dart';

import '../data/order.dart';
import '../data/order_repository.dart';
import '../data/result.dart';

class OrderModel extends ChangeNotifier {
  OrderModel(this._repository);
  final OrderRepository _repository;

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      switch (await _repository.fetchAll()) {
        case Ok(:final value): _orders = value;
        case Err(:final msg): _error = msg;
      }
    } catch (_) { _error = 'Не удалось загрузить историю заказов'; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<(Order?, String?)> place(Order draft) async {
    try {
      switch (await _repository.create(draft)) {
        case Ok(:final value):
          _orders = [value, ..._orders];
          notifyListeners();
          return (value, null);
        case Err(:final msg): return (null, msg);
      }
    } catch (_) { return (null, 'Не удалось оформить заказ'); }
  }

  Future<String?> remove(int id) async {
    try {
      switch (await _repository.delete(id)) {
        case Ok<void>():
          _orders = _orders.where((o) => o.id != id).toList();
          notifyListeners();
          return null;
        case Err<void>(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось удалить заказ'; }
  }
}
