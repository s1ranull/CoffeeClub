import 'support/mock_network.dart';
import 'support/mock_product_repository.dart';
import 'package:coffee_club/data/product.dart';
import 'package:coffee_club/data/result.dart';
import 'package:coffee_club/models/cart_model.dart';
import 'package:coffee_club/models/catalog_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const coffee = Product(id: 1, name: 'Test Latte', price: 50,
      category: 'Кофе', imageUrl: '', description: 'Тестовый напиток');

  test('CartModel notifies and exposes immutable lines', () {
    final cart = CartModel();
    int notifications = 0;
    cart.addListener(() => notifications++);

    cart.add(coffee, size: 'M');
    cart.add(coffee, size: 'M');
    expect(cart.count, 2);
    expect(cart.total, 100);
    expect(notifications, 2);
    expect(() => cart.lines.clear(), throwsUnsupportedError);

    cart.decrement('1:M');
    expect(cart.count, 1);
    cart.remove('1:M');
    expect(cart.isEmpty, true);
    expect(notifications, 4);
    cart.dispose();
  });

  test('Repository simulates loading, CRUD and a controlled failure', () async {
    final network = MockNetwork();
    final repo = MockProductRepository(network);
    final stopwatch = Stopwatch()..start();
    final result = await repo.fetchAll();
    expect(result, isA<Ok<List<Product>>>());
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(800));

    final created = await repo.create(coffee.copyWith(id: 0));
    expect(created, isA<Ok<Product>>());
    final id = (created as Ok<Product>).value.id;
    expect(id, greaterThan(8));
    final changed = await repo.update(coffee.copyWith(id: id, price: 65));
    expect((changed as Ok<Product>).value.price, 65);
    expect(await repo.delete(id), isA<Ok<void>>());

    network.simulateError = true;
    expect(await repo.fetchAll(), isA<Err<List<Product>>>());
    network.simulateError = false;
    expect(await repo.fetchAll(), isA<Ok<List<Product>>>());
  });

  test('CatalogModel exposes loading/error/retry states', () async {
    final network = MockNetwork()..simulateError = true;
    final model = CatalogModel(MockProductRepository(network));
    final loading = model.load();
    expect(model.isLoading, true);
    await loading;
    expect(model.isLoading, false);
    expect(model.error, isNotNull);

    network.simulateError = false;
    await model.load();
    expect(model.error, isNull);
    expect(model.products.length, 8);
    expect(() => model.products.clear(), throwsUnsupportedError);
    model.dispose();
  });
}
