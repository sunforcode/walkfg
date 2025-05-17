import '../model/trip_plan_model.dart';
import '../model/route/route_model.dart';

/// 行程规划服务接口
abstract class TripService {
  /// 获取热门路线列表
  Future<List<RouteModel>> getPopularRoutes();

  /// 获取当季推荐路线列表
  Future<List<RouteModel>> getSeasonalRoutes();

  /// 获取新晋路线列表
  Future<List<RouteModel>> getNewRoutes();

  /// 获取周末短途路线列表
  Future<List<RouteModel>> getWeekendRoutes();

  /// 按地区获取路线列表
  Future<List<RouteModel>> getRoutesByRegion(String region);

  /// 按难度获取路线列表
  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty);

  /// 按时长获取路线列表
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays);

  /// 搜索路线
  Future<List<RouteModel>> searchRoutes(String query);

  /// 获取路线详情
  Future<RouteModel> getRouteDetail(String routeId);

  /// 获取用户的行程规划列表
  Future<List<TripPlanModel>> getUserTripPlans(String userId);

  /// 获取行程规划详情
  Future<TripPlanModel> getTripPlanDetail(String tripPlanId);

  /// 创建行程规划
  Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan);

  /// 更新行程规划
  Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan);

  /// 删除行程规划
  Future<bool> deleteTripPlan(String tripPlanId);

  /// 获取路线的默认每日行程
  Future<List<DailyItinerary>> getDefaultItinerary(String routeId);

  /// 获取出发城市到路线起点的交通方案
  Future<List<TransportationPlanModel>> getTransportToStart(
      String departureCity, String routeId);

  /// 获取路线终点到出发城市的交通方案
  Future<List<TransportationPlanModel>> getTransportFromEnd(
      String departureCity, String routeId);

  /// 获取路线的推荐装备清单
  Future<List<EquipmentItemModel>> getRecommendedEquipment(
      String routeId, DateTime startDate);
}

