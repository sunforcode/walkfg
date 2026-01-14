import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
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
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取行程详情失败',
          code: responseData['code']?.toString(),
        );
      }

      final tripData = responseData['data'] as Map<String, dynamic>;
      return TripModel.fromJson(tripData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  /// 创建行程
  ///
  /// [trip] 行程信息
  static Future<TripModel> createTrip(TripModel trip) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return trip.copyWith(
      id: 'trip_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 更新行程
  ///
  /// [trip] 更新后的行程信息
  static Future<TripModel> updateTrip(TripModel trip) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    return trip.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  /// 删除行程
  ///
  /// [tripId] 行程ID
  static Future<bool> deleteTrip(String tripId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  /// 根据ID获取行程详情
  static Future<TripModel> getTripById(String tripId) async {
    return getTripDetail(tripId);
  }

  /// 更新行程状态
  ///
  /// [tripId] 行程ID
  /// [status] 新状态
  static Future<bool> updateTripStatus(String tripId, String status) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  /// 生成行程邀请码
  ///
  /// [tripId] 行程ID
  static Future<String> generateTripInviteCode(String tripId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));
    // 生成一个简单的邀请码
    return 'INVITE_${tripId.hashCode.abs()}';
  }

  /// 加入行程
  ///
  /// [tripId] 行程ID
  /// [inviteCode] 邀请码
  static Future<bool> joinTrip(String tripId, String inviteCode) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
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
    final data = responseData as Map<String, dynamic>;

    if (data['code'] != 200) {
      throw BusinessException(
        data['message'] ?? '获取行程数据失败',
        code: data['code']?.toString(),
      );
    }

    final tripsData = data['data'] as Map<String, dynamic>;
    final content = tripsData['content'] as List<dynamic>;
    debugPrint('TripService: 成功解析行程数据，共 ${content.length} 条');

    return content.map((json) => TripModel.fromJson(json)).toList();
  }
}
