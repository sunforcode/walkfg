import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/service/service_manager.dart';
import '../../../model/user/user_model.dart';
import '../../page/home/widgets/stats_card.dart';

/// 个人页面
class ProfileScreen extends StatefulWidget {
  /// 构造函数
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// API服务

  /// 用户数据
  UserModel? _user;

  /// 用户统计数据Future
  late Future<UserModel> _userStatsFuture;

  /// 是否正在加载
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('ProfileScreen - initState');
    _loadUserData();
    _userStatsFuture = _loadUserStatsData();
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    print('ProfileScreen - 开始加载用户数据');
    try {
      final apiService = ServiceLocator.instance.getUserService();
      final user = await apiService.getCurrentUser();
      print('ProfileScreen - 用户数据加载成功: ${user.nickname}');
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('ProfileScreen - 加载用户数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 加载用户统计数据
  Future<UserModel> _loadUserStatsData() async {
    final userService = ServiceLocator.instance.getUserService();
    return userService.getUserStats();
  }

  /// 导航到已完成路线页面
  void _navigateToCompletedRoutes() {
    // TODO: 实现导航到已完成路线页面
    _showToast('导航到已完成路线页面');
  }

  /// 导航到装备列表页面
  void _navigateToEquipmentList() {
    // TODO: 实现导航到装备列表页面
    _showToast('导航到装备列表页面');
  }

  /// 导航到收藏路线页面
  void _navigateToFavoriteRoutes() {
    // TODO: 实现导航到收藏路线页面
    _showToast('导航到收藏路线页面');
  }

  /// 刷新用户统计数据
  void _refreshUserStats() {
    setState(() {
      _userStatsFuture = _loadUserStatsData();
    });

    // 显示刷新提示
    _showToast('统计数据已更新');
  }

  /// 显示提示信息
  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context, rootNavigator: true).pop();
        });
        return CupertinoAlertDialog(
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('ProfileScreen - build');

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
            _buildUserInfoCard(context),

            const SizedBox(height: 20),

            // 我的统计
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: StatsCard(
                userStatsFuture: _userStatsFuture,
                onCompletedRoutesPressed: _navigateToCompletedRoutes,
                onEquipmentListPressed: _navigateToEquipmentList,
                onFavoriteRoutesPressed: _navigateToFavoriteRoutes,
                onRefreshPressed: _refreshUserStats,
              ),
            ),

            const SizedBox(height: 20),

            // 功能列表
            _buildFunctionList(context),

            const SizedBox(height: 20),

            // 设置列表
            _buildSettingsList(context),

            const SizedBox(height: 20),

            // 关于我们
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              border: Border.all(
                color: CupertinoColors.systemBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _user?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      _user!.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            CupertinoIcons.person_fill,
                            size: 40,
                            color: CupertinoColors.systemBlue,
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 40,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
          ),

          const SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.nickname ?? '未知用户',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${_user?.id ?? '未知'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),

          // 编辑按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.pencil),
            onPressed: () {
              // 编辑个人资料
              _showEditProfileDialog(context);
            },
          ),
        ],
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

  /// 构建功能列表
  Widget _buildFunctionList(BuildContext context) {
    return _buildSection(
      context,
      '我的功能',
      [
        _buildListTile(
          context,
          CupertinoIcons.map,
          '我的路线',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.heart,
          '我的收藏',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.bag,
          '我的装备',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.doc_text,
          '我的攻略',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
      ],
    );
  }

  /// 显示功能未实现对话框
  void _showFeatureNotImplementedDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('提示'),
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

  /// 构建设置列表
  Widget _buildSettingsList(BuildContext context) {
    return _buildSection(
      context,
      '设置',
      [
        _buildListTile(
          context,
          CupertinoIcons.bell,
          '消息通知',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.settings,
          '通用设置',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.shield,
          '隐私设置',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
      ],
    );
  }

  /// 构建关于我们部分
  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context,
      '关于',
      [
        _buildListTile(
          context,
          CupertinoIcons.info,
          '关于我们',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.question,
          '帮助中心',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        _buildListTile(
          context,
          CupertinoIcons.star,
          '给我们评分',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
      ],
    );
  }

  /// 构建分区
  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建列表项
  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.black,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
