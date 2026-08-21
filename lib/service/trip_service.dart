import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/core/network/response_unwrap.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 行程服务
///
/// 使用静态方法，无需实例化
class TripService {
  // 禁止实例化
  TripService._();


  /// 获取用户行程列表
  ///
  /// [status] 可选参数，用于筛选特定状态的行程
  static Future<List<TripModel>> getUserTrips({String? status}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.trips,
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      return _parseTripsResponse(response.data);
    } catch (e) {
      debugPrint('TripService: 获取行程列表失败: $e');
      return [];
    }
  }

  /// 获取行程详情
  ///
  /// [tripId] 行程ID
  static Future<TripModel> getTripDetail(String tripId) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.tripDetail(tripId),
      );
      final tripData =
          unwrapResponse(response.data as Map<String, dynamic>);
      return TripModel.fromJson(tripData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 创建行程
  ///
  /// [trip] 行程信息
  static Future<TripModel> createTrip(TripModel trip) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.createTrip,
        data: trip.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return TripModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新行程
  ///
  /// [trip] 更新后的行程信息
  static Future<TripModel> updateTrip(TripModel trip) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.updateTrip(trip.id),
        data: trip.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return TripModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 删除行程
  ///
  /// [tripId] 行程ID
  static Future<bool> deleteTrip(String tripId) async {
    try {
      final response = await ApiClient.instance.delete(
        ApiEndpoints.deleteTrip(tripId),
      );
      unwrapResponse(response.data as Map<String, dynamic>);
      return true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 根据ID获取行程详情
  static Future<TripModel> getTripById(String tripId) async {
    return getTripDetail(tripId);
  }

  /// 更新行程状态
  ///
  /// [tripId] 行程ID
  /// [status] 新状态（planning / in_progress / completed / cancelled）
  static Future<bool> updateTripStatus(String tripId, String status) async {
    try {
      final statusInt = _statusToInt(status);
      final response = await ApiClient.instance.patch(
        ApiEndpoints.tripStatus(tripId),
        queryParameters: {'status': statusInt},
      );
      unwrapResponse(response.data as Map<String, dynamic>);
      return true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 将状态字符串映射为后端整型值
  ///
  /// PLANNING=0, IN_PROGRESS=1, COMPLETED=2, CANCELLED=3
  static int _statusToInt(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return 0;
      case 'in_progress':
      case 'inprogress':
        return 1;
      case 'completed':
        return 2;
      case 'cancelled':
        return 3;
      default:
        return 0;
    }
  }

  /// 获取规划中的行程列表
  static Future<List<TripModel>> getPlannedTrips() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.plannedTrips,
      );
      return _parseTripsResponse(response.data);
    } catch (e) {
      debugPrint('TripService: 获取规划行程列表失败: $e');
      return [];
    }
  }

  /// 获取所有行程列表
  static Future<List<TripModel>> getAllTrips() async {
    return getUserTrips();
  }

  /// 获取相关行程
  static Future<List<TripModel>> getRelatedTrips(String routeId, {int limit = 5}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.trips,
        queryParameters: {
          'routeId': routeId,
          'limit': limit,
        },
      );
      return _parseTripsResponse(response.data);
    } catch (e) {
      debugPrint('TripService: 获取相关行程失败: $e');
      return [];
    }
  }

  /// 解析行程响应数据的通用方法
  static List<TripModel> _parseTripsResponse(dynamic responseData) {
    final tripsData = unwrapResponse(responseData as Map<String, dynamic>);
    final content = tripsData['content'] as List<dynamic>;

    return content.map((json) => TripModel.fromJson(json)).toList();
  }
}
