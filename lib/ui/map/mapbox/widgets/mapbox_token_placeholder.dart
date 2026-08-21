import 'package:flutter/cupertino.dart';

/// Mapbox token 缺失时的占位界面
class MapboxTokenPlaceholder extends StatelessWidget {
  final double height;

  const MapboxTokenPlaceholder({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: CupertinoColors.systemGrey6,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.map,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 12),
            Text(
              '3D 地图暂不可用',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '请配置 MAPBOX_TOKEN',
              style: TextStyle(
                color: CupertinoColors.tertiaryLabel,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
