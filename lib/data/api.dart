import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'result.dart';

const apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

typedef Json = Map<String, dynamic>;

String apiMessage(http.Response response, {required bool login}) {
  try {
    final error = (jsonDecode(response.body) as Json)['error'] as Json;
    final code = error['code'] as String;
    return switch (code) {
      'VALIDATION_ERROR' => 'Проверьте введённые данные',
      'UNAUTHORIZED' when login => 'Неверный e-mail или пароль',
      'EMAIL_TAKEN' => 'Аккаунт с этим e-mail уже существует',
      'NOT_FOUND' => 'Запись не найдена',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    return 'Ошибка сервера (${response.statusCode})';
  } on TypeError {
    return 'Ошибка сервера (${response.statusCode})';
  }
}

class TokenStore {
  TokenStore(this.prefs);
  final SharedPreferences prefs;
  static const _tokenKey = 'auth_token';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';

  String? get token => prefs.getString(_tokenKey);
  String get name => prefs.getString(_nameKey) ?? 'Пользователь';
  String get email => prefs.getString(_emailKey) ?? 'E-mail не указан';

  Future<void> save(String token, String name, String email) async {
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clear() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }
}

class Api extends ChangeNotifier {
  Api(this.tokens, {this.baseUrl = apiBase, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final TokenStore tokens;
  final http.Client _client;
  Future<void>? _signingOut;

  bool get signedIn => tokens.token != null && _signingOut == null;
  String get name => tokens.name;
  String get email => tokens.email;

  Future<Result<void>> login(String email, String password, {String? name}) =>
      request<void>(
        'POST',
        name == null ? '/auth/login' : '/auth/register',
        status: name == null ? 200 : 201,
        authenticated: false,
        body: {
          'email': email,
          'password': password,
          'name': ?name,
        },
        decode: (response) async {
          final data = jsonDecode(response.body) as Json;
          final token = data['token'] as String;
          final user = data['user'] as Json;
          if (token.isEmpty) throw const FormatException();
          await tokens.save(
            token,
            user['name'] as String,
            user['email'] as String,
          );
          notifyListeners();
        },
      );

  Future<void> logout() => _signingOut ??= _clearSession();

  Future<void> _clearSession() async {
    try {
      await tokens.clear();
    } finally {
      _signingOut = null;
      notifyListeners();
    }
  }

  Future<Result<T>> request<T>(
    String method,
    String path, {
    required int status,
    required FutureOr<T> Function(http.Response) decode,
    bool authenticated = true,
    Json? body,
    Map<String, String>? query,
  }) async {
    final token = tokens.token;
    if (authenticated && !signedIn) {
      return Err('Сессия истекла. Войдите снова');
    }
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final request = http.Request(method, uri);
      if (authenticated) request.headers['Authorization'] = 'Bearer $token';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 8));
      if (authenticated && response.statusCode == 401) {
        if (tokens.token == token) await logout();
        return Err('Сессия истекла. Войдите снова');
      }
      if (response.statusCode != status) {
        return Err(apiMessage(response, login: path == '/auth/login'));
      }
      return Ok(await decode(response));
    } on SocketException {
      return Err('Сервер недоступен. Проверьте подключение и повторите');
    } on http.ClientException {
      return Err('Сервер недоступен. Проверьте подключение и повторите');
    } on TimeoutException {
      return Err('Сервер не отвечает');
    } on FormatException {
      return Err('Сервер прислал некорректный ответ');
    } on TypeError {
      return Err('Сервер прислал некорректный ответ');
    }
  }
}
