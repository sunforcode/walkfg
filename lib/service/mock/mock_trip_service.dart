import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../trip_service.dart';
import '../../model/trip/trip_model.dart';

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

    try {
      // 从JSON文件加载行程数据
      final tripsJson = await _loadJsonData('assets/mock_data/trips.json');
      if (tripsJson == null || !(tripsJson is List)) {
        debugPrint('行程数据为空或格式不正确');
        return [];
      }

      // 将JSON数据转换为TripModel对象列表
      debugPrint('开始解析行程数据，共 ${tripsJson.length} 条记录');

      List<TripModel> allTrips = [];
      for (int i = 0; i < tripsJson.length; i++) {
        try {
          debugPrint('解析第 ${i + 1} 条行程数据...');
          final tripJson = tripsJson[i];

          // 检查关键字段
          debugPrint('检查行程字段: id=${tripJson['id']}, name=${tripJson['name']}');
          debugPrint(
              'itinerary字段: ${tripJson.containsKey('itinerary') ? '存在' : '不存在'}');

          if (tripJson.containsKey('itinerary')) {
            final itinerary = tripJson['itinerary'];
            debugPrint(
                'itinerary类型: ${itinerary.runtimeType}, ${itinerary is List ? '是List' : '不是List'}');

            if (itinerary != null && itinerary is List) {
              debugPrint('itinerary长度: ${itinerary.length}');

              for (int j = 0; j < itinerary.length; j++) {
                final day = itinerary[j];
                debugPrint(
                    '第 ${j + 1} 天: day=${day['day']}, title=${day['title']}');

                if (day.containsKey('campsite')) {
                  final campsite = day['campsite'];
                  debugPrint('campsite: ${campsite != null ? '存在' : 'null'}');

                  if (campsite != null) {
                    debugPrint(
                        'campsite字段: id=${campsite['id']}, name=${campsite['name']}');
                  }
                }
              }
            }
          }

          final trip = TripModel.fromJson(tripJson);
          allTrips.add(trip);
          debugPrint('成功解析第 ${i + 1} 条行程数据');
        } catch (e, stackTrace) {
          debugPrint('解析第 ${i + 1} 条行程数据失败: $e');
          debugPrint('堆栈跟踪: $stackTrace');
        }
      }

      debugPrint('成功解析 ${allTrips.length} 条行程数据');

      // 筛选出状态为"planning"的行程
      final plannedTrips =
          allTrips.where((trip) => trip.status == TripStatus.planning).toList();

      debugPrint('筛选出 ${plannedTrips.length} 条规划中的行程');
      return plannedTrips;
    } catch (e, stackTrace) {
      debugPrint('加载规划行程失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      return [];
    }
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
