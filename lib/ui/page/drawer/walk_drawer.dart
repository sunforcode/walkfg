import 'package:flutter/cupertino.dart';

import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/radius.dart';
import '../../../theme/tokens/sizes.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/typography.dart';
import '../../routes/app_navigator.dart';

/// P14 功能抽屉 — 左侧滑出
///
/// PRD §5 P14 规格：
/// - 方向：左侧滑出，280px 宽
/// - 动画：0.35s spring 缓动
/// - 遮罩：半透明黑色 (surfaceOverlay)
/// - 品牌区：WALK Logo + 徒步旅行助手
/// - 功能网格：3 列 8 宫格
///   v1 可用：路线、我的行程、天气、日历、装备
///   v2 预留：统计、导航、附近（点击提示"即将上线"）
/// - 底部：头像 + 昵称/未登录 + 设置图标 → P13
class WalkDrawer extends StatelessWidget {
  /// 关闭抽屉回调
  final VoidCallback onClose;

  const WalkDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.drawer,
      color: AppColors.bgDrawer,
      child: SafeArea(
        child: Column(
          children: [
            _buildBrandArea(),
            Expanded(child: _buildFunctionGrid(context)),
            _buildUserArea(context),
          ],
        ),
      ),
    );
  }

  // ─── 品牌区 ───

  Widget _buildBrandArea() {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: AppSpacing.xl,
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WALK',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: 2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '徒步旅行助手',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textWeak,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 功能网格 ───

  Widget _buildFunctionGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.0,
        physics: const NeverScrollableScrollPhysics(),
        children: _drawerItems.map((item) {
          return _DrawerGridItem(
            item: item,
            onTap: () => _onItemTap(context, item),
          );
        }).toList(),
      ),
    );
  }

  // ─── 底部用户区 ───

  Widget _buildUserArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surfaceDivider, width: 0.5),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          onClose();
          AppNavigator.pushProfile(context);
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // 头像占位
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  '🚶',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '未登录',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textWeak,
                ),
              ),
            ),
            // 设置图标
            Icon(
              CupertinoIcons.gear_solid,
              size: 18,
              color: AppColors.textWeak,
            ),
          ],
        ),
      ),
    );
  }

  // ─── 导航处理 ───

  void _onItemTap(BuildContext context, _DrawerItem item) {
    if (!item.available) {
      // v2 预留功能 — 提示"即将上线"
      onClose();
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('即将上线'),
          content: Text('${item.label}功能将在后续版本推出'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
      return;
    }

    onClose();

    switch (item.id) {
      case _DrawerItemId.route:
        AppNavigator.pushRouteDiscovery(context);
        break;
      case _DrawerItemId.trip:
        // TODO: v1 用 routeId 关联行程，后续对齐时传入真实 ID
        AppNavigator.pushTripDetail(context, routeId: 'current');
        break;
      case _DrawerItemId.weather:
        AppNavigator.pushWeather(context);
        break;
      case _DrawerItemId.calendar:
        AppNavigator.pushCalendar(context);
        break;
      case _DrawerItemId.gear:
        AppNavigator.pushGearList(context);
        break;
      case _DrawerItemId.statistics:
      case _DrawerItemId.navigation:
      case _DrawerItemId.nearby:
        // v2 — handled by !item.available above
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 数据模型
// ─────────────────────────────────────────────────────────────────────────────

enum _DrawerItemId {
  route,
  trip,
  weather,
  calendar,
  gear,
  statistics,
  navigation,
  nearby
}

class _DrawerItem {
  final _DrawerItemId id;
  final String icon;
  final String label;
  final bool available;

  const _DrawerItem({
    required this.id,
    required this.icon,
    required this.label,
    this.available = true,
  });
}

/// PRD P14 功能网格 3×3（8 功能 + 1 空）
const List<_DrawerItem> _drawerItems = [
  _DrawerItem(id: _DrawerItemId.route, icon: '🗺', label: '路线'),
  _DrawerItem(id: _DrawerItemId.trip, icon: '🥾', label: '我的行程'),
  _DrawerItem(id: _DrawerItemId.weather, icon: '⛅', label: '天气'),
  _DrawerItem(id: _DrawerItemId.gear, icon: '🎒', label: '装备'),
  _DrawerItem(id: _DrawerItemId.calendar, icon: '📅', label: '日历'),
  _DrawerItem(
      id: _DrawerItemId.statistics, icon: '📊', label: '统计', available: false),
  _DrawerItem(
      id: _DrawerItemId.navigation, icon: '🧭', label: '导航', available: false),
  _DrawerItem(
      id: _DrawerItemId.nearby, icon: '📍', label: '附近', available: false),
  // 第 9 格留空，保持 3×3 布局
];

// ─────────────────────────────────────────────────────────────────────────────
// 网格项组件
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerGridItem extends StatefulWidget {
  final _DrawerItem item;
  final VoidCallback onTap;

  const _DrawerGridItem({required this.item, required this.onTap});

  @override
  State<_DrawerGridItem> createState() => _DrawerGridItemState();
}

class _DrawerGridItemState extends State<_DrawerGridItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final labelColor =
        item.available ? AppColors.textSecondary : AppColors.textWeak;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.surfaceCardHover : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
