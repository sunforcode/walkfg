import '../model/user/user_model.dart';

/// 用户服务接口
abstract class UserService {
  /// 获取当前用户信息
  Future<UserModel> getCurrentUser();

  /// 获取用户统计数据
  Future<UserModel> getUserStats();

  /// 更新用户信息
  Future<UserModel> updateUserProfile(UserModel user);

  /// 更新用户头像
  Future<String> updateUserAvatar(String filePath);

  /// 检查用户是否已登录
  Future<bool> isUserLoggedIn();

  /// 用户登录
  Future<UserModel> login(String username, String password);

  /// 用户注册
  Future<UserModel> register(String username, String password, String nickname);

  /// 用户登出
  Future<bool> logout();
}
