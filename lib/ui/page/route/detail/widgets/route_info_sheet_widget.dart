import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';

/// 路线信息浮层组件 - 可拖动的底部信息面板
/// 包含拖拽条和多个独立的 Section 卡片
/// 交互：进入 40%，上划全屏，下滑完全隐藏（size=0），隐藏时通过 [onHiddenChanged] 通知外部
class RouteInfoSheetWidget extends StatefulWidget {
  /// 路线数据
  final RouteModel route;

  /// Section 内容组件列表（每个会被包装成独立卡片）
  final List<Widget> sections;

  /// 抽屉隐藏状态变化回调（true=完全隐藏，false=展开中）
  final ValueChanged<bool>? onHiddenChanged;

  const RouteInfoSheetWidget({
    super.key,
    required this.route,
    required this.sections,
    this.onHiddenChanged,
  });

  @override
  State<RouteInfoSheetWidget> createState() => RouteInfoSheetWidgetState();
}

class RouteInfoSheetWidgetState extends State<RouteInfoSheetWidget> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  /// 完全收起（抽屉滚出屏幕外）
  static const double _minSize = 0.0;

  /// 半屏高度（初始进入状态）
  static const double _halfSize = 0.40;

  /// 全屏高度
  static const double _maxSize = 0.95;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSheetSizeChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 监听抽屉尺寸变化，通知外部隐藏状态
  void _onSheetSizeChanged() {
    if (!_controller.isAttached) return;
    final hidden = _controller.size <= 0.01;
    widget.onHiddenChanged?.call(hidden);
  }

  /// 打开到半屏（供外部触发区调用）
  void openToHalf() => animateTo(_halfSize);

  /// 切换到指定高度（供外部调用）
  void animateTo(double size) {
    if (!_controller.isAttached) return;
    _controller.animateTo(
      size,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // DraggableScrollableSheet 需要直接放在有约束的父容器里
    // 外层由 route_detail_screen.dart 的 Positioned.fill 提供全屏约束
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _halfSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      snapSizes: const [_minSize, _halfSize, _maxSize],
      expand: true,
      builder: (context, scrollController) {
        // 用 CustomScrollView 将拖拽条 + 内容列表合并到同一个可滚动容器里
        // 避免 Column + Expanded 在抽屉小高度时 overflow
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [

                // 内容卡片列表
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildSectionCard(index),
                      childCount: widget.sections.length,
                    ),
                  ),
                ),
              ],
            ),
        );
      },
    );
  }


  /// 构建单个 section 卡片
  Widget _buildSectionCard(int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.0),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.sections[index],
      ),
    );
  }
}
