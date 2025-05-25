import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 行程服务接口
///
/// 专注于行程管理功能，包括创建、更新、查询和删除行程
abstract class TripService {
  /// 获取用户行程列表
  ///
  /// [status] 可选参数，用于筛选特定状态的行程
  Future<List<TripModel>> getUserTrips({String? status});

  /// 获取行程详情
  ///
  /// [tripId] 行程ID
  Future<TripModel> getTripDetail(String tripId);

  /// 创建行程
  ///
  /// [trip] 行程信息
  Future<TripModel> createTrip(TripModel trip);

  /// 更新行程
  ///
  /// [trip] 更新后的行程信息
  Future<TripModel> updateTrip(TripModel trip);

  /// 删除行程
  ///
  /// [tripId] 行程ID
  Future<bool> deleteTrip(String tripId);

  /// 更新行程状态
  ///
  /// [tripId] 行程ID
  /// [status] 新状态
  Future<bool> updateTripStatus(String tripId, String status);

  /// 生成行程邀请码
  ///
  /// [tripId] 行程ID
  Future<String> generateTripInviteCode(String tripId);

  /// 加入行程
  ///
  /// [tripId] 行程ID
  /// [inviteCode] 邀请码
  Future<bool> joinTrip(String tripId, String inviteCode);

  /// 获取规划中的行程列表
  Future<List<TripModel>> getPlannedTrips();

  /// 根据ID获取行程详情
  Future<TripModel> getTripById(String tripId) async {
    try {
      // 从本地JSON文件加载数据
      final String jsonString =
          await rootBundle.loadString('assets/mock_data/trips.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 查找匹配ID的行程
      final tripJson = jsonList.firstWhere(
        (trip) => trip['id'] == tripId,
        orElse: () => throw Exception('未找到ID为 $tripId 的行程'),
      );

      return TripModel.fromJson(tripJson);
    } catch (e) {
      throw Exception('获取行程详情失败: $e');
    }
  }

  /// 获取所有行程列表
  Future<List<TripModel>> getAllTrips() async {
    try {
      // 从本地JSON文件加载数据
      final String jsonString =
          await rootBundle.loadString('assets/mock_data/trips.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 转换为TripModel列表
      return jsonList.map((json) => TripModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取行程列表失败: $e');
    }
  }
}
