import 'package:bakemart/core/shared/models/cart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('has empty defaults', () {
    final cart = Cart();

    expect(cart.isEmpty, true);
    expect(cart.bakeries, isEmpty);
    expect(cart.products, isEmpty);
    expect(cart.quantities, isEmpty);
    expect(cart.deliveryFee, 0.0);
    expect(cart.orderPrice, 0.0);
    expect(cart.totalBill, 0.0);
    expect(cart.userLat, 0.0);
    expect(cart.userLng, 0.0);
    expect(cart.street, isNull);
  });

  test('isEmpty depends on products', () {
    final cart = Cart(products: {'p1': fakeProduct()});

    expect(cart.isEmpty, false);
  });

  test('maps cannot be modified from outside', () {
    final cart = Cart(quantities: {'p1': 1});

    expect(() => cart.quantities['p2'] = 2, throwsUnsupportedError);
    expect(() => cart.products['p2'] = fakeProduct(), throwsUnsupportedError);
    expect(
          () => cart.bakeries['b1'] = fakeBakery('b1', 0, 0),
      throwsUnsupportedError,
    );
  });

  test('copyWith changes only the given fields', () {
    final cart = Cart(
      quantities: {'p1': 1},
      orderPrice: 10,
      deliveryFee: 2,
      totalBill: 12,
      userLat: 1,
      userLng: 2,
      street: 'S',
    );

    final copy = cart.copyWith(orderPrice: 20, building: 'B');

    expect(copy.orderPrice, 20);
    expect(copy.building, 'B');
    expect(copy.deliveryFee, 2);
    expect(copy.totalBill, 12);
    expect(copy.userLat, 1);
    expect(copy.userLng, 2);
    expect(copy.street, 'S');
    expect(copy.quantities, {'p1': 1});
  });

  test('copyWith copies the maps it receives', () {
    final source = <String, int>{'p1': 1};
    final cart = Cart().copyWith(quantities: source);

    source['p2'] = 2;

    expect(cart.quantities, {'p1': 1});
  });
}