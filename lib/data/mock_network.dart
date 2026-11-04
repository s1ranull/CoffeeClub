import 'result.dart';

// Общий переключатель аварии для всех mock-repository.
class MockNetwork {
  bool simulateError = false;

  Future<Result<T>?> check<T>() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (simulateError) {
      return Err<T>('Сеть недоступна (тестовый сбой). Отключите сбой и повторите.');
    }
    return null;
  }
}
