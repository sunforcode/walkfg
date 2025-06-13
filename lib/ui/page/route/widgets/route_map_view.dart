import 'package:flutter/cupertino.dart';

/// 路线地图视图组件
///
/// 显示地图、搜索栏、快捷操作按钮等功能
class RouteMapView extends StatelessWidget {
  /// 是否展开状态
  final bool isExpanded;

  /// 高度动画
  final Animation<double> animation;

  /// 展开/收起回调
  final VoidCallback onToggle;

  /// 构造函数
  const RouteMapView({
    super.key,
    required this.isExpanded,
    required this.animation,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              height: isExpanded ? animation.value : 200,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey4.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 地图占位符
                  _buildMapPlaceholder(),

                  // 地图标记点
                  ..._buildMapMarkers(),

                  // 搜索栏
                  _buildSearchBar(),

                  // 展开/收起按钮
                  _buildToggleButton(),

                  // 定位按钮
                  _buildLocationButton(),
                ],
              ),
            ),

            // 快捷操作栏
            _buildQuickActions(),
          ],
        );
      },
    );
  }

  /// 构建地图占位符
  Widget _buildMapPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: const Color(0xFFE5E5EA),
        child: Center(
          child: Icon(
            CupertinoIcons.map,
            size: 48,
            color: CupertinoColors.systemGrey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  /// 构建地图标记点
  List<Widget> _buildMapMarkers() {
    return [
      Positioned(
        top: 60,
        left: 100,
        child: _buildMapMarker('黄山徒步', CupertinoColors.activeOrange),
      ),
      Positioned(
        top: 120,
        left: 180,
        child: _buildMapMarker('莫干山骑行', CupertinoColors.activeBlue),
      ),
      Positioned(
        top: 80,
        right: 70,
        child: _buildMapMarker('千岛湖环湖', CupertinoColors.activeGreen),
      ),
    ];
  }

  /// 构建地图标记
  Widget _buildMapMarker(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.search,
              color: CupertinoColors.systemGrey,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '搜索路线、地点或关键词',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建展开/收起按钮
  Widget _buildToggleButton() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey4.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            isExpanded
                ? CupertinoIcons.chevron_up
                : CupertinoIcons.chevron_down,
            color: CupertinoColors.activeBlue,
            size: 16,
          ),
        ),
      ),
    );
  }

  /// 构建定位按钮
  Widget _buildLocationButton() {
    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          CupertinoIcons.location,
          color: CupertinoColors.activeBlue,
          size: 16,
        ),
      ),
    );
  }

  /// 构建快捷操作栏
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            icon: CupertinoIcons.location_circle,
            label: '附近路线',
            color: CupertinoColors.activeBlue,
            onTap: () {
              // 查看附近路线
            },
          ),
          _buildQuickActionButton(
            icon: CupertinoIcons.star,
            label: '精选路线',
            color: CupertinoColors.activeOrange,
            onTap: () {
              // 查看精选路线
            },
          ),
          _buildQuickActionButton(
            icon: CupertinoIcons.heart,
            label: '收藏路线',
            color: CupertinoColors.systemRed,
            onTap: () {
              // 查看收藏路线
            },
          ),
          _buildQuickActionButton(
            icon: CupertinoIcons.clock,
            label: '历史记录',
            color: CupertinoColors.systemGrey,
            onTap: () {
              // 查看历史记录
            },
          ),
        ],
      ),
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey4.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.label,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
