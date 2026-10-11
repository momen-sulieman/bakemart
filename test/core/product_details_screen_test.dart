import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/ignore_overflow.dart';
import '../helpers/test_setup.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  Future<void> pumpAndOpen(
      WidgetTester tester, {
        required dynamic product,
        bool statistict = false,
        bool nutrition = true,
      }) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ProductDetailsScreen(
                  product: product,
                  statistict: statistict,
                  nutrition: nutrition,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the product name, price and weight', (tester) async {
    final product = fakeProduct(id: 'p1', bakeryId: 'b1').copyWith(
      productName: 'Croissant',
      productPrice: 4.25,
      productWeight: 80,
    );

    await pumpAndOpen(tester, product: product);

    expect(find.text('Croissant '), findsOneWidget);
    expect(find.text('4.25'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgetsIgnoringOverflow(
      'shows the statistics rows with the product numbers when requested',
          (tester) async {
        final product = fakeProduct(id: 'p1', bakeryId: 'b1').copyWith(
          available: 111,
          totalProduced: 222,
          totalSold: 333,
          notSoldWaste: 444,
          mealsWaste: 555,
          manufacturingWaste: 666,
        );

        await pumpAndOpen(tester, product: product, statistict: true);

        expect(find.text('111'), findsOneWidget);
        expect(find.text('222'), findsOneWidget);
        expect(find.text('333'), findsOneWidget);
        expect(find.text('444'), findsOneWidget);
        expect(find.text('555'), findsOneWidget);
        expect(find.text('666'), findsOneWidget);
      });

  testWidgets('does not render the statistics card by default', (tester) async {
    final product = fakeProduct(id: 'p1', bakeryId: 'b1').copyWith(
      available: 111,
    );

    await pumpAndOpen(tester, product: product);

    expect(find.text('111'), findsNothing);
  });

  testWidgets('the close icon pops the dialog', (tester) async {
    final product = fakeProduct(id: 'p1', bakeryId: 'b1');

    await pumpAndOpen(tester, product: product);
    expect(find.byType(ProductDetailsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailsScreen), findsNothing);
  });
}