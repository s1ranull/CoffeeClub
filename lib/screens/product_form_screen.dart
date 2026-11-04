import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/product.dart';
import '../models/cart_model.dart';
import '../models/catalog_model.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final int? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  String _category = 'Кофе';
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final id = widget.productId;
    final product = id == null ? null : Provider.of<CatalogModel>(context, listen: false).byId(id);
    if (product != null) {
      _name.text = product.name;
      _price.text = product.price.toStringAsFixed(0);
      _description.text = product.description;
      _category = product.category;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final draft = Product(
      id: widget.productId ?? 0,
      name: _name.text.trim(),
      price: double.parse(_price.text.trim().replaceAll(',', '.')),
      category: _category,
      imageUrl: '',
      description: _description.text.trim(),
    );
    setState(() => _saving = true);
    final catalog = context.read<CatalogModel>();
    final error = widget.productId == null
        ? await catalog.add(draft)
        : await catalog.update(draft);
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (widget.productId != null) context.read<CartModel>().replaceProduct(draft);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.productId != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Редактировать товар' : 'Новый товар')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Название',
                  border: OutlineInputBorder()),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? 'Введите название (минимум 2 символа)' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Категория',
                  border: OutlineInputBorder()),
              items: ['Кофе', 'Чай', 'Десерты']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: _saving ? null : (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _price,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Цена (MDL)',
                  border: OutlineInputBorder()),
              validator: (value) {
                final price = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                return price == null || !price.isFinite || price <= 0
                    ? 'Введите положительную цену' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              enabled: !_saving,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Описание',
                  alignLabelWithHint: true, border: OutlineInputBorder()),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Введите описание' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Сохраняем...' : 'Сохранить'),
            ),
          ],
        )),
      ),
    );
  }
}
