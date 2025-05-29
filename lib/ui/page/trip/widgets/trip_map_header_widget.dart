import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';

/// 行程地图头部组件
class TripMapHeaderWidget extends StatelessWidget {
  final RouteModel? route;
  final double height;

  const TripMapHeaderWidget({
    super.key,
    this.route,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // 地图占位符
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemBlue.withOpacity(0.3),
                  CupertinoColors.systemGreen.withOpacity(0.3),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.map,
                    size: 48,
                    color: CupertinoColors.systemBlue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '路线地图',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 路线信息覆盖层
          if (route != null)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route!.name,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.location,
                          size: 12,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route!.distance?.toStringAsFixed(1) ?? "0"}km',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_up,
                          size: 12,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route!.elevationGain?.toString() ?? "0"}m',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 地图控制按钮
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                _buildMapControlButton(
                  CupertinoIcons.zoom_in,
                  () => _handleZoomIn(),
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  CupertinoIcons.zoom_out,
                  () => _handleZoomOut(),
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  CupertinoIcons.location,
                  () => _handleCenterMap(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: CupertinoColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: CupertinoColors.systemBlue,
        ),
      ),
    );
  }

  void _handleZoomIn() {
    // TODO: 实现放大功能
  }

  void _handleZoomOut() {
    // TODO: 实现缩小功能
  }

  void _handleCenterMap() {
    // TODO: 实现居中功能
  }
}