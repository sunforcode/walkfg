import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 路线信息浮层组件 - 可拖动的底部信息面板 (PRD §3.2)
///
/// 三吸附位：min(~340px) / mid(0.4H) / max(0.95H)
/// 白色背景 + 圆顶 + 拖拽手柄 + 13 段内容
class RouteInfoSheetWidget extends StatefulWidget {
  /// 路线数据
  final RouteModel route;

  /// Section 内容组件列表（每个会被包装成独立卡片）
  final List<Widget> sections;

  /// 抽屉隐藏状态变化回调
  final ValueChanged<bool>? onHiddenChanged;

  /// 抽屉 size 变化回调
  final ValueChanged<double>? onSizeChanged;

  const RouteInfoSheetWidget({
    super.key,
    required this.route,
    required this.sections,
    this.onHiddenChanged,
    this.onSizeChanged,
  });

  @override
  State<RouteInfoSheetWidget> createState() => RouteInfoSheetWidgetState();
}

class RouteInfoSheetWidgetState extends State<RouteInfoSheetWidget> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  /// 完全收起
  static const double _minSize = 0.0;

  /// 半屏高度（初始进入状态，对应 PRD §4.1 min=340px ≈ 0.42H）
  static const double _halfSize = 0.42;

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

  void _onSheetSizeChanged() {
    if (!_controller.isAttached) return;
    final size = _controller.size;
    final hidden = size <= 0.01;
    widget.onHiddenChanged?.call(hidden);
    widget.onSizeChanged?.call(size);
  }

  /// 打开到半屏（供外部触发区调用）
  void openToHalf() => animateTo(_halfSize);

  /// 切换到指定高度
  void animateTo(double size) {
    if (!_controller.isAttached) return;
    _controller.animateTo(
      size,
      duration: const Duration(milliseconds: 350),
      curve: const Cubic(0.32, 0.72, 0, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _halfSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      snapSizes: const [_minSize, _halfSize, _maxSize],
      expand: true,
      builder: (context, scrollController) {
        return _SheetShell(
          scrollController: scrollController,
          sections: widget.sections,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
//  抽屉外壳：白色圆顶 + 拖拽手柄 + 段分割线列表
// ---------------------------------------------------------------------------

class _SheetShell extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> sections;

  const _SheetShell({
    required this.scrollController,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          color: AppColors.sheetBg,
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 拖拽手柄
              const SliverToBoxAdapter(child: _DragHandle()),

              // 段列表（带分割线）
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSection(index),
                  childCount: sections.length,
                ),
              ),

              // 底部安全区 (PRD §7.3 底部安全区 24px)
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(int index) {
    final section = sections[index];

    // 空段不渲染（PRD §4.2 D10）
    if (_isEmpty(section)) return const SizedBox.shrink();

    return Column(
      children: [
        // 非首段前加分割线 (PRD §7.3 段间分割线 1px)
        if (index > 0) const _SectionDivider(),

        // 段内 padding 16px 20px (PRD §7.3)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: section,
        ),
      ],
    );
  }

  bool _isEmpty(Widget w) {
    if (w is SizedBox) return w.width == 0.0 && w.height == 0.0;
    return false;
  }
}

// ---------------------------------------------------------------------------
//  拖拽手柄 (PRD §3.2: 36x4px, rgba(0,0,0,.15), 水平居中, 距顶 10px)
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.sheetDragHandle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  段间分割线 (PRD §7.3: 1px, rgba(0,0,0,.06))
// ---------------------------------------------------------------------------

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        color: AppColors.sheetDivider,
      ),
    );
  }
}
