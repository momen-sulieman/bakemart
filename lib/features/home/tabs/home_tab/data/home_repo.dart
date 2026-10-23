import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/services/location_services.dart';
import '../../../../../core/shared/functions/distance_calculator.dart';
import '../../../../../core/shared/models/home_screen_model.dart';
import '../../../../../core/shared/models/order_model.dart';
import '../../../../../core/shared/models/product_model.dart';
import '../../../../../core/utils/enums/bakeries_table_columns.dart';
import '../../../../../core/utils/enums/buckts.dart';
import '../../../../../core/utils/enums/order_statuses.dart';
import '../../../../../core/utils/enums/orders_table_columns.dart';
import '../../../../../core/utils/enums/tables.dart';
import '../../../../../core/utils/enums/users_table_columns.dart';

class HomeRepo {
  final SupabaseClient _supabase;
  final LocationServices _locationServices;

  HomeRepo({SupabaseClient? supabase, LocationServices? locationServices})
    : _supabase = supabase ?? Supabase.instance.client,
      _locationServices = locationServices ?? LocationServices();

  Future<ResponseResult<bool>> setProfileImageStatus({
    required String userId,
    required bool hasImage,
  }) async {
    try {
      await _supabase
          .from(Tables.users)
          .update({'has_profile_image': hasImage})
          .eq(UsersTableColumns.id, userId);
      return SuccessResponse(true);
    } on PostgrestException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> removeProfileImage({
    required String userId,
  }) async {
    try {
      await _supabase.storage.from(Buckets.usersImages).remove(["$userId.jpg"]);
      return await setProfileImageStatus(userId: userId, hasImage: false);
    } on StorageException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<void>> cancelOrder({required String orderId}) async {
    try {
      await _supabase
          .from(Tables.orders)
          .delete()
          .eq(OrdersTableColumns.orderId, orderId);

      return SuccessResponse<void>(null);
    } on PostgrestException catch (error) {
      return FailureResponse<void>(error.message);
    } catch (error) {
      return FailureResponse<void>(error.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during logout: $e');
    }
  }

  Future<ResponseResult<UserModel>> getUserData() async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      if (id == null) {
        return FailureResponse("User is not authenticated");
      }

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

  Future<ResponseResult<List<HomeDataBakeriesModel>>> getBakeries() async {
    try {
      final location = await _locationServices.getCurrentLocation();
      final List<dynamic> bakeriesResponse = await _supabase
          .from(Tables.bakeries)
          .select()
          .eq(BakeriesTableColumns.verified, true);

      final List<BakeryModel> allBakeries = bakeriesResponse
          .map((bakery) => BakeryModel.fromJson(bakery))
          .toList();

      final nearby =
          allBakeries
              .map(
                (bakery) => MapEntry(
                  bakery,
                  distanceBetweenUserAndBakery(
                    location.latitude,
                    location.longitude,
                    bakery.bakeryLat,
                    bakery.bakeryLng,
                  ),
                ),
              )
              .where((entry) => entry.value <= 10000)
              .toList()
            ..sort((a, b) => a.value.compareTo(b.value));

      final List<BakeryModel> nearbyBakeries = nearby
          .map((entry) => entry.key)
          .toList();

      if (nearbyBakeries.isEmpty) return SuccessResponse([]);

      final List<String> nearbyBakeryIds = nearbyBakeries
          .map((bakery) => bakery.bakeryId)
          .toList();

      final List<dynamic> productsResponse = await _supabase
          .from(Tables.products)
          .select()
          .inFilter(ProductsTableColumns.bakeryId, nearbyBakeryIds);

      final List<ProductModel> allProducts = productsResponse
          .map((product) => ProductModel.fromJson(product))
          .toList();

      final List<HomeDataBakeriesModel> homeData = nearbyBakeries.map((bakery) {
        return HomeDataBakeriesModel(
          bakeryModel: bakery,
          productModelList: allProducts
              .where(
                (product) =>
                    product.bakeryId == bakery.bakeryId &&
                    product.branchId == bakery.branchId,
              )
              .toList(),
        );
      }).toList();

      return SuccessResponse(homeData);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Stream<List<OrderModel>> streamActiveOrders() {
    final String? id = _supabase.auth.currentUser?.id;
    if (id == null) return const Stream.empty();

    return _supabase
        .from(Tables.orders)
        .stream(primaryKey: [OrdersTableColumns.orderId])
        .eq(OrdersTableColumns.customerId, id)
        .order(OrdersTableColumns.date, ascending: false)
        .map(
          (rows) => rows
              .map((row) => OrderModel.fromJson(row))
              .where((order) => order.orderStatus != OrderStatuses.delivered)
              .toList(),
        );
  }

  Future<ResponseResult<bool>> changeUserData({
    required UserModel updatedUserData,
  }) async {
    try {
      await _supabase
          .from(Tables.users)
          .update(updatedUserData.toJson())
          .eq(UsersTableColumns.id, updatedUserData.id!);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}
