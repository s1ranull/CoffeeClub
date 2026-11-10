import 'dart:convert';

import 'package:coffee_club/data/api.dart';
import 'package:coffee_club/data/http_repositories.dart';
import 'package:coffee_club/data/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Login stores the token and a protected 401 clears it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final tokens = TokenStore(prefs);
    final api = Api(
      tokens,
      client: MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({
              'token': 'test-token',
              'user': {'id': 3, 'name': 'Ana', 'email': 'ana@example.com'},
            }),
            200,
          );
        }
        expect(request.url.path, '/products');
        expect(request.headers['authorization'], 'Bearer test-token');
        return http.Response('', 401);
      }),
    );

    expect(await api.login('ana@example.com', 'test1234'), isA<Ok<void>>());
    expect(prefs.getString('auth_token'), 'test-token');
    expect(prefs.getKeys(), {'auth_token', 'auth_name', 'auth_email'});
    expect(Api(TokenStore(prefs)).signedIn, isTrue);

    expect(await HttpProductRepository(api).fetchAll(), isA<Err>());
    expect(prefs.getString('auth_token'), isNull);
    expect(api.signedIn, isFalse);
  });
}
