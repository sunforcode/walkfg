import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 个人页面
class ProfileScreen extends StatelessWidget {
  /// 构造函数
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const Center(
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
                const Text(
                  '徒步爱好者',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: 12345678',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatItem('3', '已完成路线'),
                    const SizedBox(width: 16),
                    _buildStatItem('5', '收藏路线'),
                  ],
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
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建统计项
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
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
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.heart,
          '我的收藏',
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.bag,
          '我的装备',
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.doc_text,
          '我的攻略',
          onTap: () {},
        ),
      ],
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
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.settings,
          '通用设置',
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.shield,
          '隐私设置',
          onTap: () {},
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
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.question,
          '帮助中心',
          onTap: () {},
        ),
        _buildListTile(
          context,
          CupertinoIcons.star,
          '给我们评分',
          onTap: () {},
        ),
      ],
    );
  }
  
  /// 构建分区
  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
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