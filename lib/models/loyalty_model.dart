import 'package:flutter/foundation.dart';

import '../data/loyalty_point.dart';
import '../data/loyalty_repository.dart';
import '../data/result.dart';

class LoyaltyModel extends ChangeNotifier {
  LoyaltyModel(this._repository);
  final LoyaltyRepository _repository;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<LoyaltyPoint> _history = [];
  bool _loading = false;
  String? _error;
  List<LoyaltyPoint> get history => List.unmodifiable(_history);
  int get balance => _history.fold(0, (sum, entry) => sum + entry.points);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    if (!_disposed) notifyListeners();
    try {
      switch (await _repository.fetchAll()) {
        case Ok(:final value): _history = value;
        case Err(:final msg): _error = msg;
      }
    } catch (_) { _error = 'Не удалось загрузить бонусы'; }
    finally { _loading = false; if (!_disposed) notifyListeners(); }
  }

  Future<String?> record({required int orderId, required int points,
      required String description}) async {
    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final draft = LoyaltyPoint(id: 0, userId: 1, orderId: orderId,
        points: points, description: description, earnedAt: date);
    try {
      switch (await _repository.create(draft)) {
        case Ok(:final value):
          _history = [value, ..._history];
          if (!_disposed) notifyListeners();
          return null;
        case Err(:final msg): return msg;
      }
    } catch (_) { return 'Не удалось обновить бонусный баланс'; }
  }
}
