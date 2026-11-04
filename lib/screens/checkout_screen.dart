import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/order.dart';
import '../models/cart_model.dart';
import '../models/loyalty_model.dart';
import '../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.usePoints});
  final bool usePoints;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final cart = context.read<CartModel>();
    final loyalty = context.read<LoyaltyModel>();
    if (cart.isEmpty) return;
    final lines = cart.lines; // Снимок заказа: список защищён от внешней мутации.
    final discount = widget.usePoints
        ? math.min(loyalty.balance, cart.total.floor()) : 0;
    final total = cart.total - discount;
    final now = DateTime.now();
    final createdAt = '${now.day.toString().padLeft(2, '0')}.'
        '${now.month.toString().padLeft(2, '0')}.${now.year} · '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final draft = Order(
      id: 0,
      userId: 1,
      items: lines.map((line) => '${line.product.name} (${line.size}) × ${line.quantity}').join(', '),
      total: total,
      status: 'Принят',
      createdAt: createdAt,
      customerName: _name.text.trim(),
      phone: _phone.text.trim(),
    );

    setState(() => _saving = true);
    final (order, error) = await context.read<OrderModel>().place(draft);
    if (!mounted) return;
    if (error != null || order == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Не удалось оформить заказ')));
      return; // Форма и корзина остаются без изменений при отказе.
    }

    String? bonusError;
    if (discount > 0) {
      bonusError = await loyalty.record(orderId: order.id, points: -discount,
          description: 'Списано за заказ #${order.id}');
    }
    if (bonusError == null) {
      final earned = (total / 10).floor();
      if (earned > 0) {
        bonusError = await loyalty.record(orderId: order.id, points: earned,
            description: 'Начислено за заказ #${order.id}');
      }
    }
    if (!mounted) return;
    cart.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(bonusError == null
          ? 'Заказ #${order.id} успешно оформлен'
          : 'Заказ #${order.id} оформлен, но бонусы не обновились: $bonusError'),
    ));
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final loyalty = context.watch<LoyaltyModel>();
    final discount = widget.usePoints && loyalty.error == null && !loyalty.isLoading
        ? math.min(loyalty.balance, cart.total.floor()) : 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Контактные данные', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Имя',
                  prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? 'Укажите имя (от 2 символов)' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              enabled: !_saving,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Телефон',
                  prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
              validator: (value) {
                final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                return digits.length < 8 ? 'Введите номер телефона (от 8 цифр)' : null;
              },
            ),
            const SizedBox(height: 24),
            Text('Ваш заказ', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final line in cart.lines)
              ListTile(
                title: Text(line.product.name),
                subtitle: Text('Размер ${line.size} · ${line.quantity} шт.'),
                trailing: Text('${line.subtotal.toStringAsFixed(0)} MDL'),
              ),
            const Divider(),
            if (discount > 0) Text('Бонусная скидка: −$discount MDL'),
            const SizedBox(height: 8),
            Text('К оплате: ${(cart.total - discount).toStringAsFixed(0)} MDL',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving || cart.isEmpty ? null : _submit,
              icon: _saving ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: Text(_saving ? 'Сохраняем...' : 'Подтвердить заказ'),
            ),
          ]),
        ),
      ),
    );
  }
}