/// 模拟行程规划服务实现
class MockTripService implements TripService {
  @override
  Future<List<RouteModel>> getPopularRoutes() async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes().sublist(0, 5);
  }

  @override
  Future<List<RouteModel>> getSeasonalRoutes() async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes().sublist(2, 7);
  }

  @override
  Future<List<RouteModel>> getNewRoutes() async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes().sublist(5, 10);
  }

  @override
  Future<List<RouteModel>> getWeekendRoutes() async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes().where((route) => route.durationDays <= 2).toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByRegion(String region) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes().where((route) => route.region == region).toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByDifficulty(
      RouteDifficulty difficulty) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes()
        .where((route) => route.difficulty == difficulty)
        .toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes()
        .where((route) =>
            route.durationDays >= minDays && route.durationDays <= maxDays)
        .toList();
  }

  @override
  Future<List<RouteModel>> searchRoutes(String query) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes()
        .where(
            (route) => route.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<RouteModel> getRouteDetail(String routeId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockRoutes().firstWhere((route) => route.id == routeId);
  }

  @override
  Future<List<TripPlanModel>> getUserTripPlans(String userId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockTripPlans().where((plan) => plan.userId == userId).toList();
  }

  @override
  Future<TripPlanModel> getTripPlanDetail(String tripPlanId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockTripPlans().firstWhere((plan) => plan.id == tripPlanId);
  }

  @override
  Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return tripPlan;
  }

  @override
  Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return tripPlan;
  }

  @override
  Future<bool> deleteTripPlan(String tripPlanId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }

  @override
  Future<List<DailyItinerary>> getDefaultItinerary(String routeId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    final route = _getMockRoutes().firstWhere((route) => route.id == routeId);
    return _getMockItinerary(route.durationDays);
  }

  @override
  Future<List<TransportationPlanModel>> getTransportToStart(
      String departureCity, String routeId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockTransport(departureCity, "起点");
  }

  @override
  Future<List<TransportationPlanModel>> getTransportFromEnd(
      String departureCity, String routeId) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockTransport("终点", departureCity);
  }

  @override
  Future<List<EquipmentItemModel>> getRecommendedEquipment(
      String routeId, DateTime startDate) async {
    // 模拟数据
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockEquipment();
  }

  // 模拟路线数据
  List<RouteModel> _getMockRoutes() {
    return [
      RouteModel(
        id: '1',
        name: '贡嘎大环线',
        description: '贡嘎大环线是中国最经典的长线徒步路线之一，环绕贡嘎山，途经多种地形和景观，包括森林、草甸、冰川和高山湖泊。',
        distance: 115.0,
        duration: "7天",
        difficulty: RouteDifficulty.hard,
        bestSeason: "春季、夏季、秋季",
        elevationGain: 5000,
        elevationLoss: 5000,
        highestPoint: 4800,
        lowestPoint: 2000,
        imageUrls: [
          'https://example.com/gongga1.jpg',
          'https://example.com/gongga2.jpg',
        ],
        region: '川西',
        rating: 4.8,
        reviewCount: 245,
        bestSeasons: ['春季', '夏季', '秋季'],
      ),
      RouteModel(
        id: '2',
        name: '四姑娘山大峰环线',
        description: '四姑娘山大峰环线是一条经典的高山徒步路线，途经四姑娘山脚下的多个山谷和垭口，可以欣赏到壮观的雪山景色。',
        distance: 45.0,
        duration: "4天",
        difficulty: RouteDifficulty.hard,
        bestSeason: "春季、夏季、秋季",
        elevationGain: 3000,
        elevationLoss: 3000,
        highestPoint: 4200,
        lowestPoint: 2500,
        imageUrls: [
          'https://example.com/siguniang1.jpg',
          'https://example.com/siguniang2.jpg',
        ],
        region: '川西',
        rating: 4.9,
        reviewCount: 187,
        bestSeasons: ['春季', '夏季', '秋季'],
      ),
      RouteModel(
        id: '3',
        name: '腾格里五湖连穿',
        description: '腾格里五湖连穿是一条穿越腾格里沙漠的徒步路线，途经五个沙漠湖泊，体验沙漠与湖泊的奇妙结合。',
        distance: 35.0,
        duration: "3天",
        difficulty: RouteDifficulty.medium,
        bestSeason: "夏季、秋季",
        elevationGain: 800,
        elevationLoss: 800,
        highestPoint: 1500,
        lowestPoint: 1200,
        imageUrls: [
          'https://example.com/tengeli1.jpg',
          'https://example.com/tengeli2.jpg',
        ],
        region: '西北',
        rating: 4.7,
        reviewCount: 156,
        bestSeasons: ['夏季', '秋季'],
      ),
      RouteModel(
        id: '4',
        name: '梅里雪山环线',
        description: '梅里雪山环线是一条环绕梅里雪山的徒步路线，途经多个藏族村落和高山草甸，可以欣赏到壮观的雪山景色。',
        distance: 80.0,
        duration: "6天",
        difficulty: RouteDifficulty.hard,
        bestSeason: "春季、秋季",
        elevationGain: 4000,
        elevationLoss: 4000,
        highestPoint: 4500,
        lowestPoint: 2200,
        imageUrls: [
          'https://example.com/meili1.jpg',
          'https://example.com/meili2.jpg',
        ],
        region: '云南',
        rating: 4.8,
        reviewCount: 134,
        bestSeasons: ['春季', '秋季'],
      ),
      RouteModel(
        id: '5',
        name: '毕棚沟徒步',
        description: '毕棚沟是一条位于四川阿坝的徒步路线，以其秋季的红叶和多彩的森林景观而闻名。',
        distance: 20.0,
        duration: "2天",
        difficulty: RouteDifficulty.medium,
        bestSeason: "春季、夏季、秋季",
        elevationGain: 1200,
        elevationLoss: 1200,
        highestPoint: 3200,
        lowestPoint: 2000,
        imageUrls: [
          'https://example.com/bipangou1.jpg',
          'https://example.com/bipangou2.jpg',
        ],
        region: '川西',
        rating: 4.5,
        reviewCount: 210,
        bestSeasons: ['春季', '夏季', '秋季'],
      ),
      RouteModel(
        id: '6',
        name: '雨崩徒步',
        description: '雨崩徒步是一条通往梅里雪山脚下神秘村落的路线，途经原始森林和高山草甸，终点是被雪山环绕的雨崩村。',
        distance: 30.0,
        duration: "3天",
        difficulty: RouteDifficulty.medium,
        bestSeason: "春季、秋季",
        elevationGain: 1800,
        elevationLoss: 1800,
        highestPoint: 3800,
        lowestPoint: 2000,
        imageUrls: [
          'https://example.com/yubeng1.jpg',
          'https://example.com/yubeng2.jpg',
        ],
        region: '云南',
        rating: 4.9,
        reviewCount: 278,
        bestSeasons: ['春季', '秋季'],
      ),
      RouteModel(
        id: '7',
        name: '鳌太穿越',
        description: '鳌太穿越是一条连接鳌头和太湖的徒步路线，途经多个山峰和村落，是华东地区经典的周末徒步路线。',
        distance: 25.0,
        duration: "2天",
        difficulty: RouteDifficulty.medium,
        bestSeason: "春季、秋季",
        elevationGain: 1000,
        elevationLoss: 1000,
        highestPoint: 1200,
        lowestPoint: 200,
        imageUrls: [
          'https://example.com/aotai1.jpg',
          'https://example.com/aotai2.jpg',
        ],
        region: '华东',
        rating: 4.3,
        reviewCount: 156,
        bestSeasons: ['春季', '秋季'],
      ),
      RouteModel(
        id: '8',
        name: '南迦巴瓦环线',
        description: '南迦巴瓦环线是一条环绕南迦巴瓦峰的徒步路线，途经多个藏族村落和高山草甸，可以欣赏到壮观的雪山景色。',
        distance: 100.0,
        duration: "8天",
        difficulty: RouteDifficulty.extreme,
        bestSeason: "春季、秋季",
        elevationGain: 5500,
        elevationLoss: 5500,
        highestPoint: 5000,
        lowestPoint: 2200,
        imageUrls: [
          'https://example.com/namba1.jpg',
          'https://example.com/namba2.jpg',
        ],
        region: '西藏',
        rating: 4.9,
        reviewCount: 89,
        bestSeasons: ['春季', '秋季'],
      ),
      RouteModel(
        id: '9',
        name: '丙察察线',
        description: '丙察察线是一条连接云南和西藏的徒步路线，途经多个高山峡谷和原始森林，是中国最具挑战性的徒步路线之一。',
        distance: 120.0,
        duration: "10天",
        difficulty: RouteDifficulty.extreme,
        bestSeason: "夏季",
        elevationGain: 6000,
        elevationLoss: 6000,
        highestPoint: 5200,
        lowestPoint: 2000,
        imageUrls: [
          'https://example.com/bingchaca1.jpg',
          'https://example.com/bingchaca2.jpg',
        ],
        region: '西藏',
        rating: 4.7,
        reviewCount: 67,
        bestSeasons: ['夏季'],
      ),
      RouteModel(
        id: '10',
        name: '莫干山徒步',
        description: '莫干山徒步是一条位于浙江的徒步路线，以其竹林景观和清新空气而闻名，是华东地区经典的一日徒步路线。',
        distance: 15.0,
        duration: "1天",
        difficulty: RouteDifficulty.easy,
        bestSeason: "春季、秋季、冬季",
        elevationGain: 500,
        elevationLoss: 500,
        highestPoint: 700,
        lowestPoint: 200,
        imageUrls: [
          'https://example.com/moganshan1.jpg',
          'https://example.com/moganshan2.jpg',
        ],
        region: '华东',
        rating: 4.4,
        reviewCount: 312,
        bestSeasons: ['春季', '秋季', '冬季'],
      ),
    ];
  }

  // 模拟行程规划数据
  List<TripPlanModel> _getMockTripPlans() {
    return [
      TripPlanModel(
        id: '1',
        userId: 'user1',
        routeId: '1',
        routeName: '贡嘎大环线',
        startDate: DateTime.now().add(const Duration(days: 30)),
        participantCount: 3,
        departureCity: '成都',
        customizedItinerary: _getMockItinerary(7),
        transportationPlans: _getMockTransport('成都', '贡嘎山起点'),
        equipmentList: _getMockEquipment(),
        lastEdited: DateTime.now(),
        status: TripPlanStatus.draft,
      ),
      TripPlanModel(
        id: '2',
        userId: 'user1',
        routeId: '3',
        routeName: '腾格里五湖连穿',
        startDate: DateTime.now().add(const Duration(days: 60)),
        participantCount: 4,
        departureCity: '银川',
        customizedItinerary: _getMockItinerary(3),
        transportationPlans: _getMockTransport('银川', '腾格里沙漠入口'),
        equipmentList: _getMockEquipment(),
        lastEdited: DateTime.now().subtract(const Duration(days: 5)),
        status: TripPlanStatus.confirmed,
      ),
      TripPlanModel(
        id: '3',
        userId: 'user1',
        routeId: '5',
        routeName: '毕棚沟徒步',
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        participantCount: 2,
        departureCity: '成都',
        customizedItinerary: _getMockItinerary(2),
        transportationPlans: _getMockTransport('成都', '毕棚沟入口'),
        equipmentList: _getMockEquipment(),
        lastEdited: DateTime.now().subtract(const Duration(days: 25)),
        status: TripPlanStatus.completed,
      ),
    ];
  }

  // 模拟每日行程数据
  List<DailyItinerary> _getMockItinerary(int days) {
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
          waypoints: _getMockWaypoints(),
          recommendedCampsite: _getMockCampsite('推荐营地$i'),
          alternateCampsites: [
            _getMockCampsite('备选营地${i}A'),
            _getMockCampsite('备选营地${i}B'),
          ],
        ),
      );
    }

    return itinerary;
  }

  // 模拟途经点数据
  List<WaypointModel> _getMockWaypoints() {
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
      WaypointModel(
        id: 'wp3',
        name: '休息点',
        description: '适合休息的平坦区域',
        latitude: 30.34567,
        longitude: 103.34567,
        elevation: 3400,
        type: WaypointType.rest,
        estimatedArrivalTime: '14:00',
      ),
    ];
  }

  // 模拟营地数据
  CampSiteModel _getMockCampsite(String name) {
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

  // 模拟交通数据
  List<TransportationPlanModel> _getMockTransport(String from, String to) {
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

  // 模拟装备数据
  List<EquipmentItemModel> _getMockEquipment() {
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
      EquipmentItemModel(
        id: 'equip6',
        name: '睡袋',
        category: '露营装备',
        isEssential: true,
        description: '舒适温度不高于5°C的睡袋',
      ),
      EquipmentItemModel(
        id: 'equip7',
        name: '防潮垫',
        category: '露营装备',
        isEssential: true,
        description: '隔热防潮的睡垫',
      ),
      EquipmentItemModel(
        id: 'equip8',
        name: '头灯',
        category: '工具',
        isEssential: true,
        description: '亮度不低于200流明的头灯',
      ),
      EquipmentItemModel(
        id: 'equip9',
        name: '水壶',
        category: '补给',
        isEssential: true,
        description: '容量不少于2L的水壶或水袋',
      ),
      EquipmentItemModel(
        id: 'equip10',
        name: '登山杖',
        category: '工具',
        isEssential: false,
        description: '减轻膝盖负担，提高稳定性',
      ),
      EquipmentItemModel(
        id: 'equip11',
        name: '急救包',
        category: '医疗',
        isEssential: true,
        description: '包含创可贴、绷带、消毒液等基本医疗用品',
      ),
      EquipmentItemModel(
        id: 'equip12',
        name: '地图/GPS',
        category: '导航',
        isEssential: true,
        description: '纸质地图或GPS设备，确保不会迷路',
      ),
    ];
  }
}
