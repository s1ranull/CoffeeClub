import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/catalog_model.dart';
import '../widgets/error_view.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  String _selectedSize = 'M';

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: const Text('Он исчезнет из меню и корзины.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final error = await context.read<CatalogModel>().remove(widget.productId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.read<CartModel>().removeProduct(widget.productId);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final catalog = context.watch<CatalogModel>();
    if (catalog.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (catalog.error != null) {
      return Scaffold(body: ErrorView(message: catalog.error!,
        onRetry: () => context.read<CatalogModel>().load()));
    }
    final product = catalog.byId(widget.productId);
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Товар не существует')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(tooltip: 'Редактировать', icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/menu/${product.id}/edit')),
          IconButton(tooltip: 'Удалить', icon: const Icon(Icons.delete_outline),
              onPressed: _delete),
        ],
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
                  : product.category == 'Чай'
                      ? Icons.emoji_food_beverage_outlined
                      : Icons.local_cafe,
              size: 100,
              color: scheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            product.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            product.category,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Размер',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: [
              for (final size in ['S', 'M', 'L'])
                ChoiceChip(
                  label: Text(size),
                  selected: _selectedSize == size,
                  onSelected: (_) {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                ),
            ],
          ),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: () {
              context.read<CartModel>().add(product, size: _selectedSize);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${product.name}, размер $_selectedSize добавлен в корзину',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Добавить в корзину'),
          ),
        ],
      ),
    );
  }
}
