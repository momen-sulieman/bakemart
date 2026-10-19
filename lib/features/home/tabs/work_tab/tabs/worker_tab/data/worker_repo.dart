import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/waste_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/bakeries_table_columns.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/payrolls_table_columns.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/sales_table_columns.dart';
import 'package:bakemart/core/utils/enums/shifts_table_columns.dart';
import 'package:bakemart/core/utils/enums/storages_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/core/utils/enums/users_table_columns.dart';
import 'package:collection/collection.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../../core/shared/models/order_model.dart';
import '../../../../../../../core/shared/models/sales_model.dart';
import '../../../../../../../core/shared/models/storage_helper.dart';
import '../../../../../../../core/utils/enums/finance_table_columns.dart';
import '../../../../../../../core/utils/enums/orders_table_columns.dart';
import '../../../../../../../core/utils/enums/staffs_table_columns.dart';

class WorkerRepo {
  final SupabaseClient _supabase;

  WorkerRepo({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<UserModel>> getUserData() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from(Tables.users)
          .select()
          .eq(UsersTableColumns.id, id!)
          .single();
      final user = UserModel.fromJson(response);
      return SuccessResponse(user);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> quit() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) {
        return FailureResponse("Id error");
      }
      await _supabase
          .from(Tables.staffs)
          .delete()
          .eq(StaffsTableColumns.workerId, id);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<StaffModel?>> checkStaffTable() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;

      if (id == null) {
        return FailureResponse("User is not authenticated.");
      }

      final response = await _supabase
          .from(Tables.staffs)
          .select()
          .eq(StaffsTableColumns.workerId, id)
          .maybeSingle();

      if (response != null) {
        final staffModel = StaffModel.fromJson(response);
        return SuccessResponse(staffModel);
      }

      return SuccessResponse(null);
    } on PostgrestException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<BakeryModel>> getBakeryData(String employerId,String branchId) async {
    try {
      final response = await _supabase
          .from(Tables.bakeries)
          .select()
          .eq(BakeriesTableColumns.bakeryId, employerId)
          .eq(BakeriesTableColumns.branchId, branchId)
          .single();
      final bakery = BakeryModel.fromJson(response);
      return SuccessResponse(bakery);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<UserModel>> checkDeliveryManQrCode(
    String scannedId,
  ) async {
    try {
      final userResponse = await _supabase
          .from(Tables.users)
          .select()
          .eq(UsersTableColumns.id, scannedId)
          .maybeSingle();
      if (userResponse != null) {
        return SuccessResponse(UserModel.fromJson(userResponse));
      } else {
        return FailureResponse("User not found!");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<OrderModel>>> fetchAllOrdersOfThisDeliveryMan({
    required String deliveryManId,
    required String bakeryId,
  }) async {
    try {
      final checkResult = await checkDeliveryManQrCode(deliveryManId);
      if (checkResult is SuccessResponse<UserModel>) {
        final resolvedDeliveryManId = checkResult.data.id;
        final ordersResponse = await _supabase
            .from(Tables.orders)
            .select()
            .eq(OrdersTableColumns.deliveryManId, resolvedDeliveryManId!)
            .eq(OrdersTableColumns.orderStatus, OrderStatuses.accepted);
        if (ordersResponse == []) return SuccessResponse([]);
        final List<OrderModel> allOrders = (ordersResponse as List<dynamic>)
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final List<OrderModel> filteredOrders = [];
        for (final order in allOrders) {
          final bakeryProducts = order.orderedProducts
              .where((product) => product.bakeryId == bakeryId)
              .toList();
          if (bakeryProducts.isEmpty) continue;

          final int bakeryIndex = order.bakeries.indexWhere(
            (b) => b.bakeryId == bakeryId,
          );
          if (bakeryIndex == -1) continue;

          final bool alreadyReceived =
              bakeryIndex < order.received.length &&
              order.received[bakeryIndex];
          if (alreadyReceived) continue;

          final bakeryQuantities = <int>[];
          for (final product in bakeryProducts) {
            final index = order.orderedProducts.indexOf(product);
            if (index != -1 && index < order.orderedQuantities.length) {
              bakeryQuantities.add(order.orderedQuantities[index]);
            }
          }
          double bakeryOrderPrice = 0;
          for (int i = 0; i < bakeryProducts.length; i++) {
            bakeryOrderPrice +=
                bakeryProducts[i].productPrice * bakeryQuantities[i];
          }

          filteredOrders.add(
            order.copyWith(
              // bakeries left untouched — indices must stay valid for later writes
              orderedProducts: bakeryProducts,
              orderedQuantities: bakeryQuantities,
              orderPrice: bakeryOrderPrice,
            ),
          );
        }
        return SuccessResponse(filteredOrders);
      } else {
        return FailureResponse((checkResult as FailureResponse).error);
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> join(BarcodeCapture qrScanResult) async {
    try {
      if (qrScanResult.barcodes.first.rawValue != null) {
        final bakeryResponse = await _supabase
            .from(Tables.bakeries)
            .select()
            .eq(
              BakeriesTableColumns.bakeryId,
              qrScanResult.barcodes.first.rawValue!,
            )
            .maybeSingle();
        if (bakeryResponse != null) {
          final bakeryId = BakeryModel.fromJson(bakeryResponse).bakeryId;
          final String? id = _supabase.auth.currentUser?.id;
          final userResponse = await _supabase
              .from(Tables.users)
              .select()
              .eq(UsersTableColumns.id, id!)
              .maybeSingle();
          if (userResponse != null) {
            final user = UserModel.fromJson(userResponse);
            await _supabase
                .from(Tables.staffs)
                .insert(
                  StaffModel(
                    workerName: "${user.firstName} ${user.secondName}",
                    workerId: user.id!,
                    bakeryId: bakeryId,
                    branchId: "",
                  ).toJson(),
                );
            return SuccessResponse(true);
          } else {
            return FailureResponse("Couldn't fetch user id");
          }
        } else {
          return FailureResponse("Bakery not found!");
        }
      } else {
        return FailureResponse("Scan failed!");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<PayrollModel?>> fetchPayroll(String id,String branchId) async {
    try {
      final Map<String, dynamic>? payrollResponse = await _supabase
          .from(Tables.payrolls)
          .select()
          .eq(PayrollsTableColumns.bakeryId, id)
          .eq(PayrollsTableColumns.branchId, branchId)
          .maybeSingle();
      if (payrollResponse != null) {
        final payroll = PayrollModel.fromJson(payrollResponse);
        return SuccessResponse(payroll);
      } else {
        return FailureResponse("Payroll not found");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<ProductModel>?>> fetchProducts(String id,String branchId) async {
    try {
      final List<Map<String, dynamic>> productsResponse = await _supabase
          .from(Tables.products)
          .select()
          .eq(ProductsTableColumns.bakeryId, id)
          .eq(ProductsTableColumns.branchId, branchId);
      if (productsResponse.isNotEmpty) {
        final List<ProductModel> products = productsResponse
            .map((json) => ProductModel.fromJson(json))
            .toList();
        return SuccessResponse(products);
      } else {
        return FailureResponse("No product found");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<StaffModel>?>> fetchStaff(String id,String branchId) async {
    try {
      final List<Map<String, dynamic>> staffResponse = await _supabase
          .from(Tables.staffs)
          .select()
          .eq(StaffsTableColumns.bakeryId, id)
          .eq(StaffsTableColumns.branchId, branchId);
      if (staffResponse.isNotEmpty) {
        final List<StaffModel> staff = staffResponse
            .map((json) => StaffModel.fromJson(json))
            .toList();
        return SuccessResponse(staff);
      } else {
        return FailureResponse("No staff found");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<ShiftModel>?>> fetchShifts(String id,String branchId) async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T').first;
      final fourDaysAgoStr = today
          .subtract(Duration(days: 4))
          .toIso8601String()
          .split('T')
          .first;

      final List<Map<String, dynamic>> shiftsResponse = await _supabase
          .from(Tables.shifts)
          .select()
          .eq(ShiftsTableColumns.bakeryId, id)
          .eq(ShiftsTableColumns.branchId, branchId)
          .gte(ShiftsTableColumns.date, fourDaysAgoStr)
          .lte(ShiftsTableColumns.date, todayStr);

      final List<ShiftModel> shifts = shiftsResponse
          .map((json) => ShiftModel.fromJson(json))
          .toList();

      return SuccessResponse(shifts);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<ShiftModel>?>> fetchMyShifts() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id != null) {
        final List<Map<String, dynamic>> shiftsResponse = await _supabase
            .from(Tables.shifts)
            .select()
            .eq(ShiftsTableColumns.workerId, id);
        final List<ShiftModel> shifts = shiftsResponse
            .map((json) => ShiftModel.fromJson(json))
            .toList();

        return SuccessResponse(shifts);
      } else {
        return FailureResponse("ID error");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<FinanceModel>?>> fetchFinance(String id,String branchId) async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T').first;
      final fourDaysAgoStr = today
          .subtract(Duration(days: 4))
          .toIso8601String()
          .split('T')
          .first;

      final List<Map<String, dynamic>> financeResponse = await _supabase
          .from(Tables.finances)
          .select()
          .eq(FinanceTableColumns.bakeryId, id)
          .gte(FinanceTableColumns.date, fourDaysAgoStr)
          .lte(FinanceTableColumns.date, todayStr);

      final List<FinanceModel> finance = financeResponse
          .map((json) => FinanceModel.fromJson(json))
          .toList();

      return SuccessResponse(finance);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<StorageModel?>> fetchStorage(String id,String branchId) async {
    try {
      final Map<String, dynamic>? storageResponse = await _supabase
          .from(Tables.storages)
          .select()
          .eq(StoragesTableColumns.bakeryId, id)
          .maybeSingle();
      if (storageResponse != null) {
        final storage = StorageModel.fromJson(storageResponse);
        return SuccessResponse(storage);
      } else {
        return FailureResponse("Storage not found");
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<void> _rolloverYesterdayStats({required ProductModel product}) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().split('T').first;

      final Map<String, dynamic>? yesterdaySalesResponse = await _supabase
          .from(Tables.sales)
          .select()
          .eq(SalesTableColumns.bakeryId, product.bakeryId)
          .eq(SalesTableColumns.productId, product.productId!)
          .eq(SalesTableColumns.date, yesterdayStr)
          .maybeSingle();

      final SalesModel? yesterdaySales = yesterdaySalesResponse != null
          ? SalesModel.fromJson(yesterdaySalesResponse)
          : null;

      await _supabase
          .from(Tables.products)
          .update({
            ProductsTableColumns.yesterdayProduced:
                (yesterdaySales?.produced ?? 0).toDouble(),
            ProductsTableColumns.yesterdaySold: (yesterdaySales?.sold ?? 0)
                .toDouble(),
          })
          .eq(ProductsTableColumns.productId, product.productId!)
          .eq(ProductsTableColumns.bakeryId, product.bakeryId);
    } catch (_) {
      // Best-effort rollover — don't block the sale/production flow on this.
    }
  }

  Future<ResponseResult<bool>> upsertShiftsTable({
    required List<ShiftModel> shiftTable,
  }) async {
    try {
      final List<Map<String, dynamic>> shiftRows = shiftTable
          .map((shiftRow) => shiftRow.toJson())
          .toList();
      await _supabase
          .from(Tables.shifts)
          .upsert(
            shiftRows,
            onConflict:
                '${ShiftsTableColumns.workerId},${ShiftsTableColumns.date}',
          );
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> adjustAvailabilityForWasteChanges({
    required List<WasteModel> oldWastes,
    required List<WasteModel> newWastes,
    required List<ProductModel> products,
    required String bakeryId,
  }) async {
    try {
      for (final newWaste in newWastes) {
        final WasteModel? oldWaste = oldWastes.firstWhereOrNull(
          (w) => w.productId == newWaste.productId,
        );
        final int oldMeal = oldWaste?.meal ?? 0;
        final int oldNotSold = oldWaste?.notSold ?? 0;
        final int oldManuf = oldWaste?.manufacturing ?? 0;

        final int mealDiff = newWaste.meal - oldMeal;
        final int notSoldDiff = newWaste.notSold - oldNotSold;
        final int manufDiff = newWaste.manufacturing - oldManuf;
        final int totalDiff = mealDiff + notSoldDiff + manufDiff;

        if (totalDiff == 0) continue;

        final ProductModel? product = products.firstWhereOrNull(
          (p) => p.productId == newWaste.productId,
        );
        if (product == null) continue;

        final int updatedAvailable = product.available - totalDiff;

        await _supabase
            .from(Tables.products)
            .update({ProductsTableColumns.available: updatedAvailable})
            .eq(ProductsTableColumns.productId, newWaste.productId)
            .eq(ProductsTableColumns.bakeryId, bakeryId);
      }
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> deleteShift({required ShiftModel worker}) async {
    try {
      if (worker.date == null) {
        return FailureResponse("Shift date is missing.");
      }

      final dateStr = worker.date!.toLocal().toIso8601String().split('T').first;

      await _supabase
          .from(Tables.shifts)
          .delete()
          .eq(ShiftsTableColumns.workerId, worker.workerId)
          .eq(ShiftsTableColumns.date, dateStr);

      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> upsertFinancerecord({
    required FinanceModel financeRecord,
    required String bakeryId,
  }) async {
    try {
      if (financeRecord.bakeryId.isEmpty) {
        financeRecord = financeRecord.copyWith(bakeryId: bakeryId);
      }
      await _supabase
          .from(Tables.finances)
          .upsert(
            financeRecord.toJson(),
            onConflict:
                '${FinanceTableColumns.bakeryId},${FinanceTableColumns.date}',
          );
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> deleteMealFromDatabase({
    required FinanceModel financeRecord,
    required WasteModel product,
    required String bakeryId,
  }) async {
    try {
      final updatedwastes = financeRecord.wastes
          .where((meal) => meal.productId != product.productId)
          .toList();

      final updatedFinanceRecord = financeRecord.copyWith(
        bakeryId: bakeryId,
        wastes: updatedwastes,
      );

      await _supabase
          .from(Tables.finances)
          .upsert(
            updatedFinanceRecord.toJson(),
            onConflict:
                '${FinanceTableColumns.bakeryId},${FinanceTableColumns.date}',
          );

      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> postPayrollExpenses({
    required String bakeryId,
    required String branchId,
    required double payrollExpenses,
    required DateTime date,
  }) async {
    try {
      final String formattedDate = date.toIso8601String().split('T').first;

      final existingRow = await _supabase
          .from(Tables.finances)
          .select()
          .eq(FinanceTableColumns.bakeryId, bakeryId)
          .eq(FinanceTableColumns.date, formattedDate)
          .maybeSingle();

      if (existingRow != null) {
        await _supabase
            .from(Tables.finances)
            .update({FinanceTableColumns.payrollExpenses: payrollExpenses})
            .eq(FinanceTableColumns.bakeryId, bakeryId)
            .eq(FinanceTableColumns.date, formattedDate);
      } else {
        final freshFinance = FinanceModel(
          bakeryId: bakeryId,
          branchId: branchId,
          date: date,
          cleaningExpenses: 0.0,
          wastes: [],
          payrollExpenses: payrollExpenses,
          profit: 0.0,
        );

        await _supabase.from(Tables.finances).insert(freshFinance.toJson());
      }
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> windowSell({
    int? soldQuantity,
    int? notSoldQuantity,
    int? mealWaste,
    required ProductModel product,
  }) async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T').first;

      if (soldQuantity != null) {
        final int availableUpdate = product.available - soldQuantity;
        final int totalSoldUpdated = product.totalSold + soldQuantity;
        final double addedProfit = soldQuantity * product.productPrice;

        final Map<String, dynamic>? existingRecord = await _supabase
            .from(Tables.sales)
            .select()
            .eq(SalesTableColumns.bakeryId, product.bakeryId)
            .eq(SalesTableColumns.productId, product.productId!)
            .eq(SalesTableColumns.date, todayStr)
            .maybeSingle();

        if (existingRecord != null) {
          final SalesModel currentSales = SalesModel.fromJson(existingRecord);
          final int updatedSoldValue = currentSales.sold + soldQuantity;

          await _supabase
              .from(Tables.sales)
              .update({SalesTableColumns.sold: updatedSoldValue})
              .eq(SalesTableColumns.bakeryId, product.bakeryId)
              .eq(SalesTableColumns.productId, product.productId!)
              .eq(SalesTableColumns.date, todayStr);
        } else {
          await _rolloverYesterdayStats(product: product);
          final SalesModel newSalesRecord = SalesModel(
            productName: product.productName,
            bakeryId: product.bakeryId,
            branchId: product.branchId,
            productId: product.productId!,
            productPrice: product.productPrice,
            date: today,
            produced: 0,
            sold: soldQuantity,
          );

          await _supabase.from(Tables.sales).insert(newSalesRecord.toJson());
        }

        await _supabase
            .from(Tables.products)
            .update({
              ProductsTableColumns.available: availableUpdate,
              ProductsTableColumns.totalSold: totalSoldUpdated,
            })
            .eq(ProductsTableColumns.productId, product.productId!)
            .eq(ProductsTableColumns.bakeryId, product.bakeryId);
        final Map<String, dynamic>? financeResponse = await _supabase
            .from(Tables.finances)
            .select()
            .eq(FinanceTableColumns.bakeryId, product.bakeryId)
            .eq(FinanceTableColumns.date, todayStr)
            .maybeSingle();

        if (financeResponse != null) {
          final FinanceModel existingFinanceRecord = FinanceModel.fromJson(
            financeResponse,
          );
          final double currentProfit = existingFinanceRecord.profit;
          final double updatedProfit = currentProfit + addedProfit;
          await _supabase
              .from(Tables.finances)
              .update({FinanceTableColumns.profit: updatedProfit})
              .eq(FinanceTableColumns.bakeryId, product.bakeryId)
              .eq(FinanceTableColumns.date, todayStr);
        } else {
          final FinanceModel newFinanceRecord = FinanceModel(
            bakeryId: product.bakeryId,
            branchId: product.branchId,
            date: today,
            cleaningExpenses: 0.0,
            wastes: [],
            profit: addedProfit,
          );

          await _supabase
              .from(Tables.finances)
              .insert(newFinanceRecord.toJson());
        }
      }

      if (notSoldQuantity != null) {
        final int availableUpdate = product.available - notSoldQuantity;
        final int notSoldWasteUpdated = product.notSoldWaste + notSoldQuantity;
        await _supabase
            .from(Tables.products)
            .update({
              ProductsTableColumns.available: availableUpdate,
              ProductsTableColumns.notSoldWaste: notSoldWasteUpdated,
            })
            .eq(ProductsTableColumns.productId, product.productId!)
            .eq(ProductsTableColumns.bakeryId, product.bakeryId);

        final Map<String, dynamic>? financeResponse = await _supabase
            .from(Tables.finances)
            .select()
            .eq(FinanceTableColumns.bakeryId, product.bakeryId)
            .eq(FinanceTableColumns.date, todayStr)
            .maybeSingle();

        if (financeResponse != null) {
          final FinanceModel existingFinanceRecord = FinanceModel.fromJson(
            financeResponse,
          );

          final int existingNotSoldIndex = existingFinanceRecord.wastes
              .indexWhere((w) => w.productId == product.productId);

          List<WasteModel> updatedwastes = List.from(
            existingFinanceRecord.wastes,
          );

          if (existingNotSoldIndex != -1) {
            final WasteModel existingWaste =
                updatedwastes[existingNotSoldIndex];
            updatedwastes[existingNotSoldIndex] = existingWaste.copyWith(
              notSold: existingWaste.notSold + notSoldQuantity,
            );
          } else {
            updatedwastes.add(
              WasteModel(
                productId: product.productId!,
                productName: product.productName,
                meal: 0,
                notSold: notSoldQuantity,
                manufacturing: 0,
                productPrice: product.productPrice,
                date: today,
              ),
            );
          }

          final FinanceModel updatedFinanceRecord = existingFinanceRecord
              .copyWith(wastes: updatedwastes);

          await _supabase
              .from(Tables.finances)
              .update({
                FinanceTableColumns.wastes: updatedFinanceRecord
                    .toJson()[FinanceTableColumns.wastes],
              })
              .eq(FinanceTableColumns.bakeryId, product.bakeryId)
              .eq(FinanceTableColumns.date, todayStr);
        } else {
          final FinanceModel newFinanceRecord = FinanceModel(
            bakeryId: product.bakeryId,
            branchId: product.branchId,
            date: today,
            cleaningExpenses: 0.0,
            wastes: [
              WasteModel(
                productId: product.productId!,
                productName: product.productName,
                meal: 0,
                notSold: notSoldQuantity,
                manufacturing: 0,
                productPrice: product.productPrice,
                date: today,
              ),
            ],
          );

          await _supabase
              .from(Tables.finances)
              .insert(newFinanceRecord.toJson());
        }
      }

      if (mealWaste != null) {
        final int availableUpdate = product.available - mealWaste;
        final int wastesWasteUpdated = product.mealsWaste + mealWaste;
        await _supabase
            .from(Tables.products)
            .update({
              ProductsTableColumns.available: availableUpdate,
              ProductsTableColumns.mealsWaste: wastesWasteUpdated,
            })
            .eq(ProductsTableColumns.productId, product.productId!)
            .eq(ProductsTableColumns.bakeryId, product.bakeryId);

        final Map<String, dynamic>? financeResponse = await _supabase
            .from(Tables.finances)
            .select()
            .eq(FinanceTableColumns.bakeryId, product.bakeryId)
            .eq(FinanceTableColumns.date, todayStr)
            .maybeSingle();

        if (financeResponse != null) {
          final FinanceModel existingFinanceRecord = FinanceModel.fromJson(
            financeResponse,
          );

          final int existingMealIndex = existingFinanceRecord.wastes.indexWhere(
            (w) => w.productId == product.productId,
          );

          List<WasteModel> updatedwastes = List.from(
            existingFinanceRecord.wastes,
          );

          if (existingMealIndex != -1) {
            final WasteModel existingMeal = updatedwastes[existingMealIndex];
            updatedwastes[existingMealIndex] = existingMeal.copyWith(
              meal: existingMeal.meal + mealWaste,
            );
          } else {
            updatedwastes.add(
              WasteModel(
                productId: product.productId!,
                productName: product.productName,
                meal: mealWaste,
                productPrice: product.productPrice,
                date: today,
                notSold: 0,
                manufacturing: 0,
              ),
            );
          }

          final FinanceModel updatedFinanceRecord = existingFinanceRecord
              .copyWith(wastes: updatedwastes);

          await _supabase
              .from(Tables.finances)
              .update({
                FinanceTableColumns.wastes: updatedFinanceRecord
                    .toJson()[FinanceTableColumns.wastes],
              })
              .eq(FinanceTableColumns.bakeryId, product.bakeryId)
              .eq(FinanceTableColumns.date, todayStr);
        } else {
          final FinanceModel newFinanceRecord = FinanceModel(
            bakeryId: product.bakeryId,
            branchId: product.branchId,
            date: today,
            cleaningExpenses: 0.0,
            wastes: [
              WasteModel(
                productId: product.productId!,
                productName: product.productName,
                meal: mealWaste,
                productPrice: product.productPrice,
                date: today,
                notSold: 0,
                manufacturing: 0,
              ),
            ],
          );

          await _supabase
              .from(Tables.finances)
              .insert(newFinanceRecord.toJson());
        }
      }
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> produce({
    required int batchCounter,
    required int manufacturingWasteCounter,
    required ProductModel product,
    required StorageModel currentStorage,
  }) async {
    try {
      final int producedQuantity = batchCounter * product.quantityPerBatch;
      final int totalNewProduction =
          producedQuantity - manufacturingWasteCounter;
      final int manufacturingWasteUpdated =
          product.manufacturingWaste + manufacturingWasteCounter;
      final int availableUpdate = totalNewProduction + product.available;
      final int totalProducedUpdated =
          product.totalProduced + totalNewProduction;

      await _supabase
          .from(Tables.products)
          .update({
            ProductsTableColumns.manufacturingWaste: manufacturingWasteUpdated,
            ProductsTableColumns.available: availableUpdate,
            ProductsTableColumns.totalProduced: totalProducedUpdated,
          })
          .eq(ProductsTableColumns.productId, product.productId!)
          .eq(ProductsTableColumns.bakeryId, product.bakeryId);
      final Map<String, dynamic>? existingRecord = await _supabase
          .from(Tables.sales)
          .select()
          .eq(SalesTableColumns.bakeryId, product.bakeryId)
          .eq(SalesTableColumns.productId, product.productId!)
          .eq(
            SalesTableColumns.date,
            DateTime.now().toIso8601String().split('T').first,
          )
          .maybeSingle();

      if (existingRecord != null) {
        final SalesModel currentSales = SalesModel.fromJson(existingRecord);
        final int updatedProducedValue =
            currentSales.produced + totalNewProduction;

        await _supabase
            .from(Tables.sales)
            .update({SalesTableColumns.produced: updatedProducedValue})
            .eq(SalesTableColumns.bakeryId, product.bakeryId)
            .eq(SalesTableColumns.productId, product.productId!)
            .eq(
              SalesTableColumns.date,
              DateTime.now().toIso8601String().split('T').first,
            );
      } else {
        await _rolloverYesterdayStats(product: product);
        final SalesModel newSalesRecord = SalesModel(
          productName: product.productName,
          bakeryId: product.bakeryId,
          branchId: product.branchId,
          productId: product.productId!,
          productPrice: product.productPrice,
          date: DateTime.now(),
          produced: totalNewProduction,
          sold: 0,
        );

        await _supabase.from(Tables.sales).insert(newSalesRecord.toJson());
      }
      final StorageModel updatedStorage = StorageHelper.deductRecipeFromStorage(
        currentStorage: currentStorage,
        recipe: product.productRecipe,
        numberOfBatches: batchCounter,
      );

      await _supabase
          .from(Tables.storages)
          .upsert(
            updatedStorage.toJson(),
            onConflict: StoragesTableColumns.bakeryId,
          );

      if (manufacturingWasteCounter > 0) {
        final String todayStr = DateTime.now()
            .toIso8601String()
            .split('T')
            .first;

        final Map<String, dynamic>? financeResponse = await _supabase
            .from(Tables.finances)
            .select()
            .eq(FinanceTableColumns.bakeryId, product.bakeryId)
            .eq(FinanceTableColumns.date, todayStr)
            .maybeSingle();

        if (financeResponse != null) {
          final FinanceModel existingFinanceRecord = FinanceModel.fromJson(
            financeResponse,
          );

          final int existingManufIndex = existingFinanceRecord.wastes
              .indexWhere((w) => w.productId == product.productId);

          List<WasteModel> updatedwastes = List.from(
            existingFinanceRecord.wastes,
          );

          if (existingManufIndex != -1) {
            final WasteModel existingWaste = updatedwastes[existingManufIndex];
            updatedwastes[existingManufIndex] = existingWaste.copyWith(
              manufacturing:
                  existingWaste.manufacturing + manufacturingWasteCounter,
            );
          } else {
            updatedwastes.add(
              WasteModel(
                productId: product.productId!,
                productName: product.productName,
                meal: 0,
                notSold: 0,
                manufacturing: manufacturingWasteCounter,
                productPrice: product.productPrice,
                date: DateTime.now(),
              ),
            );
          }

          final FinanceModel updatedFinanceRecord = existingFinanceRecord
              .copyWith(wastes: updatedwastes);

          await _supabase
              .from(Tables.finances)
              .update({
                FinanceTableColumns.wastes: updatedFinanceRecord
                    .toJson()[FinanceTableColumns.wastes],
              })
              .eq(FinanceTableColumns.bakeryId, product.bakeryId)
              .eq(FinanceTableColumns.date, todayStr);
        } else {
          final FinanceModel newFinanceRecord = FinanceModel(
            bakeryId: product.bakeryId,
            branchId: product.branchId,
            date: DateTime.now(),
            cleaningExpenses: 0.0,
            wastes: [
              WasteModel(
                productId: product.productId!,
                productName: product.productName,
                meal: 0,
                notSold: 0,
                manufacturing: manufacturingWasteCounter,
                productPrice: product.productPrice,
                date: DateTime.now(),
              ),
            ],
          );

          await _supabase
              .from(Tables.finances)
              .insert(newFinanceRecord.toJson());
        }
      }

      return SuccessResponse(true);
    } catch (error) {
      final String errorMsg = error is FailureResponse
          ? error.error.toString()
          : error.toString();
      return FailureResponse(errorMsg);
    }
  }

  double calculateWage({
    required List<String> roles,
    required List<int> numberOfBatches,
    required PayrollModel payroll,
  }) {
    double totalWage = 0.0;

    for (int i = 0; i < roles.length; i++) {
      final String role = roles[i];
      final int batches = i < numberOfBatches.length ? numberOfBatches[i] : 0;
      double ratePerBatch = 0.0;

      switch (role) {
        case PayrollsTableColumns.ajan:
          ratePerBatch = payroll.ajan ?? 0.0;
          break;
        case PayrollsTableColumns.faran:
          ratePerBatch = payroll.faran ?? 0.0;
          break;
        case PayrollsTableColumns.tawlaji:
          ratePerBatch = payroll.tawlaji ?? 0.0;
          break;
        case PayrollsTableColumns.chef:
          ratePerBatch = payroll.chef ?? 0.0;
          break;
        case PayrollsTableColumns.coChef:
          ratePerBatch = payroll.coChef ?? 0.0;
          break;
        case PayrollsTableColumns.bagger:
          ratePerBatch = payroll.bagger ?? 0.0;
          break;
        case PayrollsTableColumns.supervisor:
          ratePerBatch = payroll.supervisor ?? 0.0;
          break;
      }

      // Fixed parenthesis precedence
      totalWage += (ratePerBatch) * batches;
    }

    return totalWage;
  }

  List<ShiftModel> mergeShifts({
    required List<ShiftModel>? existingShifts,
    required List<ShiftModel> newBatchShift,
    required PayrollModel payroll,
  }) {
    if (existingShifts == null || existingShifts.isEmpty) {
      return newBatchShift
          .map(
            (s) => s.copyWith(
              wage: calculateWage(
                roles: s.role,
                numberOfBatches: s.numberOfBatches,
                payroll: payroll,
              ),
            ),
          )
          .toList();
    }

    final Map<String, ShiftModel> mergedMap = {
      for (final shift in existingShifts) shift.workerId: shift,
    };

    for (final newShift in newBatchShift) {
      final existingShift = mergedMap[newShift.workerId];

      if (existingShift != null) {
        // Map roles to batch counts to keep indices synchronized
        final Map<String, int> roleBatchMap = {};

        for (int i = 0; i < existingShift.role.length; i++) {
          final role = existingShift.role[i];
          final batches = i < existingShift.numberOfBatches.length
              ? existingShift.numberOfBatches[i]
              : 0;
          roleBatchMap[role] = (roleBatchMap[role] ?? 0) + batches;
        }

        for (int i = 0; i < newShift.role.length; i++) {
          final role = newShift.role[i];
          final batches = i < newShift.numberOfBatches.length
              ? newShift.numberOfBatches[i]
              : 0;
          roleBatchMap[role] = (roleBatchMap[role] ?? 0) + batches;
        }

        final List<String> mergedRoles = roleBatchMap.keys.toList();
        final List<int> mergedBatches = roleBatchMap.values.toList();

        final double totalCalculatedWage = calculateWage(
          roles: mergedRoles,
          numberOfBatches: mergedBatches,
          payroll: payroll,
        );

        mergedMap[newShift.workerId] = existingShift.copyWith(
          role: mergedRoles,
          numberOfBatches: mergedBatches,
          wage: totalCalculatedWage,
        );
      } else {
        final double calculatedWage = calculateWage(
          roles: newShift.role,
          numberOfBatches: newShift.numberOfBatches,
          payroll: payroll,
        );
        mergedMap[newShift.workerId] = newShift.copyWith(wage: calculatedWage);
      }
    }

    return mergedMap.values.toList();
  }

  ResponseResult<List<ShiftModel>> filterShiftsByDate({
    required List<ShiftModel> allShifts,
    required DateTime selectedDate,
  }) {
    try {
      List<ShiftModel> filteredShifts = allShifts
          .where(
            (shift) =>
                shift.date?.year == selectedDate.year &&
                shift.date?.month == selectedDate.month &&
                shift.date?.day == selectedDate.day,
          )
          .toList();
      return SuccessResponse(filteredShifts);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  ResponseResult<FinanceModel?> filterExpensesByDate({
    required List<FinanceModel> allExpenses,
    required DateTime selectedDate,
  }) {
    try {
      final FinanceModel? filteredExpenses = allExpenses.firstWhereOrNull(
        (row) =>
            row.date?.year == selectedDate.year &&
            row.date?.month == selectedDate.month &&
            row.date?.day == selectedDate.day,
      );
      if (filteredExpenses == null) {
        return FailureResponse("No expenses found for this date");
      }
      return SuccessResponse(filteredExpenses);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> updateOrderInDatabase({
    required OrderModel order,
    required String bakeryId,
    required String branchId,
  }) async {
    try {
      final int bakeryIndex = order.bakeries.indexWhere(
        (bakery) => bakery.bakeryId == bakeryId,
      );
      if (bakeryIndex == -1) return FailureResponse('Bakery not found');

      final List<bool> updatedReceived = List.from(order.received);
      updatedReceived[bakeryIndex] = true;

      final List<ProductModel> updatedReceivedProducts =
          order.receivedProducts != null
          ? List<ProductModel>.from(order.receivedProducts!)
          : [];
      updatedReceivedProducts.addAll(order.orderedProducts);

      final List<int> updatedReceivedQuantities =
          order.receivedQuantities != null
          ? List<int>.from(order.receivedQuantities!)
          : [];
      updatedReceivedQuantities.addAll(order.orderedQuantities);

      await _supabase
          .from(Tables.orders)
          .update({
            OrdersTableColumns.received: updatedReceived,
            OrdersTableColumns.receivedProducts: updatedReceivedProducts,
            OrdersTableColumns.receivedQuantities: updatedReceivedQuantities,
            OrdersTableColumns.orderPrice: order.orderPrice,
          })
          .eq(OrdersTableColumns.orderId, order.orderId!);

      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T').first;

      for (int i = 0; i < order.orderedProducts.length; i++) {
        final product = order.orderedProducts[i];
        final int quantity = i < order.orderedQuantities.length
            ? order.orderedQuantities[i]
            : 0;
        if (quantity <= 0 || product.productId == null) continue;

        // --- products table ---
        final int newAvailable = product.available - quantity;
        final int newTotalSold = product.totalSold + quantity;

        await _supabase
            .from(Tables.products)
            .update({
              ProductsTableColumns.available: newAvailable < 0
                  ? 0
                  : newAvailable,
              ProductsTableColumns.totalSold: newTotalSold,
            })
            .eq(ProductsTableColumns.productId, product.productId!)
            .eq(ProductsTableColumns.bakeryId, bakeryId);

        // --- sales table: today's row for this product ---
        final Map<String, dynamic>? existingSalesRecord = await _supabase
            .from(Tables.sales)
            .select()
            .eq(SalesTableColumns.bakeryId, bakeryId)
            .eq(SalesTableColumns.productId, product.productId!)
            .eq(SalesTableColumns.date, todayStr)
            .maybeSingle();

        if (existingSalesRecord != null) {
          final SalesModel currentSales = SalesModel.fromJson(
            existingSalesRecord,
          );
          final int updatedSoldValue = currentSales.sold + quantity;

          await _supabase
              .from(Tables.sales)
              .update({SalesTableColumns.sold: updatedSoldValue})
              .eq(SalesTableColumns.bakeryId, bakeryId)
              .eq(SalesTableColumns.productId, product.productId!)
              .eq(SalesTableColumns.date, todayStr);
        } else {
          final SalesModel newSalesRecord = SalesModel(
            productName: product.productName,
            bakeryId: bakeryId,
            branchId: product.branchId,
            productId: product.productId!,
            productPrice: product.productPrice,
            date: today,
            produced: 0,
            sold: quantity,
          );

          await _supabase.from(Tables.sales).insert(newSalesRecord.toJson());
        }

        // --- finances table: today's profit ---
        final double addedProfit = quantity * product.productPrice;

        final Map<String, dynamic>? existingFinanceRecord = await _supabase
            .from(Tables.finances)
            .select()
            .eq(FinanceTableColumns.bakeryId, bakeryId)
            .eq(FinanceTableColumns.date, todayStr)
            .maybeSingle();

        if (existingFinanceRecord != null) {
          final FinanceModel currentFinance = FinanceModel.fromJson(
            existingFinanceRecord,
          );
          final double updatedProfit = currentFinance.profit + addedProfit;

          await _supabase
              .from(Tables.finances)
              .update({FinanceTableColumns.profit: updatedProfit})
              .eq(FinanceTableColumns.bakeryId, bakeryId)
              .eq(FinanceTableColumns.date, todayStr);
        } else {
          final FinanceModel newFinanceRecord = FinanceModel(
            bakeryId: bakeryId,
            branchId: branchId,
            date: today,
            cleaningExpenses: 0.0,
            wastes: [],
            profit: addedProfit,
          );

          await _supabase
              .from(Tables.finances)
              .insert(newFinanceRecord.toJson());
        }
      }

      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  bool isBakeryReceived(OrderModel order, String bakeryId) {
    final int index = order.bakeries.indexWhere((b) => b.bakeryId == bakeryId);
    if (index == -1) return false;
    return index < order.received.length && order.received[index];
  }

  bool isOrderFullyReceived(OrderModel order) {
    return order.received.every((r) => r == true);
  }
}
