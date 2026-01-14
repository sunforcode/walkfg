import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 行程服务
///
/// 使用静态方法，无需实例化
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class TripService {
  // 禁止实例化
  TripService._();

  /// 从JSON文件加载数据
  static Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  /// 获取用户行程列表
  ///
  /// [status] 可选参数，用于筛选特定状态的行程
  static Future<List<TripModel>> getUserTrips({String? status}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 从JSON文件加载行程数据
    final tripsJson = await _loadJsonData('assets/mock_data/trips.json');
    if (tripsJson == null || !(tripsJson is List)) {
      return [];
    }

    // 将JSON数据转换为TripModel对象列表
    List<TripModel> trips =
        tripsJson.map<TripModel>((json) => TripModel.fromJson(json)).toList();

    // 根据状态筛选
    if (status != null && status.isNotEmpty) {
      return trips
          .where((trip) => trip.status.toString().split('.').last == status)
          .toList();
    }

    return trips;
  }

  /// 获取行程详情
  ///
  /// [tripId] 行程ID
  static Future<TripModel> getTripDetail(String tripId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 从JSON文件加载行程详情数据
    final tripsJson = await _loadJsonData('assets/mock_data/trips.json');
    if (tripsJson == null || !(tripsJson is List)) {
      throw Exception('Failed to load trip data');
    }

    // 查找指定ID的行程
    final tripJson = tripsJson.firstWhere(
      (trip) => trip['id'] == tripId,
      orElse: () => throw Exception('Trip not found: $tripId'),
    );
    final model = TripModel.fromJson(tripJson);
    print(" equipmentList - object");
    print(model.equipmentList?.equipments.length);
    return model;
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
    return getUserTrips(status: 'planned');
  }

  /// 获取所有行程列表
  static Future<List<TripModel>> getAllTrips() async {
    return getUserTrips();
  }

  /// 获取相关行程
  static Future<List<TripModel>> getRelatedTrips(String routeId, {int limit = 5}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 从JSON文件加载行程数据
    final tripsJson = await _loadJsonData('assets/mock_data/trips.json');
    if (tripsJson == null || !(tripsJson is List)) {
      return [];
    }

    // 将JSON数据转换为TripModel对象列表
    List<TripModel> trips =
        tripsJson.map<TripModel>((json) => TripModel.fromJson(json)).toList();

    // 筛选匹配路线ID的行程
    final relatedTrips = trips.where((trip) => trip.primaryRouteId == routeId).toList();

    // 限制数量
    if (relatedTrips.length > limit) {
      return relatedTrips.sublist(0, limit);
    }

    return relatedTrips;
  }
}
