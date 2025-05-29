import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/route/water_source_model.dart';
import 'package:walk/model/route/supply_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/route_ratings.dart';

/// 路线数据服务
/// 
/// 提供路线相关的各种数据，包括轨迹、水源、补给点等
class RouteDataService {
  /// 获取可用轨迹列表
  Future<List<TrackModel>> getAvailableTracks(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();

    // 根据路线ID返回不同的轨迹数据
    // 这里可以从API或本地数据库获取
    return [
      TrackModel(
        id: 'track_1_$routeId',
        name: '推荐路线',
        description: '经典路线，风景优美，补给充足',
        distance: 58.5,
        difficulty: RouteDifficulty.medium,
        trackType: TrackType.recommended,
        isRecommended: true,
        elevationGain: 2400,
        elevationLoss: 2400,
        estimatedTime: 32.0, // 4天 * 8小时
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.8,
        tags: ['经典', '风景优美'],
      ),
      TrackModel(
        id: 'track_2_$routeId',
        name: '挑战路线',
        description: '更具挑战性，适合有经验的徒步者',
        distance: 62.3,
        difficulty: RouteDifficulty.hard,
        trackType: TrackType.challenge,
        isChallenge: true,
        elevationGain: 2800,
        elevationLoss: 2800,
        estimatedTime: 36.0, // 4.5天 * 8小时
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.6,
        tags: ['挑战', '高难度'],
      ),
      TrackModel(
        id: 'track_3_$routeId',
        name: '冬季路线',
        description: '冬季专用路线，避开危险路段',
        distance: 55.2,
        difficulty: RouteDifficulty.medium,
        trackType: TrackType.seasonal,
        isSeasonal: true,
        suitableSeasons: ['冬季'],
        elevationGain: 2200,
        elevationLoss: 2200,
        estimatedTime: 30.0,
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.4,
        tags: ['冬季', '安全'],
      ),
      TrackModel(
        id: 'track_4_$routeId',
        name: '快速路线',
        description: '距离较短，适合时间有限的徒步者',
        distance: 52.8,
        difficulty: RouteDifficulty.easy,
        trackType: TrackType.fast,
        elevationGain: 2000,
        elevationLoss: 2000,
        estimatedTime: 24.0, // 3天 * 8小时
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
        rating: 4.2,
        tags: ['快速', '短途'],
      ),
    ];
  }

  /// 获取水源点列表
  Future<List<WaterSourceModel>> getWaterSources(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 根据路线ID返回对应的水源数据
    final waterSourcesData = [
      {
        'name': '云谷寺水源',
        'distance': 0.0,
        'location': '云谷寺入口处',
        'quality': '优',
        'availability': '全年',
        'treatment': '可直接饮用',
        'notes': '水质清澈，流量充足',
        'sourceType': '人工',
        'flowRate': '充足',
        'elevation': 800,
      },
      {
        'name': '白鹅岭山泉',
        'distance': 8.5,
        'location': '白鹅岭观景台附近',
        'quality': '良',
        'availability': '全年',
        'treatment': '建议过滤后饮用',
        'notes': '山泉水，需要简单过滤',
        'sourceType': '山泉',
        'flowRate': '一般',
        'elevation': 1600,
      },
      {
        'name': '光明顶水站',
        'distance': 12.3,
        'location': '光明顶气象站',
        'quality': '优',
        'availability': '全年',
        'treatment': '可直接饮用',
        'notes': '人工水源，水质有保障',
        'sourceType': '人工',
        'flowRate': '充足',
        'elevation': 1860,
      },
    ];

    return waterSourcesData
        .map((data) => WaterSourceModel.fromMap(data))
        .toList();
  }

  /// 获取补给点列表
  Future<List<SupplyPointModel>> getSupplyPoints(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 根据路线ID返回对应的补给点数据
    final supplyPointsData = [
      {
        'name': '云谷寺商店',
        'distance': 0.0,
        'location': '云谷寺索道站',
        'type': '综合商店',
        'status': '营业',
        'hours': '6:00-18:00',
        'items': ['食物', '饮料', '登山用品', '雨具'],
        'notes': '价格适中，商品齐全',
        'priceLevel': '适中',
        'paymentMethods': ['现金', '刷卡', '移动支付'],
        'hasHotFood': true,
        'elevation': 800,
      },
      {
        'name': '北海宾馆小卖部',
        'distance': 10.2,
        'location': '北海宾馆内',
        'type': '小卖部',
        'status': '营业',
        'hours': '7:00-21:00',
        'items': ['方便面', '饮料', '零食'],
        'notes': '山上价格较高',
        'priceLevel': '较高',
        'paymentMethods': ['现金', '移动支付'],
        'hasAccommodation': true,
        'elevation': 1630,
      },
      {
        'name': '白云宾馆商店',
        'distance': 14.8,
        'location': '白云宾馆一楼',
        'type': '综合商店',
        'status': '营业',
        'hours': '6:30-20:30',
        'items': ['热食', '饮料', '纪念品', '药品'],
        'notes': '提供热食，可刷卡支付',
        'priceLevel': '较高',
        'paymentMethods': ['现金', '刷卡', '移动支付'],
        'hasHotFood': true,
        'hasAccommodation': true,
        'elevation': 1700,
      },
    ];

    return supplyPointsData
        .map((data) => SupplyPointModel.fromMap(data))
        .toList();
  }

