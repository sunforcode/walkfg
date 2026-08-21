import 'package:flutter/cupertino.dart';
import 'package:walk/core/network/interceptors/auth_interceptor.dart';
import 'package:walk/core/state/auth_notifier.dart';
import 'package:walk/service/user_service.dart';
import '../../../model/user/user_model.dart';
import '../../../model/user/user_stats_model.dart';
import '../../page/home/widgets/stats_card.dart';
import 'login_screen.dart';
import 'auth/register_screen.dart';
import 'package:walk/utils/toast_utils.dart';
import 'widgets/not_logged_in_view.dart';
import 'widgets/profile_about_section.dart';
import 'widgets/profile_function_list.dart';
import 'widgets/profile_settings_list.dart';
import 'widgets/user_info_card.dart';

/// 个人页面
class ProfileScreen extends StatefulWidget {
  /// 构造函数
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// 用户数据
  UserModel? _user;

  /// 用户统计数据 Future
  Future<UserStatsModel>? _userStatsFuture;

  /// 是否正在加载
  bool _isLoading = true;

  /// 是否已登录
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndLoadData();

    // 监听登录状态变化
    AuthNotifier().addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    // 移除登录状态监听
    AuthNotifier().removeListener(_onAuthStateChanged);
    super.dispose();
  }

  /// 登录状态变化回调
  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {
        _isLoggedIn = AuthNotifier().isLoggedIn;
        _isLoading = false;
      });
      
      // 如果已登录，重新加载用户数据
      if (AuthNotifier().isLoggedIn) {
        _loadUserData();
        _userStatsFuture = _loadUserStatsData();
      } else {
        // 如果已登出，清除用户数据
        setState(() {
          _user = null;
          _userStatsFuture = null;
        });
      }
    }
  }

  /// 检查登录状态并加载数据
  void _checkLoginStatusAndLoadData() {
    // 使用 AuthNotifier 的状态（已在 main() 中从本地存储初始化）
    final isLoggedIn = AuthNotifier().isLoggedIn;

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    }

    if (isLoggedIn) {
      _loadUserData();
      _userStatsFuture = _loadUserStatsData();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          _isLoggedIn = true;
        });
      }
    } catch (e) {
      debugPrint('ProfileScreen - 加载用户数据失败: $e');
      // 获取用户数据失败，清除 token 并通知登出
      await AuthInterceptor.clearAuthTokens();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = false;
          _user = null;
          _userStatsFuture = null;
        });
      }
    }
  }

  /// 加载用户统计数据
  Future<UserStatsModel> _loadUserStatsData() async {
    try {
      return await UserService.getUserStats();
    } catch (e) {
      debugPrint('ProfileScreen - 加载用户统计数据失败: $e');
      rethrow;
    }
  }

  /// 导航到已完成路线页面
  void _navigateToCompletedRoutes() {
    // TODO: 实现导航到已完成路线页面
    ToastUtils.showToast(context, '导航到已完成路线页面');
  }

  /// 导航到装备列表页面
  void _navigateToEquipmentList() {
    // TODO: 实现导航到装备列表页面
    ToastUtils.showToast(context, '导航到装备列表页面');
  }

  /// 导航到收藏路线页面
  void _navigateToFavoriteRoutes() {
    // TODO: 实现导航到收藏路线页面
    ToastUtils.showToast(context, '导航到收藏路线页面');
  }

  /// 刷新用户统计数据
  void _refreshUserStats() {
    if (!_isLoggedIn) {
      ToastUtils.showToast(context, '请先登录');
      return;
    }
    
    setState(() {
      _userStatsFuture = _loadUserStatsData();
    });

    // 显示刷新提示
    ToastUtils.showToast(context, '统计数据已更新');
  }

  /// 显示提示信息

  /// 导航到登录页面
  void _navigateToLogin() {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    )
        .then((result) {
      // 如果登录成功，刷新页面
      if (result == true) {
        setState(() {
          _isLoading = true;
          _isLoggedIn = true;
        });
        _loadUserData();
        _userStatsFuture = _loadUserStatsData();
      }
    });
  }

  /// 导航到注册页面
  void _navigateToRegister() {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    )
        .then((result) {
      // 如果注册成功，刷新页面
      if (result == true) {
        setState(() {
          _isLoading = true;
          _isLoggedIn = true;
        });
        _loadUserData();
        _userStatsFuture = _loadUserStatsData();
      }
    });
  }

  /// 退出登录
  void _logout() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('退出'),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await UserService.logout();
                  if (mounted) {
                    setState(() {
                      _user = null;
                      _isLoggedIn = false;
                    });
                    ToastUtils.showToast(context, '已退出登录');
                  }
                } catch (e) {
                  if (mounted) {
                    ToastUtils.showToast(context, '退出登录失败：$e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('个人中心'),
        ),
        child: SafeArea(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }

    // 未登录状态
    if (!_isLoggedIn) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('个人中心'),
        ),
        child: SafeArea(
          child: NotLoggedInView(
            onLoginPressed: _navigateToLogin,
            onRegisterPressed: _navigateToRegister,
          ),
        ),
      );
    }

    // 用户数据为空时显示错误信息
    if (_user == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('个人中心'),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 50,
                  color: CupertinoColors.systemRed,
                ),
                const SizedBox(height: 16),
                const Text(
                  '加载用户数据失败',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Text('重试'),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadUserData();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('个人中心'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 用户信息卡片
            UserInfoCard(
              user: _user,
              onEditPressed: () => _showEditProfileDialog(context),
            ),

            const SizedBox(height: 20),

            // 我的统计
            if (_userStatsFuture != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: StatsCard(
                  userStatsFuture: _userStatsFuture!,
                  onCompletedRoutesPressed: _navigateToCompletedRoutes,
                  onEquipmentListPressed: _navigateToEquipmentList,
                  onFavoriteRoutesPressed: _navigateToFavoriteRoutes,
                  onRefreshPressed: _refreshUserStats,
                ),
              ),

            const SizedBox(height: 20),

            // 功能列表
            const ProfileFunctionList(),

            const SizedBox(height: 20),

            // 设置列表
            const ProfileSettingsList(),

            const SizedBox(height: 20),

            // 关于我们
            const ProfileAboutSection(),

            const SizedBox(height: 20),

            // 退出登录按钮
            CupertinoButton(
              color: CupertinoColors.systemRed,
              child: const Text('退出登录'),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示编辑个人资料对话框
  void _showEditProfileDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('编辑个人资料'),
          content: const Text('此功能尚未实现'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
