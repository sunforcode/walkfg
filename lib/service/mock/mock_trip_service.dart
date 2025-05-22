import 'dart:convert';
import 'package:flutter/services.dart';
import '../trip_service.dart';
import '../../model/model/trip/trip_model.dart';

/// 模拟行程服务实现
class MockTripService implements TripService {
  /// 单例实例
  static final MockTripService _instance = MockTripService._internal();

  /// 工厂构造函数
  factory MockTripService() {
    return _instance;
  }

  /// 私有构造函数
  MockTripService._internal();

  /// 从JSON文件加载数据
  Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  @override
  Future<List<TripModel>> getUserTrips({String? status}) async {
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

  @override
  Future<TripModel> getTripDetail(String tripId) async {
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

    return TripModel.fromJson(tripJson);
  }

  @override
  Future<TripModel> createTrip(TripModel trip) async {
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

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    return trip.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteTrip(String tripId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  @override
  Future<bool> updateTripStatus(String tripId, String status) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功
    return true;
  }

  @override
  Future<String> generateTripInviteCode(String tripId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟生成邀请码
    return 'TRIP123';
  }

  @override
  Future<bool> joinTrip(String tripId, String inviteCode) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 验证邀请码（模拟）
    if (inviteCode != 'TRIP123') {
      throw Exception('Invalid invite code');
    }

    // 模拟加入成功
    return true;
  }

  @override
  Future<List<TripModel>> getPlannedTrips() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 从JSON文件加载行程数据
    final tripsJson = await _loadJsonData('assets/mock_data/trips.json');
    if (tripsJson == null || !(tripsJson is List)) {
      return [];
    }

    // 将JSON数据转换为TripModel对象列表
    List<TripModel> allTrips =
        tripsJson.map<TripModel>((json) => TripModel.fromJson(json)).toList();

    // 筛选出状态为"planning"的行程
    return allTrips
        .where((trip) => trip.status == TripStatus.planning)
        .toList();
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    return getTripDetail(tripId);
  }
  
  @override
  Future<List<TripModel>> getAllTrips() {
    // TODO: implement getAllTrips
    throw UnimplementedError();
  }
}
