import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/history_filter_cubit/history_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/shift_history_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

void main() {
  late MockWorkerRepo repo;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockWorkerRepo();
  });

  Future<HistoryFilterCubit> buildReady(WidgetTester tester) async {
    late HistoryFilterCubit cubit;
    await tester.runAsync(() async {
      cubit = HistoryFilterCubit(repo);
      await pumpEventQueue();
    });
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> pumpTile(WidgetTester tester, HistoryFilterCubit cubit) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<HistoryFilterCubit>.value(
          value: cubit,
          child: const ShiftHistoryTile(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a batch-based shift from this month', (tester) async {
    final now = DateTime.now();
    when(() => repo.fetchMyShifts()).thenAnswer(
          (_) async => SuccessResponse<List<ShiftModel>?>([
        fakeShift().copyWith(
          date: now,
          role: const ['chef'],
          numberOfBatches: const [3],
          rate: null,
        ),
      ]),
    );
    final cubit = await buildReady(tester);

    await pumpTile(tester, cubit);

    expect(find.text('3'), findsOneWidget);
    expect(find.text('chef'.tr()), findsOneWidget);
  });

  testWidgets('shows a rate percentage for a daily-payment shift with no batches',
          (tester) async {
        final now = DateTime.now();
        when(() => repo.fetchMyShifts()).thenAnswer(
              (_) async => SuccessResponse<List<ShiftModel>?>([
            fakeShift().copyWith(
              date: now,
              role: const ['chef'],
              numberOfBatches: const [],
              rate: 0.5,
            ),
          ]),
        );
        final cubit = await buildReady(tester);

        await pumpTile(tester, cubit);

        expect(find.textContaining('50%'), findsOneWidget);
      });

  testWidgets('shows a roles-overflow icon instead of text when there are multiple roles',
          (tester) async {
        final now = DateTime.now();
        when(() => repo.fetchMyShifts()).thenAnswer(
              (_) async => SuccessResponse<List<ShiftModel>?>([
            fakeShift().copyWith(
              date: now,
              role: const ['chef', 'baker'],
              numberOfBatches: const [2, 1],
            ),
          ]),
        );
        final cubit = await buildReady(tester);

        await pumpTile(tester, cubit);

        expect(find.byIcon(Icons.more_horiz), findsOneWidget);
        expect(find.text('chef'), findsNothing);
      });

  testWidgets('tapping the roles icon opens a dialog listing every role',
          (tester) async {
        final now = DateTime.now();
        when(() => repo.fetchMyShifts()).thenAnswer(
              (_) async => SuccessResponse<List<ShiftModel>?>([
            fakeShift().copyWith(
              date: now,
              role: const ['chef', 'baker'],
              numberOfBatches: const [2, 1],
            ),
          ]),
        );
        final cubit = await buildReady(tester);
        await pumpTile(tester, cubit);

        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();

        expect(find.text('chef'), findsOneWidget);
        expect(find.text('baker'), findsOneWidget);
      });

  testWidgets('switching to a month with no shifts shows the empty state',
          (tester) async {
        final now = DateTime.now();
        when(() => repo.fetchMyShifts()).thenAnswer(
              (_) async => SuccessResponse<List<ShiftModel>?>([
            fakeShift().copyWith(date: now, role: const ['chef']),
          ]),
        );
        final cubit = await buildReady(tester);
        await pumpTile(tester, cubit);
        expect(find.byIcon(Icons.assignment_late_outlined), findsNothing);

        final otherMonth = now.month == 1 ? 2 : 1;
        cubit.filterByMonth(otherMonth);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.assignment_late_outlined), findsNWidgets(3));
      });
}