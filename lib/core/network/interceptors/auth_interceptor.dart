import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 认证拦截器
///
/// 自动为请求添加认证token，并处理token过期的情况
class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 获取存储的token
      final token = await _getToken();

      if (token != null && token.isNotEmpty) {
        // 添加Authorization header
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('AuthInterceptor: Added token to request ${options.path}');
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
      final response = await dio.post(
        '/walkbg/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newToken != null) {
          // 保存新的token
          await _saveTokens(newToken, newRefreshToken);
          debugPrint('AuthInterceptor: Token refreshed successfully');
          return newToken;
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
}
