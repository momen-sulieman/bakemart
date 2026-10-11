import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/quantities_counter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuantitiesCounterCubit cubit;

  setUp(() {
    cubit = QuantitiesCounterCubit();
  });

  tearDown(() {
    cubit.close();
  });

  test('starts at zero for all three counters', () {
    expect(cubit.state, [0, 0, 0]);
  });

  test('sold +/-1, +/-10 and +/-100 only touch index 0', () {
    cubit.soldPlusOne();
    expect(cubit.state, [1, 0, 0]);
    cubit.soldPlusTen();
    expect(cubit.state, [11, 0, 0]);
    cubit.soldPlusHundred();
    expect(cubit.state, [111, 0, 0]);
    cubit.soldMinusHundred();
    expect(cubit.state, [11, 0, 0]);
    cubit.soldMinusTen();
    expect(cubit.state, [1, 0, 0]);
    cubit.soldMinusOne();
    expect(cubit.state, [0, 0, 0]);
  });

  test('notSold +/- only touches index 1', () {
    cubit.notSoldPlusTen();
    cubit.notSoldPlusOne();
    expect(cubit.state, [0, 11, 0]);
    cubit.notSoldMinusOne();
    expect(cubit.state, [0, 10, 0]);
  });

  test('meal +/- only touches index 2', () {
    cubit.mealPlusHundred();
    cubit.mealPlusTen();
    cubit.mealPlusOne();
    expect(cubit.state, [0, 0, 111]);
    cubit.mealMinusTen();
    expect(cubit.state, [0, 0, 101]);
  });

  test('minus does not clamp at zero (matches the widget\'s own guard)', () {
    cubit.soldMinusOne();
    expect(cubit.state, [-1, 0, 0]);
  });
}