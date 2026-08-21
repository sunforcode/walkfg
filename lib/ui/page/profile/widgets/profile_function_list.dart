import 'package:flutter/cupertino.dart';

import 'profile_list_tile.dart';
import 'profile_section_card.dart';

/// 个人页面功能列表组件
class ProfileFunctionList extends StatelessWidget {
  /// 构造函数
  const ProfileFunctionList({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: '我的功能',
      children: [
        ProfileListTile(
          icon: CupertinoIcons.map,
          title: '我的路线',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.heart,
          title: '我的收藏',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.bag,
          title: '我的装备',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.doc_text,
          title: '我的攻略',
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
