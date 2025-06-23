import 'package:dio/dio.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/model/user/user_model.dart';
import '../user_service.dart';

/// 真实的用户服务实现
///
/// 连接到实际的后台API服务
class RealUserService implements UserService {
  final ApiClient _apiClient;

  RealUserService(this._apiClient);

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userProfile);

      // 验证响应数据类型
      if (response.data is! Map<String, dynamic>) {
        throw BusinessException(
          'API返回了非JSON格式的数据，可能是HTML错误页面。请检查API端点是否正确。',
          code: 'INVALID_RESPONSE_FORMAT',
        );
      }

      // 解析API响应
      final responseData = response.data as Map<String, dynamic>;

      // 检查响应状态
      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取用户信息失败',
          code: responseData['code']?.toString(),
        );
      }

      // 解析用户数据
      final userData = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<UserModel> getUserStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userStats);

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取用户统计数据失败',
          code: responseData['code']?.toString(),
        );
      }

      final userData = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateUserProfile,
        data: user.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '更新用户信息失败',
          code: responseData['code']?.toString(),
        );
      }

      final userData = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<String> updateUserAvatar(String filePath) async {
    try {
      // 创建FormData用于文件上传
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.upload(
        ApiEndpoints.uploadAvatar,
        formData,
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '上传头像失败',
          code: responseData['code']?.toString(),
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return data['avatarUrl'] as String;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      // 通过尝试获取用户信息来检查登录状态
      await getCurrentUser();
      return true;
    } catch (e) {
      // 如果获取用户信息失败，说明未登录或token已过期
      return false;
    }
  }

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '登录失败',
          code: responseData['code']?.toString(),
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;

      // 保存token（如果API返回了token）
      if (data.containsKey('token')) {
        // TODO: 保存token到本地存储
        // await _tokenStorage.saveToken(data['token']);
      }

      // 返回用户信息
      final userData = data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<UserModel> register(
      String username, String password, String nickname) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'password': password,
          'nickname': nickname,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '注册失败',
          code: responseData['code']?.toString(),
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;

      // 保存token（如果API返回了token）
      if (data.containsKey('token')) {
        // TODO: 保存token到本地存储
        // await _tokenStorage.saveToken(data['token']);
      }

      // 返回用户信息
      final userData = data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '登出失败',
          code: responseData['code']?.toString(),
        );
      }

      // TODO: 清除本地存储的token
      // await _tokenStorage.clearToken();

      return true;
    } catch (e) {
      // 即使API调用失败，也要清除本地token
      // await _tokenStorage.clearToken();

      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }
}
