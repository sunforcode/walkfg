import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../state/auth_notifier.dart';
import '../api_endpoints.dart';

/// 认证拦截器
///
/// 自动为请求添加认证token，并处理token过期的情况
class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// 需要认证的路径前缀列表（即使在公开路径列表中也需要认证）
  /// 这些路径优先级高于公开路径前缀
  static const List<String> _protectedPathPrefixes = [
    '/routes/my',
    '/routes/favorites',
    '/routes/completed',
    '/user',
    '/favorites',
    '/upload',
    '/trip-plans',
    '/search/history',
    '/recommendations/personalized',
    '/recommendations/history',
  ];

  /// 公开接口路径前缀列表
  /// 这些接口在没有token时不应打印警告日志
  static const List<String> _publicPathPrefixes = [
    // 认证相关
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/logout',

    // 路线模块公开接口
    '/routes/popular',
    '/routes/recommendations',
    '/routes/nearby',
    '/routes/search',
    '/routes/seasonal',
    '/routes/new',
    '/routes/weekend',
    '/routes/region/',
    '/routes/difficulty/',
    '/routes/duration',
    '/routes',

    // 攻略模块公开接口
    '/guides/popular',
    '/guides/categories',
    '/guides',

    // 装备模块公开接口
    '/equipment/items/category/',
    '/equipment/items/search',
    '/equipment/items/creator/',
    '/equipment/items',
    '/equipment/category-stats',
    '/equipment/weight-stats',
    '/equipment/latest',
    '/equipment/lightest',
    '/equipment/heaviest',
    '/equipment/weight-range',
    '/equipment/similar-weight',
    '/equipment/search-by-name',
    '/equipment/categories',
    '/equipment/recommended',

    // 行程模块公开接口
    '/trips/search',
    '/trips/upcoming',
    '/trips/popular',
    '/trips/recent',
    '/trips/statistics',
    '/trips/status/',
    '/trips/planned',
    '/trips/ongoing',
    '/trips/completed',
    '/trips',

    // 用户公开信息接口
    '/users/username/',
    '/users',

    // 其他公开接口
    '/weather/forecast',
    '/weather/marker-point/',
    '/weather',
    '/search/popular',
    '/search',
    '/system/config',
    '/system/version',
    '/supply-points',
    '/campsites',
    '/water-sources',
  ];

  /// 判断是否为公开接口（不需要认证即可访问的接口）
  ///
  /// 判断逻辑：
  /// 1. 首先检查是否是需要认证的路径（_protectedPathPrefixes）
  /// 2. 然后检查是否是公开路径前缀匹配
  /// 3. 特别处理：
  ///    - /routes/my、/routes/favorites、/routes/completed 需要认证
  ///    - /routes/ 详情接口（排除需要认证的路径）是公开的
  ///    - /users/ 详情接口是公开的（但 /user/ 个人数据需要认证）
  ///
  /// 注意：路径匹配使用前缀匹配，更长的路径优先级更高
  static bool isPublicEndpoint(String path) {
    // 1. 首先检查是否是需要认证的路径（优先级最高）
    for (final prefix in _protectedPathPrefixes) {
      if (path.startsWith(prefix)) {
        return false;
      }
    }

    // 2. 检查是否是公开路径前缀匹配
    for (final prefix in _publicPathPrefixes) {
      if (path.startsWith(prefix)) {
        return true;
      }
    }

    // 3. 特殊处理：/routes/{id} 形式的详情接口
    // 路径格式：/routes/123（不是 /routes/my 等需要认证的路径）
    // 需要排除的已在 _protectedPathPrefixes 中处理
    if (path.startsWith('/routes/')) {
      // 检查是否是 /routes/{id}/subpath 形式
      // 例如：/routes/1/ratings, /routes/1/tags 等
      final segments = path.split('/');
      if (segments.length >= 3) {
        // 检查第三个segment是否是数字（route id）
        // 或者直接判断不是已排除的路径（已在第一步检查）
        return true;
      }
    }

    // 4. 特殊处理：/users/{id} 形式的详情接口
    // 注意：/user/ (单数) 需要认证，已在 _protectedPathPrefixes 中处理
    if (path.startsWith('/users/')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        // /users/{id} 或 /users/{id}/stats
        return true;
      }
    }

    // 5. 特殊处理：/equipment/items/{id} 形式的详情接口
    if (path.startsWith('/equipment/items/')) {
      final segments = path.split('/');
      if (segments.length >= 5) {
        // /equipment/items/{id}
        return true;
      }
    }

    // 6. 特殊处理：/guides/{id} 形式的详情接口
    if (path.startsWith('/guides/')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        return true;
      }
    }

    // 7. 特殊处理：/trips/{id} 形式的详情接口
    if (path.startsWith('/trips/')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        // 排除需要认证的路径（已在第一步检查）
        return true;
      }
    }

    // 8. 特殊处理：带ID的子路径
    // 例如：/routes/1/ratings, /routes/1/tags, /routes/1/waypoints 等
    // 这些都属于公开接口
    if (path.startsWith('/routes/')) {
      // 检查是否包含 /ratings, /tags, /waypoints, /related, /comments, /map-data, /gpx
      if (path.contains('/ratings') ||
          path.contains('/tags') ||
          path.contains('/waypoints') ||
          path.contains('/related') ||
          path.contains('/comments') ||
          path.contains('/map-data') ||
          path.contains('/gpx')) {
        return true;
      }
    }

    // 默认返回 false（需要认证）
    return false;
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 检查请求是否为公开接口
      final path = options.path;
      final isPublic = isPublicEndpoint(path);

      // 获取存储的token
      final token = await _getToken();
      final tokenExists = token != null && token.isNotEmpty;

      // 打印调试信息
      if (kDebugMode) {
        debugPrint('AuthInterceptor: Request to $path');
        debugPrint('AuthInterceptor: Token exists: $tokenExists, token length: ${token?.length ?? 0}');
        debugPrint('AuthInterceptor: Is public endpoint: $isPublic');
      }

      if (tokenExists) {
        // 如果有token，无论是否是公开接口都添加到请求头
        // 这样已登录用户可以获取个性化数据
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('AuthInterceptor: Added Bearer token to request header for $path');
      } else if (!isPublic) {
        // 只有非公开接口且没有token时才打印警告
        debugPrint('AuthInterceptor: WARNING - No token found for protected endpoint: $path');
      }

      handler.next(options);
    } catch (e) {
      debugPrint('AuthInterceptor: Error adding token: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果是401错误，尝试刷新token
    if (err.response?.statusCode == 401) {
      // 先检查是否有refresh token
      final refreshToken = await _getRefreshToken();
      
      if (refreshToken == null || refreshToken.isEmpty) {
        // 没有refresh token，说明用户从未登录或已登出
        // 直接清除token并传递错误，不尝试刷新
        debugPrint('AuthInterceptor: Received 401 but no refresh token available. User not logged in.');
        await _clearTokens();
        handler.next(err);
        return;
      }

      debugPrint('AuthInterceptor: Received 401, attempting token refresh');

      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // 重新发送原始请求
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } else {
          // 刷新失败，清除token
          debugPrint('AuthInterceptor: Token refresh returned null, clearing tokens');
          await _clearTokens();
        }
      } catch (e) {
        debugPrint('AuthInterceptor: Token refresh failed: $e');
        // 清除无效的token
        await _clearTokens();
      }
    }

    handler.next(err);
  }

  /// 获取存储的token
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('AuthInterceptor: Error getting token: $e');
      return null;
    }
  }

  /// 获取刷新token
  Future<String?> _getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('AuthInterceptor: Error getting refresh token: $e');
      return null;
    }
  }

  /// 刷新token
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // 创建新的Dio实例避免循环调用
      final dio = Dio();
      // 使用统一管理的API路径
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // 检查是否是ApiResponse包装格式
        if (data['code'] == 200) {
          final responseData = data['data'];
          final newToken = responseData['token'];
          final newRefreshToken = responseData['refresh_token'];

          if (newToken != null) {
            // 保存新的token
            await _saveTokens(newToken, newRefreshToken);
            debugPrint('AuthInterceptor: Token refreshed successfully');
            return newToken;
          }
        }
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Token refresh error: $e');
    }

    return null;
  }

  /// 保存token
  Future<void> _saveTokens(String token, String? refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Error saving tokens: $e');
    }
  }

  /// 清除token
  Future<void> _clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      debugPrint('AuthInterceptor: Tokens cleared');
      
      // 通知 AuthNotifier 登出状态
      AuthNotifier().notifyLogout();
    } catch (e) {
      debugPrint('AuthInterceptor: Error clearing tokens: $e');
    }
  }

  /// 静态方法：保存登录token
  static Future<void> saveAuthTokens(String token, String? refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      debugPrint('AuthInterceptor: Auth tokens saved');
    } catch (e) {
      debugPrint('AuthInterceptor: Error saving auth tokens: $e');
    }
  }

  /// 静态方法：清除登录token
  static Future<void> clearAuthTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      debugPrint('AuthInterceptor: Auth tokens cleared');
      
      // 通知 AuthNotifier 登出状态
      AuthNotifier().notifyLogout();
    } catch (e) {
      debugPrint('AuthInterceptor: Error clearing auth tokens: $e');
    }
  }

  /// 静态方法：检查是否已登录
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('AuthInterceptor: Error checking login status: $e');
      return false;
    }
  }

  /// 静态方法：获取当前token
  static Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('AuthInterceptor: Error getting current token: $e');
      return null;
    }
  }

  /// 静态方法：获取当前refresh token
  static Future<String?> getCurrentRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('AuthInterceptor: Error getting current refresh token: $e');
      return null;
    }
  }
}
