import 'package:get_it/get_it.dart';
import 'route_service.dart';
import 'route_api_service.dart';

/// 服务定位器
class ServiceLocator {
  /// 私有构造函数
  ServiceLocator._();

  /// 获取服务实例
  static T get<T extends Object>() {
    return GetIt.instance.get<T>();
  }

  /// 初始化服务定位器
  static Future<void> init() async {
    final getIt = GetIt.instance;

    // 注册API服务
    getIt.registerSingleton<RouteApiService>(RouteApiService());

    // 注册路线服务
    getIt.registerSingleton<RouteService>(RouteService());
  }
}