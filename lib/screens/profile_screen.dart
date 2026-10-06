import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'ilya@example.com',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('E-mail'),
                  subtitle: Text('ilya@example.com'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone_outlined),
                  title: Text('Телефон'),
                  subtitle: Text('+373 60 123 456'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.stars_outlined),
                  title: Text('Бонусный баланс'),
                  subtitle: Text('124 балла'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Редактировать профиль'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}