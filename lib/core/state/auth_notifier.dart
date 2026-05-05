import 'package:flutter/foundation.dart';

import '../network/interceptors/auth_interceptor.dart';

/// 登录状态变更类型
enum AuthChangeType {
  login,
  logout,
  tokenRefreshed,
}

/// 登录状态变更事件
class AuthStateEvent {
  final AuthChangeType type;
  final bool isLoggedIn;

  AuthStateEvent({
    required this.type,
    required this.isLoggedIn,
  });
}

/// 登录状态通知器
///
/// 用于在应用中广播登录状态的变化
/// 使用单例模式，确保全局只有一个实例
class AuthNotifier extends ChangeNotifier {
  // 单例实现
  static final AuthNotifier _instance = AuthNotifier._internal();
  factory AuthNotifier() => _instance;
  AuthNotifier._internal();

  bool _isLoggedIn = false;
  bool _isInitialized = false;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 当前是否已登录
  bool get isLoggedIn => _isLoggedIn;

  /// 初始化登录状态
  void initialize(bool loggedIn) {
    if (_isInitialized) return;
    _isInitialized = true;
    _isLoggedIn = loggedIn;
  }

  /// 从本地存储初始化登录状态
  ///
  /// 在应用启动时调用，从 AuthInterceptor 读取本地存储的 token 状态
  /// 并初始化 AuthNotifier 的登录状态
  Future<void> initializeFromStorage() async {
    print('AuthNotifier.initializeFromStorage() called, _isInitialized: $_isInitialized');
    
    if (_isInitialized) {
      print('AuthNotifier: Already initialized, skipping');
      return;
    }
    
    print('AuthNotifier: Calling AuthInterceptor.isLoggedIn()...');
    final hasToken = await AuthInterceptor.isLoggedIn();
    print('AuthNotifier: AuthInterceptor.isLoggedIn() returned: $hasToken');
    
    _isInitialized = true;
    _isLoggedIn = hasToken;
    
    print('AuthNotifier: Initialized from storage, isLoggedIn: $hasToken');
    debugPrint('AuthNotifier: Initialized from storage, isLoggedIn: $hasToken');
    
    // 通知监听器状态变化
    // 注意：这个方法在 runApp() 之前调用，Widget 可能还没有创建
    // 但为了确保状态一致性，还是调用 notifyListeners()
    if (hasToken) {
      notifyListeners();
    }
  }

  /// 通知登录成功
  void notifyLogin() {
    _isLoggedIn = true;
    notifyListeners();
  }

  /// 通知登出成功
  void notifyLogout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  /// 通知 token 刷新
  void notifyTokenRefreshed() {
    notifyListeners();
  }

  /// 手动更新登录状态
  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }
}
