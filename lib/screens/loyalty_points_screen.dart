import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class LoyaltyPointsScreen extends StatelessWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои баллы'),
      ),
      body: ListView(
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
                    '124',
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
          ...mockLoyaltyHistory.map(
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