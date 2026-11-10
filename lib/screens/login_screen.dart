import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/api.dart';
import '../data/result.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameController = TextEditingController();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final result = await context.read<Api>().login(
      _emailController.text.trim(),
      _passwordController.text,
      name: _register ? _nameController.text.trim() : null,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result case Err(:final msg)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.local_cafe,
                      size: 80,
                      color: scheme.primary,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'CoffeeClub',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Кофе, заказы и бонусы в одном приложении',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 40),

                    if (_register) ...[
                      TextFormField(
                        controller: _nameController,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Введите имя'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      enabled: !_busy,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon:
                            Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Введите e-mail';
                        }

                        if (!value.contains('@')) {
                          return 'Введите корректный e-mail';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !_busy,
                      obscureText: true,
                      textInputAction:
                          TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon:
                            Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Введите пароль';
                        }

                        if (value.length < 6) {
                          return 'Минимум 6 символов';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    FilledButton.icon(
                      onPressed: _busy ? null : _login,
                      icon: const Icon(Icons.login),
                      label: Text(_busy ? 'Подождите...' : _register ? 'Создать аккаунт' : 'Войти'),
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _register = !_register),
                      child: Text(_register ? 'Уже есть аккаунт? Войти'
                          : 'Нет аккаунта? Зарегистрируйтесь'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
