import 'loyalty_point.dart';
import 'loyalty_repository.dart';
import 'mock_data.dart';
import 'mock_network.dart';
import 'result.dart';

class MockLoyaltyRepository implements LoyaltyRepository {
  MockLoyaltyRepository(this._network);
  final MockNetwork _network;
  final List<LoyaltyPoint> _history = List.of(mockLoyaltyHistory);

  @override
  Future<Result<List<LoyaltyPoint>>> fetchAll() async {
    final failure = await _network.check<List<LoyaltyPoint>>();
    if (failure != null) return failure;
    return Ok(List.unmodifiable(_history));
  }

  @override
  Future<Result<LoyaltyPoint>> fetchById(int id) async {
    final failure = await _network.check<LoyaltyPoint>();
    if (failure != null) return failure;
    for (final entry in _history) {
      if (entry.id == id) return Ok(entry);
    }
    return const Err('Запись о баллах не найдена');
  }

  @override
  Future<Result<LoyaltyPoint>> create(LoyaltyPoint entry) async {
    final failure = await _network.check<LoyaltyPoint>();
    if (failure != null) return failure;
    final nextId = _history.fold<int>(0, (max, p) => p.id > max ? p.id : max) + 1;
    final saved = entry.copyWith(id: nextId);
    _history.insert(0, saved);
    return Ok(saved);
  }

  @override
  Future<Result<LoyaltyPoint>> update(LoyaltyPoint entry) async {
    final failure = await _network.check<LoyaltyPoint>();
    if (failure != null) return failure;
    final index = _history.indexWhere((p) => p.id == entry.id);
    if (index < 0) return const Err('Запись о баллах не найдена');
    _history[index] = entry;
    return Ok(entry);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final failure = await _network.check<void>();
    if (failure != null) return failure;
    if (!_history.any((p) => p.id == id)) return const Err('Запись о баллах не найдена');
    _history.removeWhere((p) => p.id == id);
    return const Ok<void>(null);
  }
}
