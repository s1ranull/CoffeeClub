import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_network.dart';
import '../models/loyalty_model.dart';
import '../models/session_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Выйти из аккаунта?'),
          content: const Text(
            'Вы действительно хотите выйти?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx, false);
              },
              child: const Text('Нет'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogCtx, true);
              },
              child: const Text('Да, выйти'),
            ),
          ],
        );
      },
    );

    if (ok == true && context.mounted) {
      context.read<SessionModel>().logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loyalty = context.watch<LoyaltyModel>();
    final failure = context.watch<MockNetwork>();
    final session = context.watch<SessionModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor:
                  scheme.primaryContainer,
              foregroundColor:
                  scheme.onPrimaryContainer,
              child: Text(
                session.initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            session.name,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 4),

          Text(
            session.email,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.email_outlined),
                  title: const Text('E-mail'),
                  subtitle: Text(session.email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.phone_outlined),
                  title: const Text('Телефон'),
                  subtitle: Text(session.phone),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.stars_outlined),
                  title: const Text('Бонусный баланс'),
                  subtitle: Text(loyalty.isLoading ? 'Загрузка...'
                      : loyalty.error != null ? 'Ошибка получения баллов'
                      : '${loyalty.balance} баллов'),
                  trailing: loyalty.error != null
                      ? IconButton(icon: const Icon(Icons.refresh),
                          onPressed: () => context.read<LoyaltyModel>().load())
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.wifi_off_outlined),
              title: const Text('Симулировать сбой сети'),
              subtitle: const Text('Для демонстрации загрузки, ошибки и Retry на L4'),
              value: failure.simulateError,
              onChanged: (value) => setState(() =>
                  context.read<MockNetwork>().simulateError = value),
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Редактирование профиля пока работает локально',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label:
                const Text('Редактировать профиль'),
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
