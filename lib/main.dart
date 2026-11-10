import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/api.dart';
import 'data/http_repositories.dart';
import 'models/cart_model.dart';
import 'models/catalog_model.dart';
import 'models/loyalty_model.dart';
import 'models/order_model.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = Api(TokenStore(await SharedPreferences.getInstance()));
  final products = HttpProductRepository(api);
  final orders = HttpOrderRepository(api);
  final loyalty = HttpLoyaltyRepository(api);
  final router = createRouter(
    api,
    (child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogModel(products)..load()),
        ChangeNotifierProvider(create: (_) => OrderModel(orders)..load()),
        ChangeNotifierProvider(create: (_) => LoyaltyModel(loyalty)..load()),
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: child,
    ),
  );
  runApp(ChangeNotifierProvider<Api>.value(
    value: api,
    child: CoffeeClubApp(router: router),
  ));
}

class CoffeeClubApp extends StatelessWidget {
  const CoffeeClubApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CoffeeClub',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      routerConfig: router,
    );
  }
}
