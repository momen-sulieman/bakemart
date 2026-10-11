import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/creation_onboarding_pages.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/ui/widgets/creation_onboarding_screen.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/ui/widgets/creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/di_overrides.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryCubit;

  setUpAll(() async {
    await setupTestEnvironment();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    ensureImageCubitFactory();
    bakeryRepo = MockBakeryTabRepo();
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
    when(() => bakeryRepo.fetchBakery())
        .thenAnswer((_) async => SuccessResponse<BakeryModel?>(null));

    bakeryCubit = BakeryTabCubit(
      bakeryRepo,
      locationCubit,
      currentUserId: () => 'owner-1',
    );
    await pumpEventQueue();
    await overrideSingleton<BakeryTabCubit>(bakeryCubit);
    await overrideSingleton<LocationCubit>(locationCubit);
  });

  tearDown(() async {
    await removeSingleton<BakeryTabCubit>();
    await removeSingleton<LocationCubit>();
    await bakeryCubit.close();
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(900, 3000));
    await pumpLocalizedWidget(
      tester,
      const Scaffold(body: CreationOnboardingScreen()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapPrimary(WidgetTester tester) async {
    await tester.tap(find.byType(GlassCard).last);
    await tester.pumpAndSettle();
  }

  Future<void> goToLastPage(WidgetTester tester) async {
    for (var i = 0; i < creationOnboardingPages.length - 1; i++) {
      await tapPrimary(tester);
    }
  }

  testWidgets('starts on the first page without a back button',
          (tester) async {
        await pumpOnboarding(tester);

        expect(find.text(creationOnboardingPages.first.title), findsOneWidget);
        expect(find.text(creationOnboardingPages.first.description), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.byType(GlassCard), findsOneWidget);
        expect(bakeryCubit.currentOnboardingPage, 0);
      });

  testWidgets('the primary button advances to the next page', (tester) async {
    await pumpOnboarding(tester);

    await tapPrimary(tester);

    expect(bakeryCubit.currentOnboardingPage, 1);
    expect(find.text(creationOnboardingPages[1].title), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('the back button returns to the previous page', (tester) async {
    await pumpOnboarding(tester);
    await tapPrimary(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(bakeryCubit.currentOnboardingPage, 0);
    expect(find.text(creationOnboardingPages.first.title), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('the last page shows its own title and both buttons',
          (tester) async {
        await pumpOnboarding(tester);

        await goToLastPage(tester);

        expect(bakeryCubit.currentOnboardingPage,
            creationOnboardingPages.length - 1);
        expect(find.text(creationOnboardingPages.last.title), findsOneWidget);
        expect(find.byType(GlassCard), findsNWidgets(2));
      });

  testWidgets('the primary button on the last page opens the creation form',
          (tester) async {
        await pumpOnboarding(tester);
        await goToLastPage(tester);
        expect(find.byType(CreationScreen), findsNothing);

        await tapPrimary(tester);

        expect(find.byType(CreationScreen), findsOneWidget);
      });
}