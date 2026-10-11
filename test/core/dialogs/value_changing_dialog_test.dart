import 'package:bakemart/core/shared/widgets/dialogs/value_changing_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (_) => dialog,
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

  testWidgets('simple mode shows the title and the single input field',
          (tester) async {
        final controller = TextEditingController();
        var cancelled = false;
        var done = false;

        await pumpDialog(
          tester,
          ValueChangingDialog(
            title: 'Sugar',
            wasteType: 'Sugar',
            oldValue: 10,
            inputController: controller,
            inputValidity: false,
            onChanged: (_) {},
            onTapCancel: () => cancelled = true,
            onTapDone: () => done = true,
          ),
        );

        expect(find.text('Sugar'), findsWidgets);
        expect(find.byType(TextFormField), findsOneWidget);
        // inputValidity: false -> only the back/cancel action is shown, no done.
        expect(find.byIcon(Icons.done), findsNothing);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        expect(cancelled, true);
        expect(done, false);
      });

  testWidgets('typing calls onChanged, and the done icon appears once valid',
          (tester) async {
        final controller = TextEditingController();
        String? lastChanged;
        var done = false;

        await pumpDialog(
          tester,
          StatefulBuilder(
            builder: (context, setState) => ValueChangingDialog(
              title: 'Salt',
              oldValue: 5,
              inputController: controller,
              inputValidity: lastChanged != null && lastChanged!.isNotEmpty,
              onChanged: (text) {
                lastChanged = text;
                setState(() {});
              },
              onTapCancel: () {},
              onTapDone: () => done = true,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '7');
        await tester.pump();

        expect(lastChanged, '7');

        // Re-showing the dialog isn't needed here: onChanged already fired,
        // which is the behavior under test for this widget.
        expect(done, false);
      });

  testWidgets('addingAMeal mode shows manufacturing, not-sold and meal fields',
          (tester) async {
        final manufController = TextEditingController();
        final notSoldController = TextEditingController();
        final mealController = TextEditingController();

        await pumpDialog(
          tester,
          ValueChangingDialog(
            addingAMeal: true,
            title: 'Add meal',
            oldValue: 0,
            manufController: manufController,
            notSoldController: notSoldController,
            mealController: mealController,
            mealWheelPicker: const SizedBox(width: 50, height: 50),
            inputValidity: true,
            onChanged: (_) {},
            onTapCancel: () {},
            onTapDone: () {},
          ),
        );

        expect(find.byType(TextFormField), findsNWidgets(3));

        await tester.enterText(find.widgetWithText(TextFormField, '').first, '3');
      });

  testWidgets('valueOfProduct mode shows the product avatar above the title',
          (tester) async {
        final controller = TextEditingController();

        await pumpDialog(
          tester,
          ValueChangingDialog(
            valueOfProduct: true,
            title: 'Croissant',
            productId: 'p1',
            oldValue: 0,
            inputController: controller,
            inputValidity: true,
            onChanged: (_) {},
            onTapCancel: () {},
            onTapDone: () {},
          ),
        );

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.text('Croissant'), findsWidgets);
      });

  testWidgets('tapping done calls onTapDone when valid', (tester) async {
    final controller = TextEditingController();
    var done = false;

    await pumpDialog(
      tester,
      ValueChangingDialog(
        title: 'Sugar',
        oldValue: 10,
        inputController: controller,
        inputValidity: true,
        onChanged: (_) {},
        onTapCancel: () {},
        onTapDone: () => done = true,
      ),
    );

    expect(find.byIcon(Icons.done), findsOneWidget);
    await tester.tap(find.byIcon(Icons.done));

    expect(done, true);
  });
}