import 'loyalty_point.dart';
import 'result.dart';

abstract class LoyaltyRepository {
  Future<Result<List<LoyaltyPoint>>> fetchAll();
  Future<Result<LoyaltyPoint>> fetchById(int id);
  Future<Result<LoyaltyPoint>> create(LoyaltyPoint entry);
  Future<Result<LoyaltyPoint>> update(LoyaltyPoint entry);
  Future<Result<void>> delete(int id);
}
