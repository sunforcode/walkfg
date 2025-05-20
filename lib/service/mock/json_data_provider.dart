import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/route/route_model.dart';
import '../../model/guide_model.dart';
import '../../model/weather/weather_model.dart';
import '../../model/user_model.dart';
import '../../model/trip_plan_model.dart';

/// JSON数据提供者
///
/// 从JSON文件读取模拟数据，更接近真实API的行为
class JsonDataProvider {
  // 单例实现
  static final JsonDataProvider _instance = JsonDataProvider._internal();

  /// 工厂构造函数
  factory JsonDataProvider() => _instance;

  /// 私有构造函数
  JsonDataProvider._internal();

  // 缓存的数据
  final Map<String, dynamic> _cache = {};

  /// 从JSON文件加载数据
  Future<T> _loadFromJson<T>(
      String path, T Function(dynamic json) fromJson) async {
    // 如果缓存中已有数据，直接返回
    if (_cache.containsKey(path)) {
      return _cache[path] as T;
    }

    try {
      // 读取JSON文件
      final String jsonString = await rootBundle.loadString(path);
      final dynamic jsonData = json.decode(jsonString);

      // 转换为模型对象
      final T result = fromJson(jsonData);

      // 缓存结果
      _cache[path] = result;

      return result;
    } catch (e) {
      print('Error loading JSON data from $path: $e');
      rethrow;
    }
  }

  /// 获取用户数据
  Future<UserModel> getUser({String userId = 'user1'}) async {
    final List<dynamic> usersJson = await _loadFromJson<List<dynamic>>(
      'assets/mock_data/users.json',
      (json) => json as List<dynamic>,
    );

    final userJson = usersJson.firstWhere(
      (user) => user['id'] == userId,
      orElse: () => usersJson.first,
    );

    // 确保JSON中包含必要的基础字段
    final now = DateTime.now();
    if (!userJson.containsKey('created_at')) {
      userJson['created_at'] =
          now.subtract(const Duration(days: 365)).toIso8601String();
    }
    if (!userJson.containsKey('updated_at')) {
      userJson['updated_at'] =
          now.subtract(const Duration(days: 7)).toIso8601String();
    }

    return UserModel.fromJson(userJson);
  }

  /// 获取天气数据
  Future<WeatherModel> getWeather({String city = '北京市'}) async {
    final weatherJson = await _loadFromJson<Map<String, dynamic>>(
      'assets/mock_data/weather.json',
      (json) => json as Map<String, dynamic>,
    );

    return WeatherModel.fromJson(weatherJson);
  }

  /// 获取路线数据
  Future<List<RouteModel>> getRoutes() async {
    final List<dynamic> routesList = await _loadFromJson<List<dynamic>>(
      'assets/mock_data/routes.json',
      (json) => json as List<dynamic>,
    );

    return routesList.map((item) => RouteModel.fromJson(item)).toList();
  }

  /// 获取攻略数据
  Future<List<GuideModel>> getGuides() async {
    final List<dynamic> guidesList = await _loadFromJson<List<dynamic>>(
      'assets/mock_data/guides.json',
      (json) => json as List<dynamic>,
    );

    return guidesList.map((item) => GuideModel.fromJson(item)).toList();
  }

  /// 获取行程计划数据
  Future<List<TripPlanModel>> getTripPlans() async {
    try {
      final List<dynamic> tripPlansList = await _loadFromJson<List<dynamic>>(
        'assets/mock_data/trip_plans.json',
        (json) => json as List<dynamic>,
      );

      final now = DateTime.now();
      return tripPlansList.map((item) {
        // 确保JSON中包含必要的基础字段
        if (!item.containsKey('created_at')) {
          item['created_at'] =
              now.subtract(const Duration(days: 30)).toIso8601String();
        }
        if (!item.containsKey('updated_at')) {
          item['updated_at'] =
              now.subtract(const Duration(days: 5)).toIso8601String();
        }

        return TripPlanModel.fromJson(item);
      }).toList();
    } catch (e) {
      print('Error loading trip plans: $e');
      // 如果JSON文件不存在或加载失败，返回模拟数据
      return _createMockTripPlans();
    }
  }

