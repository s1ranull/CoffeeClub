import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoffeeClub'),
        actions: [
          IconButton(
            tooltip: 'Корзина',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Поиск напитка или десерта',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Все'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Кофе'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Чай'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Десерты'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Меню',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...mockProducts.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}