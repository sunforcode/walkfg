
import 'package:walk/service/user_service.dart';
import '../../model/user_model.dart';
import 'json_data_provider.dart';

/// 模拟用户服务实现
class MockUserService implements UserService {
  final JsonDataProvider _dataProvider = JsonDataProvider();

  @override
  Future<UserModel> getCurrentUser() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    return _dataProvider.getUser();
  }

  @override
  Future<UserModel> getUserStats() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    return _dataProvider.getUser();
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟更新成功
    return user;
  }

  @override
  Future<String> updateUserAvatar(String filePath) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟上传成功，返回URL
    return 'https://randomuser.me/api/portraits/men/32.jpg';
  }

  @override
  Future<bool> isUserLoggedIn() async {
    // 模拟检查登录状态
    await Future.delayed(const Duration(milliseconds: 100));

    return true;
  }

  @override
  Future<UserModel> login(String username, String password) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟登录成功
    return _dataProvider.getUser();
  }

  @override
  Future<UserModel> register(
      String username, String password, String nickname) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟注册成功
    final now = DateTime.now();
    return UserModel(
      id: 'new_user',
      username: username,
      nickname: nickname,
      avatarUrl: null,
      completedRoutes: 0,
      equipmentLists: 0,
      favoriteRoutes: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<bool> logout() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟登出成功
    return true;
  }
}
