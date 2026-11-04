import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../widgets/error_view.dart';
import '../widgets/order_status_badge.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OrderModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        actions: [
          IconButton(tooltip: 'Обновить', icon: const Icon(Icons.refresh),
              onPressed: () => context.read<OrderModel>().load()),
        ],
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : model.error != null
              ? ErrorView(message: model.error!, onRetry: () => context.read<OrderModel>().load())
          : model.orders.isEmpty
              ? const Center(child: Text('Заказов пока нет'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: model.orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final order = model.orders[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Заказ #${order.id}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const Spacer(),
                      OrderStatusBadge(
                        status: order.status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(order.items),
                  const SizedBox(height: 8),
                  Text(
                    order.createdAt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${order.total.toStringAsFixed(0)} MDL',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
