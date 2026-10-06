import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              product.category == 'Десерты'
                  ? Icons.cake_outlined
                  : Icons.local_cafe,
              size: 100,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            product.category,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.primary,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Цена'),
                  ),
                  Text(
                    '${product.price.toStringAsFixed(0)} MDL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Размер',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('S'),
                selected: false,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('M'),
                selected: true,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('L'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Добавить в корзину'),
          ),
        ],
      ),
    );
  }
}