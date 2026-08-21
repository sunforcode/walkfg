import 'package:flutter/cupertino.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// 地图控件按钮（圆形图标按钮）
class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final Color? activeColor;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isActive
        ? (activeColor ?? CupertinoColors.systemBlue)
        : CupertinoColors.systemGrey4;
    final iconColor = isActive ? CupertinoColors.white : CupertinoColors.label;

    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      color: buttonColor.withOpacity(0.9),
      borderRadius: BorderRadius.circular(25),
      minSize: 0,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }
}

/// 地图控件覆盖层（右上角按钮组 + 左下角按钮）
class MapControlsOverlay extends StatelessWidget {
  final bool hasCurrentLocation;
  final bool isFollowingLocation;
  final bool showElevationChart;
  final VoidCallback onToggleFollowLocation;
  final VoidCallback onShowMapTypeSelector;
  final VoidCallback onLayersPressed;
  final VoidCallback onScopePressed;

  const MapControlsOverlay({
    super.key,
    required this.hasCurrentLocation,
    required this.isFollowingLocation,
    required this.showElevationChart,
    required this.onToggleFollowLocation,
    required this.onShowMapTypeSelector,
    required this.onLayersPressed,
    required this.onScopePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Returns a list isn't possible for a single widget, so this is used
    // via buildMapControls() static method below.
    throw UnimplementedError('Use MapControlsOverlay.buildMapControls() instead');
  }

  /// 构建地图控件组件列表（用于 Stack children）
  static List<Widget> buildMapControls({
    required bool hasCurrentLocation,
    required bool isFollowingLocation,
    required bool showElevationChart,
    required VoidCallback onToggleFollowLocation,
    required VoidCallback onShowMapTypeSelector,
    required VoidCallback onLayersPressed,
    required VoidCallback onScopePressed,
  }) {
    return [
      Positioned(
        top: 16,
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCurrentLocation)
              MapControlButton(
                icon: isFollowingLocation
                    ? CupertinoIcons.location_fill
                    : CupertinoIcons.location,
                isActive: isFollowingLocation,
                onPressed: onToggleFollowLocation,
              ),
            const SizedBox(height: 8),
            MapControlButton(
              icon: CupertinoIcons.map,
              onPressed: onShowMapTypeSelector,
            ),
            const SizedBox(height: 8),
            MapControlButton(
              icon: CupertinoIcons.layers_alt,
              onPressed: onLayersPressed,
            ),
          ],
        ),
      ),
      Positioned(
        bottom: showElevationChart ? 200 : 16,
        left: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MapControlButton(
              icon: CupertinoIcons.scope,
              onPressed: onScopePressed,
            ),
          ],
        ),
      ),
    ];
  }
}

/// 地图类型选择器（ActionSheet）
void showMapTypeSelectorSheet({
  required BuildContext context,
  required ValueChanged<MapType> onMapTypeSelected,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: const Text('选择地图类型'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            onMapTypeSelected(MapType.standard);
            Navigator.pop(context);
          },
          child: const Text('标准地图'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            onMapTypeSelected(MapType.satellite);
            Navigator.pop(context);
          },
          child: const Text('卫星地图'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            onMapTypeSelected(MapType.terrain);
            Navigator.pop(context);
          },
          child: const Text('地形地图'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
    ),
  );
}
