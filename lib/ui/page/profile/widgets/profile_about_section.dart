import 'package:flutter/cupertino.dart';

import '../../debug/debug_menu_page.dart';
import 'profile_list_tile.dart';
import 'profile_section_card.dart';

/// 个人页面关于我们部分组件
class ProfileAboutSection extends StatelessWidget {
  /// 构造函数
  const ProfileAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: '关于',
      children: [
        ProfileListTile(
          icon: CupertinoIcons.info,
          title: '关于我们',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.question,
          title: '帮助中心',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.star,
          title: '给我们评分',
          onTap: () {
            _showFeatureNotImplementedDialog(context);
          },
        ),
        ProfileListTile(
          icon: CupertinoIcons.wrench,
          title: '调试菜单',
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const DebugMenuPage(),
              ),
            );
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
