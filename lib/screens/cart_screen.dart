import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/loyalty_model.dart';
import '../widgets/error_view.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _usePoints = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final loyalty = context.watch<LoyaltyModel>();
    final discount = _usePoints && !loyalty.isLoading && loyalty.error == null
        ? math.min(loyalty.balance, cart.total.floor()) : 0;
    final payable = cart.total - discount;

    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: cart.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.shopping_basket_outlined, size: 70),
              const SizedBox(height: 12),
              const Text('Корзина пока пуста'),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: () => context.pop(),
                  child: const Text('Вернуться в меню')),
            ]))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final line in cart.lines)
                  Dismissible(
                    key: ValueKey(line.key),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 22),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => context.read<CartModel>().remove(line.key),
                    child: Card(child: ListTile(
                      leading: const Icon(Icons.local_cafe_outlined),
                      title: Text(line.product.name),
                      subtitle: Text('Размер: ${line.size} · ${line.subtotal.toStringAsFixed(0)} MDL'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(tooltip: 'Уменьшить', icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => context.read<CartModel>().decrement(line.key)),
                        Text('${line.quantity}'),
                        IconButton(tooltip: 'Добавить', icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => context.read<CartModel>().add(line.product, size: line.size)),
                      ]),
                    )),
                  ),
                const SizedBox(height: 20),
                if (loyalty.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (loyalty.error != null)
                  ErrorView(message: loyalty.error!,
                      onRetry: () => context.read<LoyaltyModel>().load())
                else Card(child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Использовать баллы · ${loyalty.balance} доступно'),
                    subtitle: const Text('1 балл = 1 MDL скидки'),
                    value: _usePoints,
                    onChanged: loyalty.balance <= 0 ? null :
                        (value) => setState(() => _usePoints = value ?? false),
                  ),
                )),
                const SizedBox(height: 16),
                Row(children: [
                  const Text('Товары'),
                  const Spacer(),
                  Text('${cart.total.toStringAsFixed(0)} MDL'),
                ]),
                if (discount > 0) Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    const Text('Скидка баллами'),
                    const Spacer(),
                    Text('−$discount MDL'),
                  ]),
                ),
                const Divider(height: 28),
                Row(children: [
                  Text('К оплате', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text('${payable.toStringAsFixed(0)} MDL',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
                const SizedBox(height: 24),
                FilledButton(onPressed: loyalty.isLoading || loyalty.error != null
                    ? null : () => context.push('/menu/cart/checkout', extra: _usePoints),
                    child: const Text('Оформить заказ')),
              ],
            ),
    );
  }
}
