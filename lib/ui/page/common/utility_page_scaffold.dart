import 'package:flutter/cupertino.dart';

import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/typography.dart';

/// Shared page structure for dense, task-oriented dark screens.
class UtilityPageScaffold extends StatelessWidget {
  const UtilityPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget body;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgBase,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title, style: AppTypography.navTitle),
        leading: leading,
        trailing: trailing,
      ),
      child: SafeArea(child: body),
    );
  }
}
