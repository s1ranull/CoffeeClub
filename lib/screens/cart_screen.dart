import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProducts = mockProducts.take(6).toList();

    final total = cartProducts.fold<double>(
      0,
      (sum, product) => sum + product.price,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...cartProducts.map(
            (product) => Card(
              child: ListTile(
                leading: const Icon(Icons.local_cafe_outlined),
                title: Text(product.name),
                subtitle: const Text('Количество: 1'),
                trailing: Text(
                  '${product.price.toStringAsFixed(0)} MDL',
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Баланс бонусов'),
                      ),
                      Text(
                        '124 балла',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Использовать бонусные баллы',
                    ),
                    subtitle: const Text(
                      'Скидка будет применена при оформлении',
                    ),
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Итого',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                '${total.toStringAsFixed(0)} MDL',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            child: const Text('Оформить заказ'),
          ),
        ],
      ),
    );
  }
}