  /// 获取相关路线
  Future<List<RouteModel>> getRelatedRoutes(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 根据当前路线ID返回相关路线
    return [
      RouteModel(
        id: 'related_1_$routeId',
        name: '黄山西海大峡谷环线',
        description: '探索黄山最壮观的峡谷景观，体验惊险刺激的栈道徒步。',
        regionId: 'huangshan',
        ratings: RouteRatingsVO(
          ratingCount: 189,
          overall: 4.7,
          scenery: 4.8,
          difficulty: 4.6,
          experience: 4.7,
          facilities: 4.5,
        ),
        tags: ['峡谷', '栈道', '刺激'],
        difficulty: RouteDifficulty.medium,
        imageUrls: [],
        mapDataId: 'map_1',
        createdBy: 'system',
        popularity: 189,
        bestSeason: ['春季', '秋季'],
        dailyPlans: [],
      ),
      RouteModel(
        id: 'related_2_$routeId',
        name: '天都峰攀登路线',
        description: '挑战黄山最险峻的山峰，体验极限攀登的乐趣。',
        regionId: 'huangshan',
        ratings: RouteRatingsVO(
          ratingCount: 156,
          overall: 4.5,
          scenery: 4.8,
          difficulty: 4.9,
          experience: 4.6,
          facilities: 4.2,
        ),
        tags: ['攀登', '挑战', '险峻'],
        difficulty: RouteDifficulty.hard,
        imageUrls: [],
        mapDataId: 'map_2',
        createdBy: 'system',
        popularity: 156,
        bestSeason: ['春季', '夏季', '秋季'],
        dailyPlans: [],
      ),
    ];
  }

  /// 获取相关行程
  Future<List<TripModel>> getRelatedTrips(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();

    // 根据路线ID返回相关行程
    return [
      TripModel(
        id: 'trip_1_$routeId',
        name: '黄山4天3夜深度游',
        description: '专业向导带队，深度体验黄山四季美景，包含温泉住宿和专业摄影指导。适合摄影爱好者和深度游客。',
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 18)),
        status: TripStatus.planning,
        participantCount: 6,
        organizerId: 'organizer_1',
        privacySetting: 'public',
        budget: 1200.0,
        routeIds: [routeId],
        participants: [],
        itinerary: [],
      ),
      TripModel(
        id: 'trip_2_$routeId',
        name: '黄山轻松徒步周末行',
        description: '适合新手的轻松路线，周末两天一夜，体验黄山经典景色。',
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 8)),
        status: TripStatus.planning,
        participantCount: 4,
        organizerId: 'organizer_2',
        privacySetting: 'public',
        budget: 600.0,
        routeIds: [routeId],
        participants: [],
        itinerary: [],
      ),
      TripModel(
        id: 'trip_3_$routeId',
        name: '黄山挑战极限穿越',
        description: '高强度徒步路线，包含野外生存技能培训和极限挑战项目。仅限有经验的户外爱好者参加。',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 34)),
        status: TripStatus.planning,
        participantCount: 8,
        organizerId: 'organizer_3',
        privacySetting: 'public',
        budget: 2000.0,
        routeIds: [routeId],
        participants: [],
        itinerary: [],
      ),
    ];
  }

  /// 获取测试轨迹点数据（KML解析失败时的备用数据）
  Future<Map<String, dynamic>> getTestTrackData(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));

    return {
      'trackPoints': [
        {
          'latitude': 39.9042,
          'longitude': 116.4074,
          'elevation': 100,
          'name': '测试点1',
        },
        {
          'latitude': 39.9142,
          'longitude': 116.4174,
          'elevation': 110,
          'name': '测试点2',
        },
        {
          'latitude': 39.9242,
          'longitude': 116.4274,
          'elevation': 120,
          'name': '测试点3',
        },
      ],
      'waypoints': [
        {
          'latitude': 39.9042,
          'longitude': 116.4074,
          'elevation': 100,
          'name': '起点',
          'type': '起点',
        },
        {
          'latitude': 39.9242,
          'longitude': 116.4274,
          'elevation': 120,
          'name': '终点',
          'type': '终点',
        },
      ],
    };
  }
}