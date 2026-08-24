import 'package:flutter/cupertino.dart';

import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';

/// Shared full-bleed structure for immersive pages with optional top actions.
class ImmersivePageScaffold extends StatelessWidget {
  const ImmersivePageScaffold({
    super.key,
    required this.body,
    this.leadingAction,
    this.trailingAction,
  });

  final Widget body;
  final Widget? leadingAction;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final actionTop = MediaQuery.viewPaddingOf(context).top + AppSpacing.sm;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgBase,
      child: Stack(
        fit: StackFit.expand,
        children: [
          body,
          if (leadingAction case final action?)
            Positioned(
              top: actionTop,
              left: AppSpacing.heroHorizontal,
              child: action,
            ),
          if (trailingAction case final action?)
            Positioned(
              top: actionTop,
              right: AppSpacing.heroHorizontal,
              child: action,
            ),
        ],
      ),
    );
  }
}
