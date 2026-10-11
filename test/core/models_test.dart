import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/recipe_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/bakeries_table_columns.dart';
import 'package:bakemart/core/utils/enums/home_screen_table_columns.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/orders_table_columns.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/users_table_columns.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('UserModel', () {
    test('fromJson falls back to defaults', () {
      final user = UserModel.fromJson({});

      expect(user.id, isNull);
      expect(user.firstName, '');
      expect(user.secondName, '');
      expect(user.email, '');
      expect(user.phone, '');
      expect(user.street, isNull);
      expect(user.hasProfileImage, false);
    });

    test('toJson omits null optional fields', () {
      final json = UserModel(
        firstName: 'A',
        secondName: 'B',
        email: 'a@b.c',
        phone: '1',
      ).toJson();

      expect(json.containsKey(UsersTableColumns.id), false);
      expect(json.containsKey(UsersTableColumns.street), false);
      expect(json[UsersTableColumns.hasProfileImage], false);
    });

    test('survives a toJson and fromJson round trip', () {
      final user = UserModel(
        id: 'u1',
        firstName: 'A',
        secondName: 'B',
        email: 'a@b.c',
        phone: '1',
        street: 'S',
        building: 'B',
        apartment: 'Ap',
        hasProfileImage: true,
      );

      final parsed = UserModel.fromJson(user.toJson());

      expect(parsed.toJson(), user.toJson());
    });

    test('copyWith changes only the given fields', () {
      final user = UserModel(
        id: 'u1',
        firstName: 'A',
        secondName: 'B',
        email: 'a@b.c',
        phone: '1',
      );

      final copy = user.copyWith(hasProfileImage: true);

      expect(copy.hasProfileImage, true);
      expect(copy.id, 'u1');
      expect(copy.firstName, 'A');
    });
  });

  group('BakeryModel', () {
    test('fromJson reads a list of supervisors', () {
      final bakery = BakeryModel.fromJson({
        BakeriesTableColumns.bakeryId: 'b1',
        BakeriesTableColumns.bakeryName: 'Bakery',
        BakeriesTableColumns.bakeryLat: 30,
        BakeriesTableColumns.bakeryLng: 31.5,
        BakeriesTableColumns.supervisorId: ['s1', 's2'],
      });

      expect(bakery.bakeryId, 'b1');
      expect(bakery.bakeryLat, 30.0);
      expect(bakery.bakeryLng, 31.5);
      expect(bakery.supervisorId, ['s1', 's2']);
    });

    test('fromJson wraps a single supervisor string', () {
      final bakery = BakeryModel.fromJson({
        BakeriesTableColumns.supervisorId: 's1',
      });

      expect(bakery.supervisorId, ['s1']);
    });

    test('fromJson treats an empty supervisor string as none', () {
      final bakery = BakeryModel.fromJson({
        BakeriesTableColumns.supervisorId: '',
      });

      expect(bakery.supervisorId, isEmpty);
    });

    test('fromJson falls back to defaults', () {
      final bakery = BakeryModel.fromJson({});

      expect(bakery.bakeryId, '');
      expect(bakery.bakeryName, '');
      expect(bakery.bakeryLat, 0.0);
      expect(bakery.bakeryLng, 0.0);
      expect(bakery.supervisorId, isEmpty);
    });

    test('round trips through json and compares equal', () {
      final bakery = BakeryModel(
        bakeryId: 'b1',
        bakeryName: 'Bakery',
        bakeryLat: 1.5,
        bakeryLng: 2.5,
        supervisorId: const ['s1'],
      );

      final parsed = BakeryModel.fromJson(bakery.toJson());

      expect(parsed, bakery);
      expect(parsed.hashCode, bakery.hashCode);
    });

    test('copyWith produces a different bakery', () {
      final bakery = fakeBakery('b1', 1, 2);

      final copy = bakery.copyWith(supervisorId: ['s1']);

      expect(copy, isNot(bakery));
      expect(copy.bakeryId, 'b1');
    });
  });

  group('ProductModel', () {
    test('fromJson falls back to defaults', () {
      final product = ProductModel.fromJson({});

      expect(product.productId, isNull);
      expect(product.bakeryId, '');
      expect(product.productName, 'Unknown Product');
      expect(product.productPrice, 0.0);
      expect(product.quantityPerBatch, 1);
      expect(product.available, 0);
    });

    test('toJson omits an empty product id', () {
      final withoutId = fakeProduct(id: '');
      final withId = fakeProduct(id: 'p1');

      expect(
        withoutId.toJson().containsKey(ProductsTableColumns.productId),
        false,
      );
      expect(withId.toJson()[ProductsTableColumns.productId], 'p1');
    });

    test('rate combines sell-through, volume and revenue scores', () {
      final product = fakeProduct(
        overrides: {
          ProductsTableColumns.totalProduced: 100,
          ProductsTableColumns.totalSold: 100,
          ProductsTableColumns.yesterdayProduced: 50,
          ProductsTableColumns.yesterdaySold: 50,
          ProductsTableColumns.productPrice: 1.0,
        },
      );

      expect(product.rate, 2.85);
    });

    test('rate for a product without history', () {
      final product = fakeProduct();

      expect(product.rate, 0.85);
    });

    test('rate is capped at 5', () {
      final product = fakeProduct(
        overrides: {
          ProductsTableColumns.totalProduced: 3000,
          ProductsTableColumns.totalSold: 3000,
          ProductsTableColumns.yesterdayProduced: 2500,
          ProductsTableColumns.yesterdaySold: 2500,
          ProductsTableColumns.productPrice: 1.0,
        },
      );

      expect(product.rate, 5.0);
    });

    test('fat sums oil, ghee and butter per unit in the batch', () {
      final product = fakeProduct(
        overrides: {ProductsTableColumns.quantityPerBatch: 10},
      ).copyWith(
        productRecipe: RecipeModel(
          bakeryId: 'b1',
          flourType: 'white',
          oil: 100,
          ghee: 50,
          butter: 50,
        ),
      );

      expect(product.fat, 20.0);
    });

    test('copyWith and equality', () {
      final product = fakeProduct();

      expect(product.copyWith(), product);
      expect(product.copyWith().hashCode, product.hashCode);
      expect(product.copyWith(productName: 'Other'), isNot(product));
    });
  });

  group('OrderModel', () {
    test('totalBill adds the delivery fee to the order price', () {
      final order = fakeOrder().copyWith(orderPrice: 100, deliveryFee: 12.5);

      expect(order.totalBill, 112.5);
    });

    test('fromJson falls back to defaults', () {
      final order = OrderModel.fromJson({});

      expect(order.orderId, isNull);
      expect(order.orderStatus, OrderStatuses.pending);
      expect(order.bakeries, isEmpty);
      expect(order.orderedProducts, isEmpty);
      expect(order.orderedQuantities, isEmpty);
      expect(order.received, isEmpty);
      expect(order.receivedProducts, isNull);
      expect(order.date, isNull);
      expect(order.orderPrice, 0.0);
    });

    test('toJson omits optional fields that are null', () {
      final json = fakeOrder().toJson();

      expect(json.containsKey(OrdersTableColumns.orderId), false);
      expect(json.containsKey(OrdersTableColumns.deliveryManId), false);
      expect(json.containsKey(OrdersTableColumns.receivedProducts), false);
      expect(json.containsKey(OrdersTableColumns.date), false);
      expect(json.containsKey(OrdersTableColumns.street), false);
    });

    test('round trips through json', () {
      final date = DateTime(2026, 9, 21, 10);
      final order = OrderModel(
        orderId: 'o1',
        customerId: 'c1',
        customerName: 'Customer',
        bakeries: [fakeBakery('b1', 30, 31)],
        deliveryManId: 'd1',
        deliveryManName: 'Driver',
        customerLat: 30.1,
        customerLng: 31.1,
        orderedProducts: [fakeProduct()],
        orderedQuantities: const [3],
        receivedProducts: [fakeProduct()],
        receivedQuantities: const [2],
        received: const [true],
        orderPrice: 60,
        deliveryFee: 10,
        orderStatus: OrderStatuses.accepted,
        date: date,
        street: 'S',
        building: 'B',
        apartment: 'A',
      );

      final parsed = OrderModel.fromJson(order.toJson());

      expect(parsed.orderId, 'o1');
      expect(parsed.customerId, 'c1');
      expect(parsed.bakeries, order.bakeries);
      expect(parsed.deliveryManId, 'd1');
      expect(parsed.orderedProducts.map((p) => p.productId), ['p1']);
      expect(parsed.orderedQuantities, [3]);
      expect(parsed.receivedQuantities, [2]);
      expect(parsed.received, [true]);
      expect(parsed.orderPrice, 60);
      expect(parsed.deliveryFee, 10);
      expect(parsed.orderStatus, OrderStatuses.accepted);
      expect(parsed.date, date);
      expect(parsed.street, 'S');
    });

    test('copyWith and equality', () {
      final order = fakeOrder(bakeries: [fakeBakery('b1', 1, 2)]);

      expect(order.copyWith(), order);
      expect(order.copyWith().hashCode, order.hashCode);
      expect(order.copyWith(orderStatus: OrderStatuses.delivered), isNot(order));
    });
  });

  group('HomeDataBakeriesModel', () {
    test('bakeryRate is zero without products', () {
      final model = HomeDataBakeriesModel(
        bakeryModel: fakeBakery('b1', 0, 0),
        productModelList: const [],
      );

      expect(model.bakeryRate, 0.0);
    });

    test('bakeryRate averages product rates to one decimal', () {
      final top = fakeProduct(
        id: 'p1',
        overrides: {
          ProductsTableColumns.totalProduced: 3000,
          ProductsTableColumns.totalSold: 3000,
          ProductsTableColumns.yesterdayProduced: 2500,
          ProductsTableColumns.yesterdaySold: 2500,
        },
      );
      final average = fakeProduct(
        id: 'p2',
        overrides: {
          ProductsTableColumns.totalProduced: 100,
          ProductsTableColumns.totalSold: 100,
          ProductsTableColumns.yesterdayProduced: 50,
          ProductsTableColumns.yesterdaySold: 50,
        },
      );
      final model = HomeDataBakeriesModel(
        bakeryModel: fakeBakery('b1', 0, 0),
        productModelList: [top, average],
      );

      expect(model.bakeryRate, 3.9);
    });

    test('round trips through json', () {
      final model = HomeDataBakeriesModel(
        bakeryModel: fakeBakery('b1', 1, 2),
        productModelList: [fakeProduct()],
      );

      final json = model.toJson();
      final parsed = HomeDataBakeriesModel.fromJson(json);

      expect(json.containsKey(HomeScreenTableColumns.bakery), true);
      expect(json.containsKey(HomeScreenTableColumns.products), true);
      expect(parsed.bakeryModel, model.bakeryModel);
      expect(parsed.productModelList.map((p) => p.productId), ['p1']);
    });

    test('copyWith replaces only the given field', () {
      final model = HomeDataBakeriesModel(
        bakeryModel: fakeBakery('b1', 1, 2),
        productModelList: [fakeProduct()],
      );

      final copy = model.copyWith(productModelList: const []);

      expect(copy.productModelList, isEmpty);
      expect(copy.bakeryModel, model.bakeryModel);
    });
  });
}