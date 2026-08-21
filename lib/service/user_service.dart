import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/core/network/interceptors/auth_interceptor.dart';
import 'package:walk/core/network/response_unwrap.dart';
import 'package:walk/core/state/auth_notifier.dart';
import 'package:walk/model/base/base_model.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/model/user/user_stats_model.dart';

/// 用户服务
///
/// 使用静态方法，无需实例化
class UserService {
  // 禁止实例化
  UserService._();

  /// 获取当前用户信息
  static Future<UserModel> getCurrentUser() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.userProfile);

      // 验证响应数据类型
      if (response.data is! Map<String, dynamic>) {
        throw BusinessException(
          'API返回了非JSON格式的数据，可能是HTML错误页面。请检查API端点是否正确。',
          code: 'INVALID_RESPONSE_FORMAT',
        );
      }

      // 解析API响应
      final responseData = response.data as Map<String, dynamic>;

      // 解包响应并解析用户数据
      final userData = unwrapResponse(responseData);
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取用户统计数据
  static Future<UserStatsModel> getUserStats() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.userStats);

      final responseData = response.data as Map<String, dynamic>;

      final statsData = unwrapResponse(responseData);
      return UserStatsModel.fromJson(statsData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新用户信息
  static Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.updateUserProfile,
        data: user.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;

      final userData = unwrapResponse(responseData);
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新用户头像
  static Future<String> updateUserAvatar(String filePath) async {
    try {
      // 创建FormData用于文件上传
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await ApiClient.instance.upload(
        ApiEndpoints.uploadAvatar,
        formData,
      );

      final responseData = response.data as Map<String, dynamic>;

      final data = unwrapResponse(responseData);
      return data['avatarUrl'] as String;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 检查用户是否已登录
  static Future<bool> isUserLoggedIn() async {
    // 先检查本地是否有token
    final hasToken = await AuthInterceptor.isLoggedIn();
    if (!hasToken) {
      return false;
    }

    try {
      // 通过尝试获取用户信息来验证token是否有效
      await getCurrentUser();
      return true;
    } catch (e) {
      // 如果获取用户信息失败，清除token并返回false
      await AuthInterceptor.clearAuthTokens();
      ApiClient.instance.clearAuthToken();
      return false;
    }
  }

  /// 用户登录
  static Future<UserModel> login(String username, String password) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      final data = unwrapResponse(responseData);

      // 保存token到本地存储
      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (token != null) {
        await AuthInterceptor.saveAuthTokens(token, refreshToken);
        ApiClient.instance.setAuthToken(token);
      } else {
        debugPrint('UserService: WARNING - No token in login response!');
      }

      // 从响应数据构建用户模型
      final userModel = _buildUserModelFromLoginResponse(data);

      // 通知登录成功
      AuthNotifier().notifyLogin();

      return userModel;
    } catch (e) {
      debugPrint('UserService: Login error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 用户注册
  /// 注册成功后自动登录，返回包含token的用户信息
  static Future<UserModel> register({
    required String username,
    required String password,
    required String email,
    String? nickname,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'password': password,
          'email': email,
          if (nickname != null) 'nickname': nickname,
          if (phone != null) 'phone': phone,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      final data = unwrapResponse(responseData);

      // 注册成功后保存token（后端现在返回token）
      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (token != null) {
        await AuthInterceptor.saveAuthTokens(token, refreshToken);
        ApiClient.instance.setAuthToken(token);
      } else {
        debugPrint('UserService: WARNING - No token in registration response!');
      }

      // 从响应数据构建用户模型（使用登录响应解析方法）
      final userModel = _buildUserModelFromLoginResponse(data);

      // 通知登录成功（注册成功后自动登录）
      AuthNotifier().notifyLogin();

      return userModel;
    } catch (e) {
      debugPrint('UserService: Registration error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 用户登出
  static Future<bool> logout() async {
    try {
      // 先清除本地token（即使API调用失败也要清除）
      await AuthInterceptor.clearAuthTokens();
      ApiClient.instance.clearAuthToken();

      // 通知登出成功
      AuthNotifier().notifyLogout();

      // 调用登出API
      final response = await ApiClient.instance.post(ApiEndpoints.logout);

      final responseData = response.data as Map<String, dynamic>;

      unwrapResponse(responseData);

      return true;
    } catch (e) {
      // 即使API调用失败，也已经清除了本地token并通知了登出
      // 只有当是ApiException类型时才重新抛出
      if (e is ApiException) {
        rethrow;
      }
      // 其他异常（如网络错误），返回true，因为本地token已清除
      return true;
    }
  }

  /// 刷新Token
  static Future<bool> refreshToken() async {
    try {
      final currentRefreshToken = await AuthInterceptor.getCurrentRefreshToken();
      if (currentRefreshToken == null) {
        return false;
      }

      final response = await ApiClient.instance.post(
        ApiEndpoints.refreshToken,
        data: {
          'refresh_token': currentRefreshToken,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      final data = unwrapResponse(responseData);

      final newToken = data['token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newToken != null) {
        await AuthInterceptor.saveAuthTokens(newToken, newRefreshToken);
        ApiClient.instance.setAuthToken(newToken);
        return true;
      }

      return false;
    } catch (e) {
      // 刷新失败，清除token
      await AuthInterceptor.clearAuthTokens();
      ApiClient.instance.clearAuthToken();
      return false;
    }
  }

  /// 从登录响应构建用户模型
  static UserModel _buildUserModelFromLoginResponse(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      username: data['username'] as String,
      email: data['email'] as String? ?? '',
      nickname: data['nickname'] as String? ?? data['username'] as String,
      phone: data['phone'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      createdAt: data['created_at'] != null
          ? BaseModel.parseTimestamp(data['created_at'])
          : null,
    );
  }

}
