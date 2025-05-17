import 'api_service.dart';
import 'mock_api_service.dart';
import 'trip_service.dart';

/// 服务定位器
/// 用于获取各种服务的实例
class ServiceLocator {
  /// 私有构造函数
  ServiceLocator._();

  /// 单例实例
  static final ServiceLocator _instance = ServiceLocator._();

  /// 获取单例实例
  static ServiceLocator get instance => _instance;

  /// API服务实例
  ApiService? _apiService;

  /// 行程服务实例
  TripService? _tripService;

  /// 初始化服务
  void setup() {
    // 初始化API服务
    _apiService = MockApiService();

    // 初始化行程服务
    _tripService = MockTripService();
  }

  /// 获取API服务
  ApiService getApiService() {
    // 如果服务实例不存在，则创建一个新的实例
    _apiService ??= MockApiService();
    return _apiService!;
  }

  /// 获取行程服务
  TripService getTripService() {
    // 如果服务实例不存在，则创建一个新的实例
    _tripService ??= MockTripService();
    return _tripService!;
  }

  /// 设置API服务（用于测试或切换实现）
  void setApiService(ApiService apiService) {
    _apiService = apiService;
  }

  /// 设置行程服务（用于测试或切换实现）
  void setTripService(TripService tripService) {
    _tripService = tripService;
  }
}
