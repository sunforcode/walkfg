import 'api_service.dart';
import 'mock_api_service.dart';

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
  
  /// 获取API服务
  ApiService getApiService() {
    // 如果服务实例不存在，则创建一个新的实例
    _apiService ??= MockApiService();
    return _apiService!;
  }
  
  /// 设置API服务（用于测试或切换实现）
  void setApiService(ApiService apiService) {
    _apiService = apiService;
  }
}