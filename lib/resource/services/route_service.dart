/// 路线服务类，用于处理路线相关的业务逻辑
///
/// 包含获取路线列表、路线详情等方法

import '../../model/route/route_model.dart';
import 'route_api_service.dart';

/// 路线服务类
class RouteService {
  /// API服务
  final RouteApiService _apiService = RouteApiService();
  
  /// 获取路线列表
  Future<List<Map<String, dynamic>>> getRoutes() async {
    // 模拟从API获取数据
    await Future.delayed(const Duration(milliseconds: 800));

    // 返回模拟数据
    return [
      {
        'id': '1',
        'name': '黄山主峰徒步路线',
        'description': '黄山风景区经典徒步路线，途经黄山主峰、光明顶、飞来石等著名景点。',
        'distance': 15.5,
        'duration': '6-8小时',
        'difficulty': '中等',
        'elevation_gain': 1200,
        'elevation_loss': 800,
        'highest_point': 1864,
        'lowest_point': 680,
        'terrain_types': ['山地', '石阶', '森林'],
        'seasons': ['春季', '秋季'],
        'water_sources': ['山泉', '补给站'],
        'camping_sites': ['北海营地', '西海营地'],
      },
      {
        'id': '2',
        'name': '莫干山竹海徒步',
        'description': '穿越莫干山竹海的轻松徒步路线，沿途风景优美，适合初学者。',
        'distance': 8.2,
        'duration': '3-4小时',
        'difficulty': '简单',
        'elevation_gain': 350,
        'elevation_loss': 350,
        'highest_point': 758,
        'lowest_point': 450,
        'terrain_types': ['竹林', '山路', '乡村小道'],
        'seasons': ['春季', '夏季', '秋季'],
        'water_sources': ['村庄', '农家乐'],
        'camping_sites': ['无'],
      },
      {
        'id': '3',
        'name': '雁荡山环线',
        'description': '雁荡山经典环线徒步，途经灵峰、灵岩、大龙湫等景点，风景壮丽。',
        'distance': 22.0,
        'duration': '2天',
        'difficulty': '困难',
        'elevation_gain': 1800,
        'elevation_loss': 1800,
        'highest_point': 1150,
        'lowest_point': 320,
        'terrain_types': ['山地', '岩石', '森林', '溪流'],
        'seasons': ['春季', '秋季'],
        'water_sources': ['山泉', '溪流', '补给站'],
        'camping_sites': ['灵峰营地', '龙湫营地'],
      },
    ];
  }
  
  /// 获取路线详情
  Future<Map<String, dynamic>> getRouteDetail(String routeId) async {
    // 模拟从API获取数据
    await Future.delayed(const Duration(milliseconds: 800));
      
    // 返回模拟数据
    final routes = await getRoutes();
    final route = routes.firstWhere(
      (route) => route['id'] == routeId,
      orElse: () => throw Exception('路线不存在'),
    );
      
    return route;
  }

  /// 搜索路线
  Future<List<Map<String, dynamic>>> searchRoutes(String query) async {
    // 模拟从API获取数据
    await Future.delayed(const Duration(milliseconds: 800));

    // 返回模拟数据
    final routes = await getRoutes();
    return routes.where((route) {
      final name = route['name'] as String;
      final description = route['description'] as String;
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  /// 获取推荐路线
  Future<List<Map<String, dynamic>>> getRecommendedRoutes() async {
    // 模拟从API获取数据
    await Future.delayed(const Duration(milliseconds: 800));

    // 返回模拟数据
    final routes = await getRoutes();
    return routes.take(2).toList();
  }
}