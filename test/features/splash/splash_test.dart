import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/splash/data/splash_repo.dart';
import 'package:bakemart/features/splash/logic/splash_cubit/splash_cubit.dart';
import 'package:bakemart/features/splash/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockSplashRepo extends Mock implements SplashRepo {}

class MockSupabaseUser extends Mock implements User {}

void main() {
  late MockSplashRepo repo;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockSplashRepo();
    when(() => repo.getUserData(any()))
        .thenAnswer((_) async => SuccessResponse<bool>(false));
  });

  SplashCubit buildCubit({
    User? Function()? currentUser,
    bool Function()? seenOnboarding,
  }) {
    return SplashCubit(
      repo,
      currentUser: currentUser ?? () => null,
      seenOnboarding: seenOnboarding ?? () => true,
      delay: Duration.zero,
    );
  }

  Future<void> pumpUntil(
      WidgetTester tester,
      bool Function() done, {
        int maxSteps = 20,
        Duration step = const Duration(milliseconds: 50),
      }) async {
    for (var i = 0; i < maxSteps; i++) {
      if (done()) return;
      await tester.pump(step);
    }
  }

  Future<void> pumpScreen(
      WidgetTester tester,
      SplashCubit cubit, {
        List<NavigatorObserver> observers = const [],
      }) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<SplashCubit>.value(
          value: cubit,
          child: const SplashScreen(),
        ),
      ),
      observers: observers,
      settle: false,
    );
  }

  testWidgets('renders the Bakemart brand while routing', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await pumpScreen(tester, cubit);

    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((w) => w.text.toPlainText())
        .join()
        .toLowerCase();
    expect(text, contains('bake'));
    expect(text, contains('mart'));
  });

  testWidgets('routes to sign in when onboarding was seen and no user exists',
          (tester) async {
        final cubit = buildCubit(
          currentUser: () => null,
          seenOnboarding: () => true,
        );
        addTearDown(cubit.close);
        final observer = RouteRecorder();

        await pumpScreen(tester, cubit, observers: [observer]);
        await pumpUntil(tester, () => observer.names.isNotEmpty);

        expect(observer.names, contains('/signIn'));
      });

  testWidgets('routes to home when a verified user is already signed in',
          (tester) async {
        final user = MockSupabaseUser();
        when(() => repo.getUserData(user))
            .thenAnswer((_) async => SuccessResponse<bool>(true));
        final cubit = buildCubit(
          currentUser: () => user,
          seenOnboarding: () => true,
        );
        addTearDown(cubit.close);
        final observer = RouteRecorder();

        await pumpScreen(tester, cubit, observers: [observer]);
        await pumpUntil(tester, () => observer.names.isNotEmpty);

        expect(observer.names, contains('/home'));
      });

  testWidgets('routes to onboarding when it has not been seen yet',
          (tester) async {
        final cubit = buildCubit(seenOnboarding: () => false);
        addTearDown(cubit.close);
        final observer = RouteRecorder();

        await pumpScreen(tester, cubit, observers: [observer]);
        await pumpUntil(tester, () => observer.names.isNotEmpty);

        expect(observer.names, contains('/onBoarding'));
      });

  testWidgets('shows an error snackbar when the user lookup fails',
          (tester) async {
        when(() => repo.getUserData(any()))
            .thenAnswer((_) async => FailureResponse<bool>('offline'));
        final cubit = buildCubit(
          seenOnboarding: () => true,
          currentUser: () => MockSupabaseUser(),
        );
        addTearDown(cubit.close);

        await pumpScreen(tester, cubit);
        await pumpUntil(
          tester,
              () => find.byType(SnackBar).evaluate().isNotEmpty,
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Something went wrong!'), findsOneWidget);
      });
}