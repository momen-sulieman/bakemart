import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/core/utils/enums/storages_table_columns.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepo {
  final SupabaseClient _supabase;

  StorageRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<bool>> updateStorage(
      StorageModel updatedStorage,
      ) async {
    try {
      await _supabase
          .from(Tables.storages)
          .update(updatedStorage.toJson())
          .eq(StoragesTableColumns.bakeryId, updatedStorage.bakeryId)
          .eq(StoragesTableColumns.branchId, updatedStorage.branchId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}