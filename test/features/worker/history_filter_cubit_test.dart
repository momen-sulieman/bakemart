import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/history_filter_cubit/history_filter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

class FakeShift extends Fake implements ShiftModel {
  FakeShift(this._date);

  final DateTime? _date;

  @override
  DateTime? get date => _date;
}

void main() {
  late MockWorkerRepo repo;

  final int year = DateTime.now().year.clamp(2026, 2035);
  final int month = DateTime.now().month;
  final int otherMonth = month == 12 ? 1 : month + 1;

  ShiftModel shiftOn(DateTime? date) => FakeShift(date);

  void stubShifts(List<ShiftModel>? shifts) {
    when(() => repo.fetchMyShifts()).thenAnswer(
          (_) async => SuccessResponse<List<ShiftModel>?>(shifts),
    );
  }

  Future<HistoryFilterCubit> createLoaded(List<ShiftModel>? shifts) async {
    stubShifts(shifts);
    final cubit = HistoryFilterCubit(repo);
    await pumpEventQueue();
    return cubit;
  }

  setUp(() {
    repo = MockWorkerRepo();
  });

  group('initial load', () {
    test('is loading synchronously while the fetch is pending', () async {
      final gate = Completer<ResponseResult<List<ShiftModel>?>>();
      when(() => repo.fetchMyShifts()).thenAnswer((_) => gate.future);

      final cubit = HistoryFilterCubit(repo);

      expect(cubit.state, isA<HistoryFilterLoading>());

      gate.complete(SuccessResponse<List<ShiftModel>?>([]));
      await pumpEventQueue();
      await cubit.close();
    });

    test('defaults to the current month and a clamped year', () async {
      final cubit = await createLoaded([]);

      expect(cubit.selectedMonth, month);
      expect(cubit.selectedYear, year);
      expect(cubit.isExpanded, true);

      await cubit.close();
    });

    test('keeps only shifts in the selected month and year', () async {
      final inMonth = shiftOn(DateTime(year, month, 5));
      final alsoInMonth = shiftOn(DateTime(year, month, 20));
      final otherMonthShift = shiftOn(DateTime(year, otherMonth, 5));
      final otherYearShift = shiftOn(DateTime(year + 1, month, 5));

      final cubit = await createLoaded([
        inMonth,
        otherMonthShift,
        alsoInMonth,
        otherYearShift,
      ]);

      expect(cubit.allShifts, hasLength(4));
      expect(cubit.filteredShifts, [inMonth, alsoInMonth]);
      expect(cubit.state, isA<HistoryFilterSuccess>());
      expect(
        (cubit.state as HistoryFilterSuccess).filteredShifts,
        [inMonth, alsoInMonth],
      );

      await cubit.close();
    });

    test('shifts without a date are filtered out', () async {
      final dated = shiftOn(DateTime(year, month, 5));
      final cubit = await createLoaded([shiftOn(null), dated]);

      expect(cubit.filteredShifts, [dated]);

      await cubit.close();
    });

    test('a null payload becomes an empty successful result', () async {
      final cubit = await createLoaded(null);

      expect(cubit.allShifts, isEmpty);
      expect(cubit.state, isA<HistoryFilterSuccess>());
      expect((cubit.state as HistoryFilterSuccess).filteredShifts, isEmpty);

      await cubit.close();
    });

    test('a failed fetch emits a failure with the error', () async {
      when(() => repo.fetchMyShifts()).thenAnswer(
            (_) async => FailureResponse<List<ShiftModel>?>('boom'),
      );

      final cubit = HistoryFilterCubit(repo);
      await pumpEventQueue();

      expect(cubit.state, isA<HistoryFilterFailure>());
      expect((cubit.state as HistoryFilterFailure).error, 'boom');

      await cubit.close();
    });
  });

  group('filtering', () {
    test('filterByMonth re-filters and emits a success state', () async {
      final current = shiftOn(DateTime(year, month, 5));
      final next = shiftOn(DateTime(year, otherMonth, 9));
      final cubit = await createLoaded([current, next]);
      final emitted = <HistoryFilterState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.filterByMonth(otherMonth);
      await pumpEventQueue();

      expect(cubit.selectedMonth, otherMonth);
      expect(cubit.filteredShifts, [next]);
      expect(emitted, hasLength(1));
      expect(emitted.single, isA<HistoryFilterSuccess>());
      expect((emitted.single as HistoryFilterSuccess).filteredShifts, [next]);

      await sub.cancel();
      await cubit.close();
    });

    test('filterByYear re-filters and emits a success state', () async {
      final current = shiftOn(DateTime(year, month, 5));
      final later = shiftOn(DateTime(year + 1, month, 5));
      final cubit = await createLoaded([current, later]);
      final emitted = <HistoryFilterState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.filterByYear(year + 1);
      await pumpEventQueue();

      expect(cubit.selectedYear, year + 1);
      expect(cubit.filteredShifts, [later]);
      expect(emitted.single, isA<HistoryFilterSuccess>());

      await sub.cancel();
      await cubit.close();
    });

    test('a month with no shifts yields an empty list', () async {
      final cubit = await createLoaded([shiftOn(DateTime(year, month, 5))]);

      cubit.filterByMonth(otherMonth);

      expect(cubit.filteredShifts, isEmpty);

      await cubit.close();
    });

    test('filters are applied together, not individually', () async {
      final target = shiftOn(DateTime(year + 1, otherMonth, 3));
      final cubit = await createLoaded([
        shiftOn(DateTime(year, otherMonth, 3)),
        shiftOn(DateTime(year + 1, month, 3)),
        target,
      ]);

      cubit.filterByMonth(otherMonth);
      cubit.filterByYear(year + 1);

      expect(cubit.filteredShifts, [target]);

      await cubit.close();
    });
  });

  group('tile expansion', () {
    test('updateTileExpansion stores the flag and re-emits current results',
            () async {
          final current = shiftOn(DateTime(year, month, 5));
          final cubit = await createLoaded([current]);
          final emitted = <HistoryFilterState>[];
          final sub = cubit.stream.listen(emitted.add);

          cubit.updateTileExpansion(false);
          await pumpEventQueue();

          expect(cubit.isExpanded, false);
          expect(emitted.single, isA<HistoryFilterSuccess>());
          expect((emitted.single as HistoryFilterSuccess).filteredShifts, [current]);

          await sub.cancel();
          await cubit.close();
        });
  });

  group('closing', () {
    test('a fetch that resolves after close is ignored', () async {
      final gate = Completer<ResponseResult<List<ShiftModel>?>>();
      when(() => repo.fetchMyShifts()).thenAnswer((_) => gate.future);

      final cubit = HistoryFilterCubit(repo);
      await cubit.close();
      gate.complete(
        SuccessResponse<List<ShiftModel>?>([shiftOn(DateTime(year, month, 5))]),
      );
      await pumpEventQueue();

      expect(cubit.allShifts, isEmpty);
      expect(cubit.state, isA<HistoryFilterLoading>());
    });

    test('mutators are no-ops after close', () async {
      final cubit = await createLoaded([shiftOn(DateTime(year, month, 5))]);
      await cubit.close();

      expect(() => cubit.filterByMonth(otherMonth), returnsNormally);
      expect(() => cubit.filterByYear(year + 1), returnsNormally);
      expect(() => cubit.updateTileExpansion(false), returnsNormally);

      expect(cubit.selectedMonth, month);
      expect(cubit.selectedYear, year);
      expect(cubit.isExpanded, true);
    });
  });
}