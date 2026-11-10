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
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
  String _category = 'Все';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final products = catalog.products;

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
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (text) => catalog.load(search: text),
                      decoration: InputDecoration(
                        hintText: 'Поиск напитка или десерта',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Найти',
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () => catalog.load(search: _search.text),
                        ),
                        border: const OutlineInputBorder(),
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
                            onSelected: (_) {
                              setState(() => _category = category);
                              catalog.load(category: category);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Меню · ${products.length}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (products.isEmpty)
                      const Padding(padding: EdgeInsets.all(36),
                          child: Center(child: Text('Ничего не найдено'))),
                    for (final product in products)
                      Padding(
                        key: ValueKey(product.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProductCard(product: product,
                            onTap: () => context.push('/menu/${product.id}')),
                      ),
                    if (catalog.moreError != null)
                      Text(catalog.moreError!, textAlign: TextAlign.center),
                    if (catalog.hasMore)
                      Center(
                        child: catalog.isLoadingMore
                            ? const CircularProgressIndicator()
                            : OutlinedButton(
                                onPressed: catalog.loadMore,
                                child: Text(catalog.moreError == null
                                    ? 'Показать ещё'
                                    : 'Повторить загрузку'),
                              ),
                      ),
                  ],
                ),
    );
  }
}
