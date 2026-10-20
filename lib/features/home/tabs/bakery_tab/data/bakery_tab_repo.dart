import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/utils/enums/bakeries_table_columns.dart';
import 'package:bakemart/core/utils/enums/payrolls_table_columns.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/sales_table_columns.dart';
import 'package:bakemart/core/utils/enums/shifts_table_columns.dart';
import 'package:bakemart/core/utils/enums/staffs_table_columns.dart';
import 'package:bakemart/core/utils/enums/storages_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/utils/enums/finance_table_columns.dart';

class BakeryTabRepo {
  final SupabaseClient _supabase;
  final Uuid _uuid = const Uuid();

  BakeryTabRepo({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<List<BakeryModel>>> fetchBakeries() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> bakeriesResponse = await _supabase
          .from(Tables.bakeries)
          .select()
          .eq(BakeriesTableColumns.bakeryId, id);

      final List<BakeryModel> bakeries = bakeriesResponse
          .map((json) => BakeryModel.fromJson(json))
          .toList();

      return SuccessResponse(bakeries);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<StorageModel>>> fetchStorages() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> storagesResponse = await _supabase
          .from(Tables.storages)
          .select()
          .eq(StoragesTableColumns.bakeryId, id);

      final List<StorageModel> storages = storagesResponse
          .map((json) => StorageModel.fromJson(json))
          .toList();

      return SuccessResponse(storages);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<PayrollModel>>> fetchPayrolls() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> payrollsResponse = await _supabase
          .from(Tables.payrolls)
          .select()
          .eq(PayrollsTableColumns.bakeryId, id);

      final List<PayrollModel> payrolls = payrollsResponse
          .map((json) => PayrollModel.fromJson(json))
          .toList();

      return SuccessResponse(payrolls);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<ProductModel>>> fetchProducts() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> productsResponse = await _supabase
          .from(Tables.products)
          .select()
          .eq(ProductsTableColumns.bakeryId, id);
      final List<ProductModel> products = productsResponse
          .map((row) => ProductModel.fromJson(row))
          .toList();
      return SuccessResponse(products);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<SalesModel>>> fetchSales() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> salesResponse = await _supabase
          .from(Tables.sales)
          .select()
          .eq(SalesTableColumns.bakeryId, id);
      final List<SalesModel> sales = salesResponse
          .map((row) => SalesModel.fromJson(row))
          .toList();
      return SuccessResponse(sales);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<FinanceModel>>> fetchFinance() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> financeResponse = await _supabase
          .from(Tables.finances)
          .select()
          .eq(FinanceTableColumns.bakeryId, id);
      final List<FinanceModel> finance = financeResponse
          .map((row) => FinanceModel.fromJson(row))
          .toList();
      return SuccessResponse(finance);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<ShiftModel>>> fetchShifts() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> shiftsResponse = await _supabase
          .from(Tables.shifts)
          .select()
          .eq(ShiftsTableColumns.bakeryId, id);
      final List<ShiftModel> shifts = shiftsResponse
          .map((row) => ShiftModel.fromJson(row))
          .toList();
      return SuccessResponse(shifts);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<List<StaffModel>>> fetchStaff() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) return FailureResponse("User is not authenticated.");

      final List<Map<String, dynamic>> staffResponse = await _supabase
          .from(Tables.staffs)
          .select()
          .eq(StaffsTableColumns.bakeryId, id);
      final List<StaffModel> staff = staffResponse
          .map((row) => StaffModel.fromJson(row))
          .toList();
      return SuccessResponse(staff);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> createBakery({
    required BakeryModel bakeryData,
    required List<ProductModel> products,
    required PayrollModel payroll,
    required StorageModel storage,
  }) async {
    try {
      final bakeryId = _supabase.auth.currentUser?.id;
      final branchId=_uuid.v4();
      if (bakeryId == null || bakeryId.isEmpty) {
        return FailureResponse("Failed to assign Bakery ID.");
      }

      final updatedBakery = bakeryData.copyWith(
        bakeryId: bakeryId,
        branchId: branchId,
      );
      final updatedProducts = products.map((product) {
        final generatedProductId =
            (product.productId != null && product.productId!.isNotEmpty)
            ? product.productId!
            : _uuid.v4();
        return product.copyWith(
          productId: generatedProductId,
          bakeryId: bakeryId,
          branchId:branchId,
          productRecipe: product.productRecipe.copyWith(
            productId: generatedProductId,
            bakeryId: bakeryId,
          ),
        );
      }).toList();
      final updatedPayroll = payroll.copyWith(bakeryId: bakeryId,branchId:branchId);
      final updatedStorage = storage.copyWith(bakeryId: bakeryId,branchId:branchId);

      await _supabase.rpc(
        'create_bakery',
        params: {
          'p_bakery': updatedBakery.toJson(),
          'p_products': updatedProducts.map((p) => p.toJson()).toList(),
          'p_payroll': updatedPayroll.toJson(),
          'p_storage': updatedStorage.toJson(),
        },
      );

      return SuccessResponse(true);
    } on PostgrestException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  ResponseResult<List<SalesModel>> filterSalesByDate({
    required List<SalesModel> allSales,
    required DateTime selectedDate,
  }) {
    try {
      final filteredSales = allSales
          .where(
            (record) =>
                record.date?.year == selectedDate.year &&
                record.date?.month == selectedDate.month &&
                record.date?.day == selectedDate.day,
          )
          .toList();
      return SuccessResponse(filteredSales);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  ResponseResult<FinanceModel> filterFinanceRecordsByDate({
    required List<FinanceModel> allFinanceRecords,
    required DateTime selectedDate,
  }) {
    try {
      final filteredExpenses = allFinanceRecords.firstWhere(
        (row) =>
            row.date?.year == selectedDate.year &&
            row.date?.month == selectedDate.month &&
            row.date?.day == selectedDate.day,
      );
      return SuccessResponse(filteredExpenses);
    } catch (error) {
      return FailureResponse(
        "No financial records found for the selected date.",
      );
    }
  }

  ResponseResult<List<ShiftModel>> filterShiftsByDate({
    required List<ShiftModel> allShifts,
    required DateTime selectedDate,
  }) {
    try {
      final filteredShifts = allShifts
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
}
