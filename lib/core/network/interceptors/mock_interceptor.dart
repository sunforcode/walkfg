import 'dart:math' as math;
import 'package:dio/dio.dart';

import '../../config/app_config.dart';

/// Mock数据拦截器
///
/// 在开发/测试环境提供Mock数据支持:
/// - 根据 AppConfig.useMockServices 决定是否返回Mock数据
/// - 匹配API端点路径，返回对应的Mock响应
/// - 模拟网络延迟，提供更真实的测试体验
/// - 作为第一个拦截器执行，Mock数据可以绕过所有其他拦截器
class MockInterceptor extends Interceptor {
  final _random = math.Random();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 检查是否启用Mock模式
    if (!AppConfig.instance.useMockServices) {
      return handler.next(options);
    }

    // 提取请求路径（移除 baseUrl）
    final path = options.path;

    // 尝试匹配Mock端点
    final mockData = _getMockData(path, options.queryParameters);

    if (mockData != null) {
      // 模拟网络延迟 (200-500ms)
      final delay = 200 + _random.nextInt(300);
      await Future.delayed(Duration(milliseconds: delay));

      // 返回Mock响应
      return handler.resolve(
        Response(
          requestOptions: options,
          data: mockData,
          statusCode: 200,
          statusMessage: 'OK (Mock)',
        ),
      );
    }

