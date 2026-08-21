import 'package:flutter/cupertino.dart';
import 'package:walk/ui/map/mapbox/mapbox_style.dart';

/// Mapbox 缩放按钮组
class MapboxZoomButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapboxZoomButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapboxZoomButton(
          icon: CupertinoIcons.plus,
          onPressed: onZoomIn,
        ),
        const SizedBox(height: 4),
        _MapboxZoomButton(
          icon: CupertinoIcons.minus,
          onPressed: onZoomOut,
        ),
      ],
    );
  }
}

class _MapboxZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapboxZoomButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: CupertinoColors.label),
      ),
    );
  }
}

/// Mapbox 样式切换按钮组
class MapboxStyleSwitcher extends StatelessWidget {
  final MapboxStyle currentStyle;
  final ValueChanged<MapboxStyle> onStyleChanged;

  const MapboxStyleSwitcher({
    super.key,
    required this.currentStyle,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: MapboxStyle.values.map((style) {
          final isSelected = currentStyle == style;
          return GestureDetector(
            onTap: () => onStyleChanged(style),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                style.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.label,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
