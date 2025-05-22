import 'dart:convert';
import 'package:flutter/services.dart';
import '../user_service.dart';
import '../../model/user/user_model.dart';

/// Mock用户服务实现
class MockUserService implements UserService {
  /// 单例实例
  static final MockUserService _instance = MockUserService._internal();

  /// 工厂构造函数
  factory MockUserService() {
    return _instance;
  }

  /// 私有构造函数
  MockUserService._internal();

  /// 当前用户缓存
  UserModel? _currentUserCache;

  /// 从JSON文件加载数据
  Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final userJson = await _loadJsonData('assets/mock_data/current_user.json');
    if (userJson == null) {
      throw Exception('Failed to load user data');
    }

    _currentUserCache = UserModel.fromJson(userJson);
    return _currentUserCache!;
  }

  @override
  Future<UserModel> getUserStats() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final statsJson = await _loadJsonData('assets/mock_data/current_user.json');
    if (statsJson == null) {
      throw Exception('Failed to load user stats');
    }

    return UserModel.fromJson(statsJson);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新缓存
    _currentUserCache = user;

    return user;
  }

  @override
  Future<String> updateUserAvatar(String filePath) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟上传成功，返回URL
    return "https://example.com/avatars/user_avatar.jpg";
  }

  @override
  Future<bool> isUserLoggedIn() async {
    // 检查缓存
    if (_currentUserCache != null) {
      return true;
    }

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 尝试加载用户数据
    try {
      final userJson =
          await _loadJsonData('assets/mock_data/current_user.json');
      if (userJson != null) {
        _currentUserCache = UserModel.fromJson(userJson);
        return true;
      }
    } catch (e) {
      // 忽略错误
    }

    return false;
  }

  @override
  Future<UserModel> login(String username, String password) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟登录验证
    if (username == 'test' && password == '123456') {
      // 加载用户数据
      final userJson =
          await _loadJsonData('assets/mock_data/current_user.json');
      if (userJson == null) {
        throw Exception('Failed to load user data');
      }

      _currentUserCache = UserModel.fromJson(userJson);
      return _currentUserCache!;
    } else {
      throw Exception('用户名或密码不正确');
    }
  }

  @override
  Future<UserModel> register(
      String username, String password, String nickname) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 创建新用户
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      nickname: nickname,
      completedRoutes: 0,
      equipmentLists: 0,
      favoriteRoutes: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentUserCache = newUser;
    return newUser;
  }

  @override
  Future<bool> logout() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 清除缓存
    _currentUserCache = null;

    // 模拟登出成功
    return true;
  }
}
