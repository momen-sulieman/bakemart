import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/shared/models/waste_model.dart';


Position fakePosition(double lat, double lng) {
  return Position(
    longitude: lng,
    latitude: lat,
    timestamp: DateTime(2026),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

BakeryModel fakeBakery(String id, double lat, double lng) {
  return BakeryModel(
    bakeryId: id,
    bakeryName: 'Bakery $id',
    bakeryLat: lat,
    bakeryLng: lng,
    supervisorId: const [],
  );
}

ProductModel fakeProduct({
  String id = 'p1',
  String bakeryId = 'b1',
  Map<String, dynamic> overrides = const {},
}) {
  return ProductModel.fromJson({
    ProductsTableColumns.productId: id,
    ProductsTableColumns.bakeryId: bakeryId,
    ProductsTableColumns.productName: 'Product $id',
    ProductsTableColumns.productPrice: 1.0,
    ...overrides,
  });
}

OrderModel fakeOrder({
  List<BakeryModel> bakeries = const [],
  double customerLat = 0,
  double customerLng = 0,
}) {
  return OrderModel(
    customerId: 'c1',
    customerName: 'Customer',
    bakeries: bakeries,
    customerLat: customerLat,
    customerLng: customerLng,
    orderedProducts: const [],
    orderedQuantities: const [],
    received: const [],
    orderPrice: 0,
    deliveryFee: 0,
    orderStatus: OrderStatuses.pending,
  );
}
PayrollModel fakePayroll({
  String bakeryId = 'b1',
  bool payrollMethod = true,
  double? ajan,
  double? faran,
  double? tawlaji,
  double? chef,
  double? coChef,
  double? bagger,
  double? supervisor,
}) {
  return PayrollModel(
    bakeryId: bakeryId,
    payrollMethod: payrollMethod,
    ajan: ajan,
    faran: faran,
    tawlaji: tawlaji,
    chef: chef,
    coChef: coChef,
    bagger: bagger,
    supervisor: supervisor,
  );
}

StorageModel fakeStorage({String bakeryId = 'b1'}) {
  return StorageModel(bakeryId: bakeryId);
}

StaffModel fakeStaff({
  String workerId = 'w1',
  String workerName = 'Worker',
  String bakeryId = 'b1',
}) {
  return StaffModel(
    workerName: workerName,
    workerId: workerId,
    bakeryId: bakeryId,
  );
}

ShiftModel fakeShift({
  String bakeryId = 'b1',
  String workerId = 'w1',
  String workerName = 'Worker',
  double wage = 0,
  List<String> role = const ['ajan'],
  List<int> numberOfBatches = const [1],
  DateTime? date,
  double? rate,
}) {
  return ShiftModel(
    bakeryId: bakeryId,
    workerId: workerId,
    workerName: workerName,
    wage: wage,
    role: role,
    numberOfBatches: numberOfBatches,
    date: date,
    rate: rate,
  );
}

WasteModel fakeWaste({
  String productId = 'p1',
  String productName = 'Product',
  int meal = 0,
  int notSold = 0,
  int manufacturing = 0,
  double productPrice = 1.0,
  DateTime? date,
}) {
  return WasteModel(
    productId: productId,
    productName: productName,
    meal: meal,
    notSold: notSold,
    manufacturing: manufacturing,
    productPrice: productPrice,
    date: date,
  );
}

FinanceModel fakeFinance({
  String bakeryId = 'b1',
  DateTime? date,
  double cleaningExpenses = 0,
  List<WasteModel> wastes = const [],
  double payrollExpenses = 0,
  double profit = 0,
}) {
  return FinanceModel(
    bakeryId: bakeryId,
    date: date,
    cleaningExpenses: cleaningExpenses,
    wastes: wastes,
    payrollExpenses: payrollExpenses,
    profit: profit,
  );
}