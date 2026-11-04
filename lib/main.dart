import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_loyalty_repository.dart';
import 'data/mock_network.dart';
import 'data/mock_order_repository.dart';
import 'data/mock_product_repository.dart';
import 'data/loyalty_repository.dart';
import 'data/order_repository.dart';
import 'data/product_repository.dart';
import 'models/cart_model.dart';
import 'models/catalog_model.dart';
import 'models/loyalty_model.dart';
import 'models/order_model.dart';
import 'models/session_model.dart';
import 'router.dart';

void main() {
  // Единственное место выбора источника данных. На L5 mock заменяется API.
  final network = MockNetwork();
  final products = MockProductRepository(network);
  final orders = MockOrderRepository(network);
  final loyalty = MockLoyaltyRepository(network);
  runApp(MultiProvider(
    providers: [
      Provider<MockNetwork>.value(value: network),
      Provider<ProductRepository>.value(value: products),
      Provider<OrderRepository>.value(value: orders),
      Provider<LoyaltyRepository>.value(value: loyalty),
      ChangeNotifierProvider(create: (_) => CatalogModel(products)..load()),
      ChangeNotifierProvider(create: (_) => OrderModel(orders)..load()),
      ChangeNotifierProvider(create: (_) => LoyaltyModel(loyalty)..load()),
      ChangeNotifierProvider(create: (_) => CartModel()),
      ChangeNotifierProvider(create: (_) => SessionModel()),
    ],
    child: const CoffeeClubApp(),
  ));
}

class CoffeeClubApp extends StatelessWidget {
  const CoffeeClubApp({super.key});

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
