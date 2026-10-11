import 'package:bakemart/features/onboarding/logic/onboarding_cubit/onboarding_cubit.dart';
import 'package:bakemart/features/onboarding/ui/onboarding_screen.dart';
import 'package:bakemart/features/onboarding/data/onboarding_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  final nextButtonFinder = find.text('Next');
  final getStartedFinder = find.text('Get started');
  final backArrowFinder = find.byIcon(Icons.arrow_back);

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    // OnboardingScreen resolves its cubit via
    // DependencyInjection.getIt<OnboardingCubit>() internally, so the
    // factory has to be registered on the same GetIt.instance for the
    // widget to build at all.
    if (GetIt.instance.isRegistered<OnboardingCubit>()) {
      GetIt.instance.unregister<OnboardingCubit>();
    }
    GetIt.instance.registerFactory<OnboardingCubit>(() => OnboardingCubit());
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<OnboardingCubit>()) {
      GetIt.instance.unregister<OnboardingCubit>();
    }
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(tester, const OnboardingScreen());
    await tester.pumpAndSettle();
  }

  testWidgets('renders the first page with no back arrow', (tester) async {
    await pumpScreen(tester);

    expect(find.text(onboardingPages[0].title), findsOneWidget);
    expect(find.text(onboardingPages[0].description), findsOneWidget);
    expect(nextButtonFinder, findsOneWidget);
    expect(getStartedFinder, findsNothing);
    expect(backArrowFinder, findsNothing);
  });

  testWidgets('Next advances to the next page and reveals the back arrow',
          (tester) async {
        await pumpScreen(tester);

        await tester.ensureVisible(nextButtonFinder);
        await tester.tap(nextButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text(onboardingPages[1].title), findsOneWidget);
        expect(find.text(onboardingPages[1].description), findsOneWidget);
        expect(backArrowFinder, findsOneWidget);
      });

  testWidgets('the back arrow returns to the previous page', (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(nextButtonFinder);
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(backArrowFinder);
    await tester.pumpAndSettle();

    expect(find.text(onboardingPages[0].title), findsOneWidget);
    expect(backArrowFinder, findsNothing);
  });

  testWidgets('the last page shows Get started instead of Next',
          (tester) async {
        await pumpScreen(tester);

        // onboardingPages has 7 entries (indices 0-6): tap Next 6 times to land
        // on the last page.
        for (var i = 0; i < onboardingPages.length - 1; i++) {
          await tester.ensureVisible(nextButtonFinder);
          await tester.tap(nextButtonFinder);
          await tester.pumpAndSettle();
        }

        expect(find.text(onboardingPages.last.title), findsOneWidget);
        expect(find.text(onboardingPages.last.description), findsOneWidget);
        expect(getStartedFinder, findsOneWidget);
        expect(nextButtonFinder, findsNothing);
        // Deliberately not tapping "Get started": it calls Bingo.mark(...)
        // directly inside the widget with no injection point, and Bingo isn't
        // set up in this test environment (only main.dart calls
        // Bingo.setup()). If you want that final navigation covered, expose a
        // way to fake/skip Bingo in tests and I'll add it.
      });
}