    // 未匹配到Mock端点，放行请求
    return handler.next(options);
  }

  /// 根据路径获取Mock数据
  Map<String, dynamic>? _getMockData(String path, Map<String, dynamic>? params) {
    // 匹配用户信息
    if (path.contains('/user/profile')) {
      return _mockUserProfile();
    }

    // 匹配天气信息
    if (path.contains('/weather')) {
      return _mockWeather();
    }

    // 匹配规划行程
    if (path.contains('/trips/planned')) {
      return _mockPlannedTrips();
    }

    // 匹配推荐路线
    if (path.contains('/routes') && !path.contains('/trips')) {
      return _mockRoutes();
    }

    // 匹配徒步攻略
    if (path.contains('/guides')) {
      return _mockGuides();
    }

    return null;
  }

  /// Mock用户信息
  Map<String, dynamic> _mockUserProfile() {
    return {
      'code': 200,
      'message': 'success',
      'data': {
        'id': 'mock_user_001',
        'username': 'hiker_zhang',
        'nickname': '张三',
        'avatar_url': 'https://picsum.photos/200',
        'completed_routes': 12,
        'equipment_lists': 3,
        'favorite_routes': 8,
        'created_at': 1640000000000,
        'updated_at': 1705200000000,
      },
    };
  }

  /// Mock天气信息
  Map<String, dynamic> _mockWeather() {
    return {
      'code': 200,
      'message': 'success',
      'data': {
        'city': '北京',
        'condition': '晴朗',
        'suitability': true,
        'temperature': 22.5,
        'wind_speed': 12.0,
        'humidity': 45.0,
        'visibility': 10.0,
        'uv_index': 5,
        'pressure': 1013.0,
        'sunrise_time': 1705200000000,
        'sunset_time': 1705240000000,
      },
    };
  }

  /// Mock规划行程列表
  Map<String, dynamic> _mockPlannedTrips() {
    return {
      'code': 200,
      'message': 'success',
      'data': {
        'content': [
          {
            'id': 'trip_001',
            'name': '鳌太穿越',
            'description': '秦岭主脊穿越，风景优美，挑战性强',
            'start_date': 1706400000000,
            'end_date': 1706832000000,
            'status': 0,
            'route_ids': ['route_001'],
            'primary_route_id': 'route_001',
            'participants': [],
            'participant_count': 4,
            'organizer_id': 'mock_user_001',
            'itinerary': [],
            'cover_url': 'https://picsum.photos/400/300?random=1',
            'budget': 2500.0,
            'privacy_setting': 'public',
            'created_at': 1705200000000,
            'updated_at': 1705200000000,
          },
          {
            'id': 'trip_002',
            'name': '武功山徒步',
            'description': '江南三大名山，高山草甸，云海日出',
            'start_date': 1707004800000,
            'end_date': 1707264000000,
            'status': 0,
            'route_ids': ['route_002'],
            'primary_route_id': 'route_002',
            'participants': [],
            'participant_count': 2,
            'organizer_id': 'mock_user_001',
            'itinerary': [],
            'cover_url': 'https://picsum.photos/400/300?random=2',
            'budget': 1200.0,
            'privacy_setting': 'public',
            'created_at': 1705200000000,
            'updated_at': 1705200000000,
          },
        ],
        'number': 0,
        'size': 10,
        'totalElements': 2,
        'totalPages': 1,
      },
    };
  }

  /// Mock推荐路线列表
  Map<String, dynamic> _mockRoutes() {
    return {
      'code': 200,
      'message': 'success',
      'data': {
        'content': [
          {
            'id': 'route_001',
            'name': '鳌太穿越',
            'description': '秦岭主脊线路，太白山到鳌山，全长约120公里',
            'region_id': 'region_001',
            'region': '陕西·秦岭',
            'default_map_id': 'map_001',
            'difficulty': 3,
            'cover_url': 'https://picsum.photos/600/400?random=1',
            'is_favorite': false,
            'popularity': 9500,
            'route_type': 1,
            'is_loop': false,
            'status': 'planning',
            'usage_count': 156,
            'tags': ['高海拔', '雪山', '草甸', '极限挑战'],
            'ratings': {
              'overall': 4.8,
              'scenery': 5.0,
              'difficulty': 4.5,
              'experience': 4.6,
              'facilities': 4.0,
              'rating_count': 100,
            },
            'marker_points': [],
            'created_at': 1700000000000,
            'updated_at': 1705200000000,
          },
          {
            'id': 'route_002',
            'name': '武功山穿越',
            'description': '江南三大名山，高山草甸，云海日出',
            'region_id': 'region_002',
            'region': '江西·萍乡',
            'default_map_id': 'map_002',
            'difficulty': 1,
            'cover_url': 'https://picsum.photos/600/400?random=2',
            'is_favorite': true,
            'popularity': 12000,
            'route_type': 1,
            'is_loop': false,

            'status': 'planning',
            'usage_count': 320,
            'tags': ['草甸', '云海', '日出', '适合新手'],
            'ratings': {
              'overall': 4.8,
              'scenery': 5.0,
              'difficulty': 4.5,
              'experience': 4.6,
              'facilities': 4.0,
              'rating_count': 100,
            },
            'marker_points': [],
            'created_at': 1700000000000,
            'updated_at': 1705200000000,
          },
          {
            'id': 'route_003',
            'name': '狼塔C+V线',
            'description': '新疆天山深处的顶级徒步线路',
            'region_id': 'region_003',
            'region': '新疆·天山',
            'default_map_id': 'map_003',
            'difficulty': 3,
            'cover_url': 'https://picsum.photos/600/400?random=3',
            'is_favorite': false,
            'popularity': 6800,
            'is_loop': false,
            'route_type': 1,
            'status': 'planning',
            'usage_count': 89,
            'tags': ['高海拔', '冰川', '原始森林', '极限挑战'],
            'ratings': {
              'overall': 4.8,
              'scenery': 5.0,
              'difficulty': 4.5,
              'experience': 4.6,
              'facilities': 4.0,
              'rating_count': 100,
            },
            'marker_points': [],
            'created_at': 1700000000000,
            'updated_at': 1705200000000,
          },
        ],
        'number': 0,
        'size': 10,
        'totalElements': 3,
        'totalPages': 1,
      },
    };
  }

  /// Mock徒步攻略列表
  Map<String, dynamic> _mockGuides() {
    return {
      'code': 200,
      'message': 'success',
      'data': {
        'content': [
          {
            'id': 'guide_001',
            'title': '鳌太穿越完整攻略（2024年春季版）',
            'content': '这是一份详细的鳌太穿越攻略...',
            'author': '老驴张三',
            'author_id': 'author_001',
            'author_avatar_url': 'https://picsum.photos/100?random=1',
            'likes': 456,
            'views': 8900,
            'publish_date': 1704067200000,
            'update_date': 1705200000000,
            'icon_code': 'e047',
            'cover_url': 'https://picsum.photos/800/600?random=11',
            'tags': ['鳌太', '秦岭', '高海拔', '装备清单'],
            'is_liked': false,
            'difficulty': 3,
            'reading_time': 15,
            'is_bookmarked': false,
            'comment_count': 89,
            'location': '陕西·秦岭',
            'best_time': '5-10月',
            'actual_cost': 2800.0,
            'actual_days': 6,
            'highlights': ['太白山顶观日出', '高山草甸', '冰川遗迹'],
            'personal_tips': ['注意高反', '天气多变需备足衣物'],
            'seasonal_advice': ['春季多雨', '夏季最佳'],
            'safety_warnings': ['不建议单人', '注意雷暴'],
            'equipment_adjustments': ['增加保暖层', '防水装备必备'],
            'route_modifications': [],
            'base_route_id': 'route_001',
            'related_guide_ids': [],
            'created_at': 1704067200000,
            'updated_at': 1705200000000,
          },
          {
            'id': 'guide_002',
            'title': '武功山三天两夜轻装穿越',
            'content': '武功山徒步详细攻略...',
            'author': '徒步李四',
            'author_id': 'author_002',
            'author_avatar_url': 'https://picsum.photos/100?random=2',
            'likes': 789,
            'views': 12300,
            'publish_date': 1703462400000,
            'update_date': 1705200000000,
            'icon_code': 'e047',
            'cover_url': 'https://picsum.photos/800/600?random=12',
            'tags': ['武功山', '草甸', '云海', '新手友好'],
            'is_liked': true,
            'difficulty': 1,
            'reading_time': 10,
            'is_bookmarked': true,
            'comment_count': 156,
            'location': '江西·萍乡',
            'best_time': '4-11月',
            'actual_cost': 1500.0,
            'actual_days': 3,
            'highlights': ['十万亩高山草甸', '金顶日出', '云海奇观'],
            'personal_tips': ['提前预定山顶住宿', '早起看日出'],
            'seasonal_advice': ['秋季最美', '冬季有雪景'],
            'safety_warnings': ['注意防晒', '雷雨天气避开山顶'],
            'equipment_adjustments': ['轻量化装备', '备用电池'],
            'route_modifications': [],
            'base_route_id': 'route_002',
            'related_guide_ids': [],
            'created_at': 1703462400000,
            'updated_at': 1705200000000,
          },
          {
            'id': 'guide_003',
            'title': '狼塔C线重装穿越记录',
            'content': '狼塔C线穿越详细记录...',
            'author': '户外王五',
            'author_id': 'author_003',
            'author_avatar_url': 'https://picsum.photos/100?random=3',
            'likes': 234,
            'views': 4500,
            'publish_date': 1702857600000,
            'update_date': 1705200000000,
            'icon_code': 'e047',
            'cover_url': 'https://picsum.photos/800/600?random=13',
            'tags': ['狼塔', '天山', '重装', '极限挑战'],
            'is_liked': false,
            'difficulty': 3,
            'reading_time': 20,
            'is_bookmarked': false,
            'comment_count': 67,
            'location': '新疆·天山',
            'best_time': '7-9月',
            'actual_cost': 5000.0,
            'actual_days': 8,
            'highlights': ['冰川穿越', '原始森林', '高山湖泊'],
            'personal_tips': ['体能要求极高', '必须有经验队友'],
            'seasonal_advice': ['仅夏季可行'],
            'safety_warnings': ['严禁单人', '天气突变频繁', '需要向导'],
            'equipment_adjustments': ['重装备齐全', '卫星电话'],
            'route_modifications': [],
            'base_route_id': 'route_003',
            'related_guide_ids': [],
            'created_at': 1702857600000,
            'updated_at': 1705200000000,
          },
          {
            'id': 'guide_004',
            'title': '贡嘎大环线逆时针穿越',
            'content': '贡嘎大环线详细攻略...',
            'author': '雪山探险者',
            'author_id': 'author_004',
            'author_avatar_url': 'https://picsum.photos/100?random=4',
            'likes': 567,
            'views': 9800,
            'publish_date': 1702252800000,
            'update_date': 1705200000000,
            'icon_code': 'e047',
            'cover_url': 'https://picsum.photos/800/600?random=14',
            'tags': ['贡嘎', '雪山', '高海拔', '摄影天堂'],
            'is_liked': false,
            'difficulty': 2,
            'reading_time': 18,
            'is_bookmarked': false,
            'comment_count': 123,
            'location': '四川·甘孜',
            'best_time': '5-6月，9-10月',
            'actual_cost': 3500.0,
            'actual_days': 7,
            'highlights': ['贡嘎雪山', '子梅垭口', '高山花海'],
            'personal_tips': ['逆时针更省力', '子梅垭口最佳观景点'],
            'seasonal_advice': ['避开雨季', '秋季最美'],
            'safety_warnings': ['高反风险', '注意保暖'],
            'equipment_adjustments': ['防寒装备', '高原药品'],
            'route_modifications': [],
            'base_route_id': 'route_004',
            'related_guide_ids': [],
            'created_at': 1702252800000,
            'updated_at': 1705200000000,
          },
        ],
        'number': 0,
        'size': 10,
        'totalElements': 4,
        'totalPages': 1,
      },
    };
  }
}
