import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route/route_model.dart';
import '../../../../model/map/track_point_model.dart';
import '../../../map/unified_map_widget.dart';
import '../../../map/core/map_enum.dart';

/// 路线地图占位组件
class RouteMapPlaceholderWidget extends StatefulWidget {
  /// 路线数据
  final RouteModel route;

  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 路标点
  final List<TrackPointVO> waypoints;

  /// 地图高度
  final double height;

  /// 地图点击回调
  final VoidCallback? onMapTap;

  /// 构造函数
  const RouteMapPlaceholderWidget({
    super.key,
    required this.route,
    this.trackPoints = const [],
    this.waypoints = const [],
    this.height = 300.0,
    this.onMapTap,
  });

  @override
  State<RouteMapPlaceholderWidget> createState() =>
      _RouteMapPlaceholderWidgetState();
}

class _RouteMapPlaceholderWidgetState extends State<RouteMapPlaceholderWidget> {
  MapType _currentMapType = MapType.satellite;
  MapProviderType _currentProvider = MapProviderType.google;
  bool _showTrackPoints = true;
  bool _showWaypoints = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 地图组件
            _buildMapWidget(),

            // 地图控制工具栏
            _buildMapControls(),

            // 地图信息覆盖层
            _buildMapOverlay(),

            // 点击遮罩（如果需要处理点击事件）
            if (widget.onMapTap != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onMapTap,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建地图组件
  Widget _buildMapWidget() {
    // 如果有轨迹点数据，使用真实地图
    if (widget.trackPoints.isNotEmpty || widget.waypoints.isNotEmpty) {
      return UnifiedMapWidget(
        route: widget.route,
        trackPoints: widget.trackPoints,
        waypoints: widget.waypoints,
        height: widget.height,
        showCurrentLocation: false,
        showMapTypeToolbar: false,
        showEnhancedToolbar: false,
        mapType: _currentMapType,
        mapProvider: _currentProvider,
        trackRenderMode: TrackRenderMode.normal,
        showKilometerMarkers: true,
        showPointsOfInterest: _showWaypoints,
        showElevationChart: false,
        supportOfflineMap: false,
      );
    }

    // 否则显示占位图
    return _buildPlaceholderMap();
  }

  /// 构建占位地图
  Widget _buildPlaceholderMap() {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: CupertinoColors.systemGrey6,
      child: Stack(
        children: [
          // 背景网格
          _buildGridBackground(),

          // 模拟路线
          _buildMockRoute(),

          // 中心内容
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.map,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(height: 8),
                Text(
                  '地图组件',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '等待地图功能迭代',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建网格背景
  Widget _buildGridBackground() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(),
    );
  }

  /// 构建模拟路线
  Widget _buildMockRoute() {
    return CustomPaint(
      size: Size.infinite,
      painter: MockRoutePainter(),
    );
  }

  /// 构建地图控制工具栏
  Widget _buildMapControls() {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        children: [
          // 地图类型切换
          _buildControlButton(
            icon: _getMapTypeIcon(),
            onPressed: _switchMapType,
            tooltip: '切换地图类型',
          ),

          const SizedBox(height: 8),

          // 轨迹点显示切换
          if (widget.trackPoints.isNotEmpty)
            _buildControlButton(
              icon: _showTrackPoints
                  ? CupertinoIcons.location_solid
                  : CupertinoIcons.location,
              onPressed: () {
                setState(() {
                  _showTrackPoints = !_showTrackPoints;
                });
              },
              tooltip: '轨迹点',
              isActive: _showTrackPoints,
            ),

          const SizedBox(height: 8),

          // 路标点显示切换
          if (widget.waypoints.isNotEmpty)
            _buildControlButton(
              icon: _showWaypoints
                  ? CupertinoIcons.flag_fill
                  : CupertinoIcons.flag,
              onPressed: () {
                setState(() {
                  _showWaypoints = !_showWaypoints;
                });
              },
              tooltip: '路标点',
              isActive: _showWaypoints,
            ),
        ],
      ),
    );
  }

  /// 构建地图信息覆盖层
  Widget _buildMapOverlay() {
    return Positioned(
      bottom: 12,
      left: 12,
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
              widget.route.name,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.route.distance.toStringAsFixed(1)}km · ${widget.route.difficulty.getName()}',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? CupertinoColors.activeBlue
              : CupertinoColors.white.withOpacity(0.9),
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
          color: isActive ? CupertinoColors.white : CupertinoColors.black,
          size: 20,
        ),
      ),
    );
  }

  /// 获取地图类型图标
  IconData _getMapTypeIcon() {
    switch (_currentMapType) {
      case MapType.satellite:
        return CupertinoIcons.globe;
      case MapType.terrain:
        return CupertinoIcons.map;
      case MapType.standard:
      default:
        return CupertinoIcons.map_fill;
    }
  }

  /// 切换地图类型
  void _switchMapType() {
    setState(() {
      switch (_currentMapType) {
        case MapType.standard:
          _currentMapType = MapType.satellite;
          break;
        case MapType.satellite:
          _currentMapType = MapType.terrain;
          break;
        case MapType.terrain:
          _currentMapType = MapType.standard;
          break;
        default:
          break;
      }
    });
  }
}

/// 网格背景绘制器
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.systemGrey4.withOpacity(0.3)
      ..strokeWidth = 1;

    const gridSize = 20.0;

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 模拟路线绘制器
class MockRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.activeBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    // 创建一条模拟的蜿蜒路线
    final startX = size.width * 0.1;
    final startY = size.height * 0.8;

    path.moveTo(startX, startY);

    // 添加一些曲线点
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.4,
    );

    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    // 绘制起点和终点
    final pointPaint = Paint()
      ..color = CupertinoColors.systemGreen
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(startX, startY), 6, pointPaint);

    pointPaint.color = CupertinoColors.systemRed;
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.3), 6, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
