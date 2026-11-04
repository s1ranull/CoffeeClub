import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/catalog_model.dart';
import '../widgets/error_view.dart';
import '../widgets/product_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _search = '';
  String _category = 'Все';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final filtered = catalog.products.where((p) =>
        (_category == 'Все' || p.category == _category) &&
        p.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CoffeeClub'),
        actions: [
          IconButton(
            tooltip: 'Обновить меню',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CatalogModel>().load(),
          ),
          Consumer<CartModel>(
            builder: (context, cart, child) => IconButton(
              tooltip: 'Корзина (${cart.count})',
              onPressed: () => context.push('/menu/cart'),
              icon: Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                child: child!,
              ),
            ),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      floatingActionButton: catalog.error == null && !catalog.isLoading
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/menu/new'),
              icon: const Icon(Icons.add),
              label: const Text('Новый товар'),
            ) : null,
      body: catalog.isLoading
          ? const Center(child: CircularProgressIndicator())
          : catalog.error != null
              ? ErrorView(message: catalog.error!,
                  onRetry: () => context.read<CatalogModel>().load())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      onChanged: (text) => setState(() => _search = text),
                      decoration: const InputDecoration(
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
                        for (final category in ['Все', 'Кофе', 'Чай', 'Десерты'])
                          FilterChip(
                            label: Text(category),
                            selected: _category == category,
                            onSelected: (_) => setState(() => _category = category),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Меню · ${filtered.length}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(padding: EdgeInsets.all(36),
                          child: Center(child: Text('Ничего не найдено'))),
                    for (final product in filtered)
                      Padding(
                        key: ValueKey(product.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProductCard(product: product,
                            onTap: () => context.push('/menu/${product.id}')),
                      ),
                  ],
                ),
    );
  }
}
