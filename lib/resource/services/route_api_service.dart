import '../../model/route/route_model.dart';

/// 路线API服务
///
/// 提供路线数据的API调用

/// 路线API服务
class RouteApiService {
  /// 获取路线列表
  Future<List<Map<String, dynamic>>> getRoutes() async {
    // 模拟API调用
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
      },
      {
        'id': '2',
        'name': '莫干山竹海徒步',
        'description': '穿越莫干山竹海的轻松徒步路线，沿途风景优美，适合初学者。',
        'distance': 8.2,
        'duration': '3-4小时',
        'difficulty': '简单',
      },
      {
        'id': '3',
        'name': '雁荡山环线',
        'description': '雁荡山经典环线徒步，途经灵峰、灵岩、大龙湫等景点，风景壮丽。',
        'distance': 22.0,
        'duration': '2天',
        'difficulty': '困难',
      },
    ];
  }

  /// 获取路线详情
  Future<Map<String, dynamic>> getRouteDetail(String routeId) async {
    // 模拟API调用
    await Future.delayed(const Duration(milliseconds: 800));

    // 返回模拟数据
    final routes = await getRoutes();
    final route = routes.firstWhere(
      (route) => route['id'] == routeId,
      orElse: () => throw Exception('路线不存在'),
    );

    // 添加更多详细信息
    if (routeId == '1') {
      route['elevation_gain'] = 1200;
      route['elevation_loss'] = 800;
      route['highest_point'] = 1864;
      route['lowest_point'] = 680;
      route['terrain_types'] = ['山地', '石阶', '森林'];
      route['seasons'] = ['春季', '秋季'];
      route['water_sources'] = ['山泉', '补给站'];
      route['camping_sites'] = ['北海营地', '西海营地'];
    } else if (routeId == '2') {
      route['elevation_gain'] = 350;
      route['elevation_loss'] = 350;
      route['highest_point'] = 758;
      route['lowest_point'] = 450;
      route['terrain_types'] = ['竹林', '山路', '乡村小道'];
      route['seasons'] = ['春季', '夏季', '秋季'];
      route['water_sources'] = ['村庄', '农家乐'];
      route['camping_sites'] = ['无'];
    } else if (routeId == '3') {
      route['elevation_gain'] = 1800;
      route['elevation_loss'] = 1800;
      route['highest_point'] = 1150;
      route['lowest_point'] = 320;
      route['terrain_types'] = ['山地', '岩石', '森林', '溪流'];
      route['seasons'] = ['春季', '秋季'];
      route['water_sources'] = ['山泉', '溪流', '补给站'];
      route['camping_sites'] = ['灵峰营地', '龙湫营地'];
    }

    return route;
  }
}