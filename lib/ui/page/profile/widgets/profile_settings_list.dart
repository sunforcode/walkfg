import 'package:flutter/cupertino.dart';

import 'profile_list_tile.dart';
import 'profile_section_card.dart';

/// 个人页面设置列表组件
class ProfileSettingsList extends StatelessWidget {
  /// 构造函数
  const ProfileSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: '设置',
      children: [
        ProfileListTile(
          icon: CupertinoIcons.bell,
          title: '消息通知',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.settings,
          title: '通用设置',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.shield,
          title: '隐私设置',
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
}