  /// 获取行程计划详情
  Future<TripPlanModel> getTripPlanById(String tripPlanId) async {
    final tripPlans = await getTripPlans();
    return tripPlans.firstWhere(
      (plan) => plan.id == tripPlanId,
      orElse: () => throw Exception('Trip plan not found: $tripPlanId'),
    );
  }

  /// 获取每日行程数据
  Future<List<DailyItinerary>> getItinerary(int days) async {
    try {
      final List<dynamic> itineraryList = await _loadFromJson<List<dynamic>>(
        'assets/mock_data/daily_itineraries.json',
        (json) => json as List<dynamic>,
      );

      // 查找匹配天数的行程
      final itineraryData = itineraryList.firstWhere(
        (item) => item['days'] == days,
        orElse: () => itineraryList.first,
      );

      return (itineraryData['daily_itineraries'] as List)
          .map((day) => DailyItinerary.fromJson(day))
          .toList();
    } catch (e) {
      print('Error loading itineraries: $e');
      // 如果JSON文件不存在或加载失败，返回模拟数据
      return _createMockItinerary(days);
    }
  }

  /// 获取装备数据
  Future<List<EquipmentItemModel>> getEquipment() async {
    try {
      final List<dynamic> equipmentList = await _loadFromJson<List<dynamic>>(
        'assets/mock_data/equipment.json',
        (json) => json as List<dynamic>,
      );

      return equipmentList
          .map((item) => EquipmentItemModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Error loading equipment: $e');
      // 如果JSON文件不存在或加载失败，返回模拟数据
      return _createMockEquipment();
    }
  }

  /// 获取交通方案数据
  Future<List<TransportationPlanModel>> getTransportation(
      String from, String to) async {
    try {
      final List<dynamic> transportationList =
          await _loadFromJson<List<dynamic>>(
        'assets/mock_data/transportation.json',
        (json) => json as List<dynamic>,
      );

      // 查找匹配出发地和目的地的交通方案
      final transportData = transportationList
          .where(
            (item) => item['from'] == from && item['to'] == to,
          )
          .toList();

      if (transportData.isNotEmpty) {
        return (transportData.first['plans'] as List)
            .map((plan) => TransportationPlanModel.fromJson(plan))
            .toList();
      }

      // 如果没有找到匹配的交通方案，返回模拟数据
      return _createMockTransportation(from, to);
    } catch (e) {
      print('Error loading transportation: $e');
      // 如果JSON文件不存在或加载失败，返回模拟数据
      return _createMockTransportation(from, to);
    }
  }

  /// 根据ID获取攻略
  Future<GuideModel> getGuideById(String guideId) async {
    final guides = await getGuides();
    return guides.firstWhere(
      (guide) => guide.id == guideId,
      orElse: () => throw Exception('Guide not found: $guideId'),
    );
  }

  /// 根据ID获取路线
  Future<RouteModel> getRouteById(String routeId) async {
    final routes = await getRoutes();
    return routes.firstWhere(
      (route) => route.id == routeId,
      orElse: () => throw Exception('Route not found: $routeId'),
    );
  }

  /// 解析难度字符串为枚举
  RouteDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return RouteDifficulty.easy;
      case 'medium':
        return RouteDifficulty.medium;
      case 'hard':
        return RouteDifficulty.hard;
      case 'extreme':
        return RouteDifficulty.extreme;
      default:
        return RouteDifficulty.medium;
    }
  }

  /// 从字符串获取图标
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.sunny;
      case 'cloud':
        return Icons.cloud;
      case 'cloud_queue':
        return Icons.cloud_queue;
      case 'water_drop':
        return Icons.water_drop;
      case 'flash_on':
        return Icons.flash_on;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'air':
        return Icons.air;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  /// 创建模拟行程规划数据
  List<TripPlanModel> _createMockTripPlans() {
    final now = DateTime.now();
    return [
      TripPlanModel(
        id: '1',
        userId: 'user1',
        routeId: '1',
        routeName: '贡嘎大环线',
        startDate: now.add(const Duration(days: 30)),
        participantCount: 3,
        departureCity: '成都',
        customizedItinerary: _createMockItinerary(7),
        transportationPlans: _createMockTransportation('成都', '贡嘎山起点'),
        equipmentList: _createMockEquipment(),
        status: TripPlanStatus.draft,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      TripPlanModel(
        id: '2',
        userId: 'user1',
        routeId: '3',
        routeName: '腾格里五湖连穿',
        startDate: now.add(const Duration(days: 60)),
        participantCount: 4,
        departureCity: '银川',
        customizedItinerary: _createMockItinerary(3),
        transportationPlans: _createMockTransportation('银川', '腾格里沙漠入口'),
        equipmentList: _createMockEquipment(),
        status: TripPlanStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// 创建模拟每日行程数据
  List<DailyItinerary> _createMockItinerary(int days) {
    List<DailyItinerary> itinerary = [];

    for (int i = 1; i <= days; i++) {
      itinerary.add(
        DailyItinerary(
          startPoint: '第${i}天起点',
          endPoint: '第${i}天终点',
          distance: 15.0 + i.toDouble(),
          elevationGain: 500 + i * 100,
          elevationLoss: 300 + i * 50,
          estimatedTime: 6.0,
          waypoints: _createMockWaypoints(),
          recommendedCampsite: _createMockCampsite('推荐营地$i'),
          alternateCampsites: [
            _createMockCampsite('备选营地${i}A'),
            _createMockCampsite('备选营地${i}B'),
          ],
        ),
      );
    }

    return itinerary;
  }

  /// 创建模拟途经点数据
  List<WaypointModel> _createMockWaypoints() {
    return [
      WaypointModel(
        id: 'wp1',
        name: '观景台',
        description: '可以俯瞰整个山谷的观景点',
        latitude: 30.12345,
        longitude: 103.12345,
        elevation: 3500,
        type: WaypointType.viewpoint,
        estimatedArrivalTime: '10:30',
      ),
      WaypointModel(
        id: 'wp2',
        name: '补给站',
        description: '可以补充水和食物的补给站',
        latitude: 30.23456,
        longitude: 103.23456,
        elevation: 3600,
        type: WaypointType.rest,
        estimatedArrivalTime: '12:00',
      ),
    ];
  }

  /// 创建模拟营地数据
  CampSiteModel _createMockCampsite(String name) {
    return CampSiteModel(
      id: 'camp_${name.hashCode}',
      name: name,
      description: '位于山谷中的平坦区域，视野开阔，有水源',
      latitude: 30.45678,
      longitude: 103.45678,
      elevation: 3800,
      capacity: 20,
      waterSourceDistance: 100,
      facilities: ['水源', '平坦区域', '避风处'],
      features: ['视野开阔', '靠近水源', '有遮蔽'],
    );
  }

  /// 创建模拟交通数据
  List<TransportationPlanModel> _createMockTransportation(
      String from, String to) {
    return [
      TransportationPlanModel(
        id: 'trans1',
        name: '公共交通',
        type: TransportationType.publicTransport,
        departureLocation: from,
        arrivalLocation: to,
        departureTime: '07:00',
        arrivalTime: '09:00',
        cost: 80.0,
        description: '每天7:00, 9:00, 11:00发车，客运站电话: 028-12345678',
      ),
      TransportationPlanModel(
        id: 'trans2',
        name: '包车',
        type: TransportationType.privateCar,
        departureLocation: from,
        arrivalLocation: to,
        departureTime: '自定义',
        arrivalTime: '约2小时后',
        cost: 300.0,
        description: '需提前一天预约，包车电话: 138xxxxxxxx',
      ),
    ];
  }

  /// 创建模拟装备数据
  List<EquipmentItemModel> _createMockEquipment() {
    return [
      EquipmentItemModel(
        id: 'equip1',
        name: '登山鞋',
        category: '鞋类',
        isEssential: true,
        description: '防水、防滑、支撑性好的登山鞋',
      ),
      EquipmentItemModel(
        id: 'equip2',
        name: '冲锋衣',
        category: '服装',
        isEssential: true,
        description: '防风防水透气的冲锋衣',
      ),
      EquipmentItemModel(
        id: 'equip3',
        name: '速干衣裤',
        category: '服装',
        isEssential: true,
        description: '轻便、速干、透气的衣裤',
      ),
      EquipmentItemModel(
        id: 'equip4',
        name: '保暖层',
        category: '服装',
        isEssential: true,
        description: '抓绒衣或轻薄羽绒服',
      ),
      EquipmentItemModel(
        id: 'equip5',
        name: '帐篷',
        category: '露营装备',
        isEssential: true,
        description: '三季帐或四季帐，根据季节选择',
      ),
    ];
  }
}
