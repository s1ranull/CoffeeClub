import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
              child: const Text(
                'IV',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Илья Ведерников',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 4),

          Text(
            'ilya@example.com',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      Icon(Icons.email_outlined),
                  title: Text('E-mail'),
                  subtitle:
                      Text('ilya@example.com'),
                ),
                Divider(height: 1),
                ListTile(
                  leading:
                      Icon(Icons.phone_outlined),
                  title: Text('Телефон'),
                  subtitle:
                      Text('+373 60 123 456'),
                ),
                Divider(height: 1),
                ListTile(
                  leading:
                      Icon(Icons.stars_outlined),
                  title:
                      Text('Бонусный баланс'),
                  subtitle: Text('124 балла'),
                ),
              ],
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