import 'package:coffee_club/data/result.dart';

class MockNetwork {
  bool simulateError = false;

  Future<Result<T>?> check<T>() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (simulateError) {
      return Err<T>(
        'Сеть недоступна (тестовый сбой). Отключите сбой и повторите.',
      );
    }
    return null;
  }
}
