import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/features/bakery_details/logic/quantity_counter_cubit/quantity_counter_cubit.dart';
import 'package:bakemart/features/home/logic/home_screen_cubit/home_screen_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/logic/unit_cubit/unit_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/quantities_counter_cubit.dart';
import 'package:bakemart/features/onboarding/logic/onboarding_cubit/onboarding_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ObscurityCubit starts true and toggles', () {
    final cubit = ObscurityCubit();
    addTearDown(cubit.close);

    expect(cubit.state, true);
    cubit.change();
    expect(cubit.state, false);
    cubit.change();
    expect(cubit.state, true);
  });

  group('QuantityCounterCubit', () {
    late QuantityCounterCubit cubit;
    setUp(() => cubit = QuantityCounterCubit());
    tearDown(() => cubit.close());

    test('starts at zero', () => expect(cubit.state, 0));

    test('increments by 1, 10, 100', () {
      cubit.plusOne();
      cubit.plusTen();
      cubit.plusHundred();
      expect(cubit.state, 111);
    });

    test('never goes below zero', () {
      cubit.minusOne();
      cubit.minusTen();
      cubit.minusHundred();
      expect(cubit.state, 0);
    });

    test('minusTen and minusHundred only apply when enough is available', () {
      cubit.plusOne();
      cubit.minusTen();
      expect(cubit.state, 1);

      cubit.plusHundred();
      cubit.minusHundred();
      expect(cubit.state, 1);
    });
  });

  group('QuantitiesCounterCubit', () {
    late QuantitiesCounterCubit cubit;
    setUp(() => cubit = QuantitiesCounterCubit());
    tearDown(() => cubit.close());

    test('starts at [0, 0, 0]', () => expect(cubit.state, [0, 0, 0]));

    test('sold/notSold/meal increments are independent', () {
      cubit.soldPlusOne();
      cubit.notSoldPlusTen();
      cubit.mealPlusHundred();
      expect(cubit.state, [1, 10, 100]);
    });

    test('decrements are independent and unguarded', () {
      cubit.soldMinusOne();
      cubit.notSoldMinusTen();
      cubit.mealMinusHundred();
      expect(cubit.state, [-1, -10, -100]);
    });
  });

  group('UnitCubit', () {
    late UnitCubit cubit;
    setUp(() => cubit = UnitCubit());
    tearDown(() => cubit.close());

    test('starts at kilo (1000)', () => expect(cubit.state, 1000));

    test('switches between gram, kilo and pound', () {
      cubit.gram();
      expect(cubit.state, 1);
      cubit.pound();
      expect(cubit.state, closeTo(453.59237, 0.0001));
      cubit.kilo();
      expect(cubit.state, 1000);
    });
  });

  test('HomeScreenCubit starts on tab 1 and switches tabs', () {
    final cubit = HomeScreenCubit();
    addTearDown(cubit.close);

    expect(cubit.state, 1);
    cubit.changeTab(0);
    expect(cubit.state, 0);
    cubit.changeTab(2);
    expect(cubit.state, 2);
  });

  test('OnboardingCubit starts at page 0 and emits on page change', () {
    final cubit = OnboardingCubit();
    addTearDown(cubit.close);

    expect(cubit.state, 0);
    cubit.pageChanged(2);
    expect(cubit.state, 2);
  });
}