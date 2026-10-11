import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/data/home_repo.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/home_data_cubit/home_data_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/home_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/di_overrides.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

class MockCartCubit extends Mock implements CartCubit {}

final Finder drawerScaffold = find.byWidgetPredicate(
      (w) => w is Scaffold && w.drawer != null,
);
final Finder dialogFields = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byType(TextFormField),
);
final Finder dialogDone = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byIcon(Icons.done),
);
final Finder dialogBack = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byIcon(Icons.arrow_back),
);

void main() {
  late MockHomeRepo repo;
  late MockCartCubit cartCubit;
  late ActiveOrdersCubit activeOrders;
  late UserModel user;
  HomeDataCubit? homeCubit;

  setUpAll(() async {
    await setupTestEnvironment();
    registerFallbackValue(
      UserModel(firstName: '', secondName: '', email: '', phone: ''),
    );
  });

  setUp(() {
    ensureImageCubitFactory();
    repo = MockHomeRepo();
    cartCubit = MockCartCubit();
    activeOrders = ActiveOrdersCubit(repo);
    user = UserModel(
      id: 'u1',
      firstName: 'Ali',
      secondName: 'Hassan',
      email: 'ali@test.com',
      phone: '0100',
      street: 'Main St',
      building: '12',
      apartment: '4B',
    );
    when(() => repo.getUserData())
        .thenAnswer((_) async => SuccessResponse<UserModel>(user));
    when(() => repo.getBakeries()).thenAnswer(
          (_) async => SuccessResponse<List<HomeDataBakeriesModel>>(
        <HomeDataBakeriesModel>[],
      ),
    );
    when(() => repo.streamActiveOrders())
        .thenAnswer((_) => const Stream<List<OrderModel>>.empty());
    when(() => repo.logout()).thenAnswer((_) async {});
    when(
          () => repo.changeUserData(updatedUserData: any(named: 'updatedUserData')),
    ).thenAnswer((_) async => SuccessResponse<bool>(true));
  });

  tearDown(() async {
    await homeCubit?.close();
    await activeOrders.close();
    await removeSingleton<ActiveOrdersCubit>();
  });

  Future<void> pumpScreen(WidgetTester tester, {bool settle = true}) async {
    useTallSurface(tester, size: const Size(900, 1800));
    await overrideSingleton<ActiveOrdersCubit>(activeOrders);
    homeCubit = HomeDataCubit(repo, activeOrders, cartCubit);
    await pumpLocalizedWidget(
      tester,
      Navigator(
        initialRoute: '/home-under-test',
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => settings.name == '/home-under-test'
              ? BlocProvider<HomeDataCubit>.value(
            value: homeCubit!,
            child: const HomeTabScreen(),
          )
              : const Scaffold(body: Text('splash-route')),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<void> openDrawer(WidgetTester tester) async {
    tester.state<ScaffoldState>(drawerScaffold).openDrawer();
    await tester.pumpAndSettle();
  }

  Future<void> openNameDialog(WidgetTester tester) async {
    await openDrawer(tester);
    await tester.tap(find.byIcon(Icons.edit).at(1));
    await tester.pumpAndSettle();
  }

  Future<void> openAddressDialog(WidgetTester tester) async {
    await openDrawer(tester);
    await tester.tap(find.byIcon(Icons.edit).at(2));
    await tester.pumpAndSettle();
  }

  UserModel capturedUser() {
    return verify(
          () => repo.changeUserData(
        updatedUserData: captureAny(named: 'updatedUserData'),
      ),
    ).captured.single as UserModel;
  }

  group('body states', () {
    testWidgets('a failed fetch shows the offline view and retries on tap',
            (tester) async {
          when(() => repo.getUserData())
              .thenAnswer((_) async => FailureResponse<UserModel>('offline'));

          await pumpScreen(tester);
          expect(find.byIcon(Icons.cell_tower), findsOneWidget);

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pumpAndSettle();

          verify(() => repo.getUserData()).called(2);
        });

    testWidgets('no nearby bakeries shows the empty view and retries on tap',
            (tester) async {
          await pumpScreen(tester);
          expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pumpAndSettle();

          verify(() => repo.getBakeries()).called(2);
        });
  });

  group('drawer', () {
    testWidgets('shows the user name and address', (tester) async {
      await pumpScreen(tester);
      await openDrawer(tester);

      expect(find.text('Ali Hassan'), findsOneWidget);
      expect(find.text('Main St'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('4B'), findsOneWidget);
    });

    testWidgets('logout calls the repo and replaces the route',
            (tester) async {
          await pumpScreen(tester);
          await openDrawer(tester);

          await tester.tap(find.byIcon(Icons.logout));
          await tester.pumpAndSettle();

          verify(() => repo.logout()).called(1);
          expect(find.text('splash-route'), findsOneWidget);
        });

    testWidgets('the language switch toggles the label', (tester) async {
      await pumpScreen(tester);
      await openDrawer(tester);
      expect(find.text('العربية'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
    });
  });

  group('name dialog', () {
    testWidgets('opens prefilled with the current names', (tester) async {
      await pumpScreen(tester);
      await openNameDialog(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(dialogFields, findsNWidgets(2));
      expect(
        find.descendant(of: find.byType(AlertDialog), matching: find.text('Ali')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Hassan'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the confirm button is hidden until a name changes',
            (tester) async {
          await pumpScreen(tester);
          await openNameDialog(tester);
          expect(dialogDone, findsNothing);

          await tester.enterText(dialogFields.at(0), 'Ali');
          await tester.pumpAndSettle();
          expect(dialogDone, findsNothing);

          await tester.enterText(dialogFields.at(0), '');
          await tester.pumpAndSettle();
          expect(dialogDone, findsNothing);

          await tester.enterText(dialogFields.at(0), 'Omar');
          await tester.pumpAndSettle();
          expect(dialogDone, findsOneWidget);
        });

    testWidgets('confirming saves the capitalized names and closes',
            (tester) async {
          await pumpScreen(tester);
          await openNameDialog(tester);

          await tester.enterText(dialogFields.at(0), 'omar');
          await tester.enterText(dialogFields.at(1), 'khaled');
          await tester.pumpAndSettle();
          await tester.tap(dialogDone);
          await tester.pumpAndSettle();

          final saved = capturedUser();
          expect(saved.firstName, 'Omar');
          expect(saved.secondName, 'Khaled');
          expect(find.byType(AlertDialog), findsNothing);
        });

    testWidgets('changing only the first name keeps the second name',
            (tester) async {
          await pumpScreen(tester);
          await openNameDialog(tester);

          await tester.enterText(dialogFields.at(0), 'omar');
          await tester.pumpAndSettle();
          await tester.tap(dialogDone);
          await tester.pumpAndSettle();

          final saved = capturedUser();
          expect(saved.firstName, 'Omar');
          expect(saved.secondName, 'Hassan');
        });

    testWidgets('the back arrow closes without saving', (tester) async {
      await pumpScreen(tester);
      await openNameDialog(tester);

      await tester.enterText(dialogFields.at(0), 'omar');
      await tester.pumpAndSettle();
      await tester.tap(dialogBack);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      verifyNever(
            () =>
            repo.changeUserData(updatedUserData: any(named: 'updatedUserData')),
      );
    });
  });

  group('address dialog', () {
    testWidgets('opens prefilled with the current address', (tester) async {
      await pumpScreen(tester);
      await openAddressDialog(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(dialogFields, findsNWidgets(3));
      for (final value in ['Main St', '12', '4B']) {
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(value),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('the confirm button is hidden until a field changes',
            (tester) async {
          await pumpScreen(tester);
          await openAddressDialog(tester);
          expect(dialogDone, findsNothing);

          await tester.enterText(dialogFields.at(1), '99');
          await tester.pumpAndSettle();
          expect(dialogDone, findsOneWidget);

          await tester.enterText(dialogFields.at(1), '12');
          await tester.pumpAndSettle();
          expect(dialogDone, findsNothing);
        });

    testWidgets('confirming saves all three address fields', (tester) async {
      await pumpScreen(tester);
      await openAddressDialog(tester);

      await tester.enterText(dialogFields.at(1), '99');
      await tester.pumpAndSettle();
      await tester.tap(dialogDone);
      await tester.pumpAndSettle();

      final saved = capturedUser();
      expect(saved.street, 'Main St');
      expect(saved.building, '99');
      expect(saved.apartment, '4B');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('the back arrow closes without saving', (tester) async {
      await pumpScreen(tester);
      await openAddressDialog(tester);

      await tester.enterText(dialogFields.at(0), 'Other St');
      await tester.pumpAndSettle();
      await tester.tap(dialogBack);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      verifyNever(
            () =>
            repo.changeUserData(updatedUserData: any(named: 'updatedUserData')),
      );
    });
  });
}