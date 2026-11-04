import 'package:flutter/foundation.dart';

// Локальная сессия L3: без backend-а и хранения пароля.
class SessionModel extends ChangeNotifier {
  String? _email;
  String get name => 'Илья Ведерников';
  String get email => _email ?? 'E-mail не указан';
  String get phone => 'Не указан';
  String get initials => name.split(' ').where((part) => part.isNotEmpty)
      .map((part) => part[0]).take(2).join().toUpperCase();

  void login(String email) {
    _email = email.trim();
    notifyListeners();
  }

  void logout() {
    _email = null;
    notifyListeners();
  }
}
