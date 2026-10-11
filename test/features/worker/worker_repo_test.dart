import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/payrolls_table_columns.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/staffs_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late MockUser authUser;
  late MockSupabaseQueryBuilder usersQuery;
  late MockSupabaseQueryBuilder staffsQuery;
  late MockSupabaseQueryBuilder bakeriesQuery;
  late MockSupabaseQueryBuilder ordersQuery;
  late MockSupabaseQueryBuilder payrollsQuery;
  late WorkerRepo repo;

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);
    registerFallbackValue(fakeStaff());
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    authUser = MockUser();
    usersQuery = MockSupabaseQueryBuilder();
    staffsQuery = MockSupabaseQueryBuilder();
    bakeriesQuery = MockSupabaseQueryBuilder();
    ordersQuery = MockSupabaseQueryBuilder();
    payrollsQuery = MockSupabaseQueryBuilder();
    when(() => supabase.auth).thenAnswer((_) => auth);
    when(() => auth.currentUser).thenAnswer((_) => authUser);
    when(() => authUser.id).thenAnswer((_) => 'worker-1');
    when(() => supabase.from(Tables.users)).thenAnswer((_) => usersQuery);
    when(() => supabase.from(Tables.staffs)).thenAnswer((_) => staffsQuery);
    when(() => supabase.from(Tables.bakeries)).thenAnswer((_) => bakeriesQuery);
    when(() => supabase.from(Tables.orders)).thenAnswer((_) => ordersQuery);
    when(() => supabase.from(Tables.payrolls)).thenAnswer((_) => payrollsQuery);
    repo = WorkerRepo(supabase: supabase);
  });

  test('getUserData returns the parsed user', () async {
    when(() => usersQuery.select()).thenAnswer(
          (_) => FakePostgrestBuilder<PostgrestList>.value(
        const <Map<String, dynamic>>[],
        single: UserModel(
          id: 'worker-1',
          firstName: 'Mo',
          secondName: 'Men',
          email: 'a@b.c',
          phone: '1',
        ).toJson(),
      ),
    );

    final result = await repo.getUserData();

    expect((result as SuccessResponse<UserModel>).data.id, 'worker-1');
  });

  test('quit deletes the staff row and fails without an id', () async {
    when(() => staffsQuery.delete()).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.value(null),
    );

    expect(await repo.quit(), isA<SuccessResponse<bool>>());

    when(() => auth.currentUser).thenAnswer((_) => null);
    final result = await repo.quit();
    expect(result, isA<FailureResponse<bool>>());
  });

  group('checkStaffTable', () {
    test('returns null when not staff anywhere', () async {
      when(() => staffsQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: null,
        ),
      );

      final result = await repo.checkStaffTable();

      expect((result as SuccessResponse<StaffModel?>).data, isNull);
    });

    test('returns the staff row when employed', () async {
      when(() => staffsQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: fakeStaff(bakeryId: 'b1').toJson(),
        ),
      );

      final result = await repo.checkStaffTable();

      expect((result as SuccessResponse<StaffModel?>).data!.bakeryId, 'b1');
    });

    test('fails without a signed-in user', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      final result = await repo.checkStaffTable();

      expect(result, isA<FailureResponse<StaffModel?>>());
    });
  });

  test('getBakeryData parses the requested bakery', () async {
    when(() => bakeriesQuery.select()).thenAnswer(
          (_) => FakePostgrestBuilder<PostgrestList>.value(
        const <Map<String, dynamic>>[],
        single: fakeBakery('b1', 1, 2).toJson(),
      ),
    );

    final result = await repo.getBakeryData('b1');

    expect((result as SuccessResponse<BakeryModel>).data.bakeryId, 'b1');
  });

  group('checkDeliveryManQrCode', () {
    test('returns the user for a valid id', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: UserModel(
            id: 'd1',
            firstName: 'D',
            secondName: 'M',
            email: 'd@m.c',
            phone: '1',
          ).toJson(),
        ),
      );

      final result = await repo.checkDeliveryManQrCode('d1');

      expect((result as SuccessResponse<UserModel>).data.id, 'd1');
    });

    test('fails when nobody matches', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: null,
        ),
      );

      final result = await repo.checkDeliveryManQrCode('nobody');

      expect((result as FailureResponse<UserModel>).error, 'User not found!');
    });
  });

  group('fetchAllOrdersOfThisDeliveryMan', () {
    test('keeps only unreceived orders that include this bakery', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: UserModel(
            id: 'd1',
            firstName: 'D',
            secondName: 'M',
            email: 'd@m.c',
            phone: '1',
          ).toJson(),
        ),
      );
      final bakery = fakeBakery('b1', 0, 0);
      final matchingOrder = OrderModel(
        customerId: 'c1',
        customerName: 'C',
        bakeries: [bakery],
        customerLat: 0,
        customerLng: 0,
        orderedProducts: [
          fakeProduct(
            id: 'p1',
            bakeryId: 'b1',
            overrides: {ProductsTableColumns.productPrice: 10.0},
          ),
        ],
        orderedQuantities: const [3],
        received: const [false],
        orderPrice: 30,
        deliveryFee: 0,
        orderStatus: OrderStatuses.accepted,
      );
      final receivedOrder = matchingOrder.copyWith(
        orderId: 'received',
        received: const [true],
      );
      when(() => ordersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value([
          matchingOrder.toJson(),
          receivedOrder.toJson(),
        ]),
      );

      final result = await repo.fetchAllOrdersOfThisDeliveryMan(
        deliveryManId: 'd1',
        bakeryId: 'b1',
      );

      final orders = (result as SuccessResponse<List<OrderModel>>).data;
      expect(orders, hasLength(1));
      expect(orders.single.orderedProducts.single.productId, 'p1');
      expect(orders.single.orderedQuantities, [3]);
      expect(orders.single.orderPrice, 30);
    });

    test('fails when the delivery man id does not resolve', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: null,
        ),
      );

      final result = await repo.fetchAllOrdersOfThisDeliveryMan(
        deliveryManId: 'unknown',
        bakeryId: 'b1',
      );

      expect(result, isA<FailureResponse<List<OrderModel>>>());
    });
  });

  group('fetchPayroll', () {
    test('returns the parsed payroll', () async {
      when(() => payrollsQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: fakePayroll(bakeryId: 'b1').toJson(),
        ),
      );

      final result = await repo.fetchPayroll('b1');

      expect((result as SuccessResponse<PayrollModel?>).data!.bakeryId, 'b1');
    });

    test('fails when there is no payroll row', () async {
      when(() => payrollsQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: null,
        ),
      );

      final result = await repo.fetchPayroll('b1');

      expect((result as FailureResponse<PayrollModel?>).error, 'Payroll not found');
    });
  });

  group('calculateWage', () {
    test('sums each role at its rate times its batches', () {
      final payroll = fakePayroll(
        chef: 10,
        coChef: 5,
        supervisor: 100,
      );

      final wage = repo.calculateWage(
        roles: [
          PayrollsTableColumns.chef,
          PayrollsTableColumns.coChef,
          PayrollsTableColumns.supervisor,
        ],
        numberOfBatches: [3, 2, 1],
        payroll: payroll,
      );

      expect(wage, 10 * 3 + 5 * 2 + 100 * 1);
    });

    test('treats a missing rate as zero', () {
      final wage = repo.calculateWage(
        roles: [PayrollsTableColumns.chef],
        numberOfBatches: [5],
        payroll: fakePayroll(),
      );

      expect(wage, 0.0);
    });
  });

  group('mergeShifts', () {
    test('stamps wages onto a fresh batch when there is no history', () {
      final payroll = fakePayroll(chef: 10);
      final newShift = fakeShift(
        workerId: 'w1',
        role: const [PayrollsTableColumns.chef],
        numberOfBatches: const [2],
      );

      final merged = repo.mergeShifts(
        existingShifts: null,
        newBatchShift: [newShift],
        payroll: payroll,
      );

      expect(merged.single.wage, 20);
    });

    test('adds batches for a worker who already has a shift today', () {
      final payroll = fakePayroll(chef: 10);
      final existing = fakeShift(
        workerId: 'w1',
        role: const [PayrollsTableColumns.chef],
        numberOfBatches: const [2],
        wage: 20,
      );
      final more = fakeShift(
        workerId: 'w1',
        role: const [PayrollsTableColumns.chef],
        numberOfBatches: const [3],
      );

      final merged = repo.mergeShifts(
        existingShifts: [existing],
        newBatchShift: [more],
        payroll: payroll,
      );

      expect(merged.single.numberOfBatches.single, 5);
      expect(merged.single.wage, 50);
    });

    test('adds a new worker entry alongside existing shifts', () {
      final payroll = fakePayroll(chef: 10);
      final existing = fakeShift(
        workerId: 'w1',
        role: const [PayrollsTableColumns.chef],
        numberOfBatches: const [2],
        wage: 20,
      );
      final newWorker = fakeShift(
        workerId: 'w2',
        role: const [PayrollsTableColumns.chef],
        numberOfBatches: const [1],
      );

      final merged = repo.mergeShifts(
        existingShifts: [existing],
        newBatchShift: [newWorker],
        payroll: payroll,
      );

      expect(merged.map((s) => s.workerId).toSet(), {'w1', 'w2'});
    });
  });

  group('filterShiftsByDate', () {
    test('keeps only shifts on the selected day', () {
      final matching = fakeShift(date: DateTime(2026, 9, 21, 8));
      final other = fakeShift(date: DateTime(2026, 9, 22));

      final result = repo.filterShiftsByDate(
        allShifts: [matching, other],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect((result as SuccessResponse).data, [matching]);
    });
  });

  group('filterExpensesByDate', () {
    test('returns the matching finance record', () {
      final matching = fakeFinance(date: DateTime(2026, 9, 21, 8));

      final result = repo.filterExpensesByDate(
        allExpenses: [matching, fakeFinance(date: DateTime(2026, 9, 22))],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect((result as SuccessResponse).data, matching);
    });

    test('fails when nothing matches the day', () {
      final result = repo.filterExpensesByDate(
        allExpenses: [fakeFinance(date: DateTime(2026, 9, 22))],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect(result, isA<FailureResponse>());
    });
  });

  group('isBakeryReceived / isOrderFullyReceived', () {
    test('isBakeryReceived checks the flag at the bakery index', () {
      final order = fakeOrder(
        bakeries: [fakeBakery('b1', 0, 0), fakeBakery('b2', 0, 0)],
      ).copyWith(received: const [true, false]);

      expect(repo.isBakeryReceived(order, 'b1'), true);
      expect(repo.isBakeryReceived(order, 'b2'), false);
      expect(repo.isBakeryReceived(order, 'missing'), false);
    });

    test('isOrderFullyReceived requires every flag true', () {
      final full = fakeOrder().copyWith(received: const [true, true]);
      final partial = fakeOrder().copyWith(received: const [true, false]);

      expect(repo.isOrderFullyReceived(full), true);
      expect(repo.isOrderFullyReceived(partial), false);
    });
  });

  group('join', () {
    test('fails when the scanned code is empty', () async {
      final scan = BarcodeCapture(barcodes: [Barcode(rawValue: null)]);

      final result = await repo.join(scan);

      expect((result as FailureResponse<bool>).error, 'Scan failed!');
    });

    test('fails when the bakery is not found', () async {
      when(() => bakeriesQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: null,
        ),
      );
      final scan = BarcodeCapture(barcodes: [Barcode(rawValue: 'b1')]);

      final result = await repo.join(scan);

      expect((result as FailureResponse<bool>).error, 'Bakery not found!');
    });

    test('joins the bakery as staff on a successful scan', () async {
      when(() => bakeriesQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: fakeBakery('b1', 0, 0).toJson(),
        ),
      );
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: UserModel(
            id: 'worker-1',
            firstName: 'Mo',
            secondName: 'Men',
            email: 'a@b.c',
            phone: '1',
          ).toJson(),
        ),
      );
      when(() => staffsQuery.insert(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );
      final scan = BarcodeCapture(barcodes: [Barcode(rawValue: 'b1')]);

      final result = await repo.join(scan);

      expect(result, isA<SuccessResponse<bool>>());
      final sent = Map<String, dynamic>.from(
        verify(() => staffsQuery.insert(captureAny())).captured.single
        as Map,
      );
      expect(sent[StaffsTableColumns.workerName], 'Mo Men');
      expect(sent[StaffsTableColumns.bakeryId], 'b1');
    });
  });

  group('acceptOrder-adjacent update paths', () {
    test('updateOrderInDatabase fails when the bakery is not in the order',
            () async {
          final order = fakeOrder(bakeries: [fakeBakery('other', 0, 0)]).copyWith(
            orderId: 'o1',
          );

          final result = await repo.updateOrderInDatabase(
            order: order,
            bakeryId: 'b1',
          );

          expect((result as FailureResponse<bool>).error, 'Bakery not found');
        });
  });
}