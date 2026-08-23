import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 可折叠section组件
class TripCollapsibleSectionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool initiallyExpanded;
  final Function()? onHeaderTap;

  const TripCollapsibleSectionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.initiallyExpanded = false,
    this.onHeaderTap,
  });

  @override
  State<TripCollapsibleSectionWidget> createState() =>
      _TripCollapsibleSectionWidgetState();
}

class _TripCollapsibleSectionWidgetState
    extends State<TripCollapsibleSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8), // 统一间距
      decoration: BoxDecoration(
        color: AppColors.bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 标题栏
          CupertinoButton(
            padding: const EdgeInsets.all(16),
            onPressed: widget.onHeaderTap ?? _toggleExpanded,
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 24,
                  color: widget.iconColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textWeak,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: AppColors.textWeak,
                  ),
                ),
              ],
            ),
          ),

          // 可展开内容
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.sheetDivider,
                    width: 0.5,
                  ),
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
