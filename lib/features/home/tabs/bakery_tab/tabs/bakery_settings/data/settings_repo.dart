import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/utils/enums/staffs_table_columns.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../core/shared/models/staff_model.dart';
import '../../../../../../../core/shared/models/user_model.dart';
import '../../../../../../../core/utils/enums/bakeries_table_columns.dart';
import '../../../../../../../core/utils/enums/products_table_columns.dart';
import '../../../../../../../core/utils/enums/tables.dart';
import '../../../../../../../core/utils/enums/users_table_columns.dart';

class SettingsRepo {
  final SupabaseClient _supabase;
  final Uuid _uuid = const Uuid();

  SettingsRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<bool>> updateBakeryData(
    BakeryModel updatedBakeryData,
  ) async {
    try {
      await _supabase
          .from(Tables.bakeries)
          .update(updatedBakeryData.toJson())
          .eq(BakeriesTableColumns.bakeryId, updatedBakeryData.bakeryId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> updatePayroll(
    PayrollModel updatedPayroll,
  ) async {
    try {
      await _supabase
          .from(Tables.payrolls)
          .update(updatedPayroll.toJson())
          .eq(BakeriesTableColumns.bakeryId, updatedPayroll.bakeryId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> updateProducts(
    List<ProductModel> updatedProducts,
  ) async {
    try {
      final List<Map<String, dynamic>> payload = updatedProducts
          .map((product) => product.toJson())
          .toList();
      await _supabase
          .from(Tables.products)
          .upsert(payload, onConflict: ProductsTableColumns.productId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> changeBakeryData({
    required BakeryModel updatedBakery,
  }) async {
    try {
      await _supabase
          .from(Tables.bakeries)
          .update(updatedBakery.toJson())
          .eq(BakeriesTableColumns.bakeryId, updatedBakery.bakeryId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
  Future<ResponseResult<bool>> deleteWorker({
    required StaffModel worker
  }) async {
    try {
      await _supabase
          .from(Tables.staffs)
          .delete()
          .eq(StaffsTableColumns.bakeryId, worker.bakeryId)
          .eq(StaffsTableColumns.workerId, worker.workerId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> deleteProduct({
    required String productId,
  }) async {
    try {
      await _supabase
          .from(Tables.products)
          .delete()
          .eq(ProductsTableColumns.productId, productId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
  Future<ResponseResult<UserModel>> getUserData(String id) async {
    try {
      final response = await _supabase
          .from(Tables.users)
          .select()
          .eq(UsersTableColumns.id, id)
          .single();
      final user = UserModel.fromJson(response);
      return SuccessResponse(user);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
  Future<ResponseResult<bool>> addWorker({
    String? workerId,
    String? workerName,
  }) async {
    try {
      final String? bakeryId = _supabase.auth.currentUser?.id;
      StaffModel newWorker = StaffModel(
        workerName: "",
        workerId: "",
        bakeryId: "",
      );
      if (workerId != null) {
        final worker = await getUserData(workerId);
        if (worker is SuccessResponse<UserModel> && bakeryId != null) {
          newWorker = newWorker.copyWith(
            workerName: "${worker.data.firstName} ${worker.data.secondName}",
            workerId: workerId,
            bakeryId: bakeryId,
          );
        } else {
          return FailureResponse("Wrong QR code");
        }
      } else if(workerName!=null){
        final generatedWorkerId=_uuid.v4();
        newWorker=newWorker.copyWith(
          workerName: workerName,
          workerId: generatedWorkerId,
          bakeryId: bakeryId,
        );
      }
      await _supabase.from(Tables.staffs).insert(newWorker.toJson());
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}
