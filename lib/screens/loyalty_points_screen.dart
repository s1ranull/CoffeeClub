import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/loyalty_model.dart';
import '../widgets/error_view.dart';

class LoyaltyPointsScreen extends StatelessWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loyalty = context.watch<LoyaltyModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои баллы'),
        actions: [
          IconButton(tooltip: 'Обновить', icon: const Icon(Icons.refresh),
              onPressed: () => context.read<LoyaltyModel>().load()),
        ],
      ),
      body: loyalty.isLoading
          ? const Center(child: CircularProgressIndicator())
          : loyalty.error != null
              ? ErrorView(message: loyalty.error!, onRetry: () => context.read<LoyaltyModel>().load())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.stars,
                    size: 48,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                      '${loyalty.balance}',
                    style:
                        Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimaryContainer,
                            ),
                  ),
                  Text(
                    'доступных балла',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'История баллов',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...loyalty.history.map(
            (entry) {
              final positive = entry.points > 0;

              return Card(
                child: ListTile(
                  leading: Icon(
                    positive
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                  ),
                  title: Text(entry.description),
                  subtitle: Text(entry.earnedAt),
                  trailing: Text(
                    '${positive ? '+' : ''}${entry.points}',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
