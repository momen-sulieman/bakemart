import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../../core/shared/models/order_model.dart';
import '../../../../../../../core/shared/models/user_model.dart';
import '../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../core/utils/enums/order_statuses.dart';
import '../../../../../../../core/utils/enums/orders_table_columns.dart';
import '../../../../../../../core/utils/enums/users_table_columns.dart';

class DeliveryRepo {
  final SupabaseClient _supabase;

  DeliveryRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<List<OrderModel>>> fetchAcceptedOrders() async {
    final String? id = _supabase.auth.currentUser?.id;
    if (id == null) {
      return FailureResponse("ID error");
    }

    try {
      final response = await _supabase
          .from(Tables.orders)
          .select()
          .eq(OrdersTableColumns.deliveryManId, id)
          .eq(OrdersTableColumns.orderStatus, OrderStatuses.accepted)
          .order(OrdersTableColumns.date, ascending: false);

      final orders = (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return SuccessResponse(orders);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Stream<List<OrderModel>> receiveOrders({
    required int range,
    required double driverLat,
    required double driverLng,
  }) {
    return _supabase
        .from(Tables.orders)
        .stream(primaryKey: [OrdersTableColumns.orderId])
        .map((data) {
      return data
          .map((json) {
        try {
          return OrderModel.fromJson(json);
        } catch (error) {
          return null;
        }
      })
          .whereType<OrderModel>()
          .where((order) => order.orderStatus == OrderStatuses.pending)
          .where(
            (order) => _allBakeriesWithinRange(
          order: order,
          driverLat: driverLat,
          driverLng: driverLng,
          maxDistance: range * 1000,
        ),
      )
          .toList();
    })
        .handleError((error, stackTrace) {
      return <OrderModel>[];
    });
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

  Future<ResponseResult<void>> acceptOrder(String orderId) async {
    final userDataResult = await getUserData();
    if (userDataResult is FailureResponse<UserModel>) {
      return FailureResponse((userDataResult as FailureResponse).error);
    }
    final user = (userDataResult as SuccessResponse<UserModel>).data;
    try {
      await _supabase
          .from(Tables.orders)
          .update({
        OrdersTableColumns.deliveryManId: user.id,
        OrdersTableColumns.deliveryManName:
        "${user.firstName} ${user.secondName}",
        OrdersTableColumns.orderStatus: OrderStatuses.accepted,
      })
          .eq(OrdersTableColumns.orderId, orderId)
          .eq(OrdersTableColumns.orderStatus, OrderStatuses.pending);

      return SuccessResponse(null);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<void>> changeOrderStatus({
    required String orderId,
    required bool delivered,
  }) async {
    try {
      if (delivered) {
        await _supabase
            .from(Tables.orders)
            .update({OrdersTableColumns.orderStatus: OrderStatuses.delivered})
            .eq(OrdersTableColumns.orderId, orderId);
      } else {
        await _supabase
            .from(Tables.orders)
            .update({
          OrdersTableColumns.deliveryManId: null,
          OrdersTableColumns.deliveryManName: null,
          OrdersTableColumns.orderStatus: OrderStatuses.pending,
        })
            .eq(OrdersTableColumns.orderId, orderId);
      }

      return SuccessResponse(null);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  /// Uploads the captured face and id photos to their buckets (keyed by
  /// [userId], overwriting any previous submission) and marks the user's
  /// row as pending review. Does NOT set `verified` — that's a backend/
  /// admin decision, not something the client can grant itself.

  Future<ResponseResult<void>> submitVerification({
    required String userId,
    required File faceImage,
    required File idImage,
  }) async {
    try {
      await _supabase.storage.from(Buckets.faceImages).upload(
        '$userId.jpg',
        faceImage,
        fileOptions: const FileOptions(upsert: true),
      );

      await _supabase.storage.from(Buckets.idImages).upload(
        '$userId.jpg',
        idImage,
        fileOptions: const FileOptions(upsert: true),
      );

      await _supabase
          .from(Tables.users)
          .update({UsersTableColumns.pending: true})
          .eq(UsersTableColumns.id, userId);

      return SuccessResponse(null);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  bool _allBakeriesWithinRange({
    required OrderModel order,
    required double driverLat,
    required double driverLng,
    required double maxDistance,
  }) {
    if (order.bakeries.isEmpty) return false;
    return order.bakeries.every((bakery) {
      final distance = Geolocator.distanceBetween(
        driverLat,
        driverLng,
        bakery.bakeryLat,
        bakery.bakeryLng,
      );
      return distance <= maxDistance;
    });
  }
}