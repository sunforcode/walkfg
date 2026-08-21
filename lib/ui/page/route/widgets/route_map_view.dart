import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/map_widget.dart';

/// 路线地图视图组件
///
/// 显示地图、搜索栏、快捷操作按钮等功能
/// 用于路线发现页面，展示多条路线的概览
class RouteMapView extends StatelessWidget {
  final bool isExpanded;
  final Animation<double> animation;
  final VoidCallback onToggle;
  final List<MapRouteMarker> routeMarkers;
  final VoidCallback? onSearchTap;
  final VoidCallback? onLocationTap;
  final double collapsedHeight;
  final double expandedHeight;

  const RouteMapView({
    super.key,
    required this.isExpanded,
    required this.animation,
    required this.onToggle,
    this.routeMarkers = const [],
    this.onSearchTap,
    this.onLocationTap,
    this.collapsedHeight = 200.0,
    this.expandedHeight = 400.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              height: animation.value,
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
                  _buildMap(),
                  _buildSearchBar(),
                  _buildToggleButton(),
                  _buildLocationButton(),
                ],
              ),
            ),
            _buildQuickActions(),
          ],
        );
      },
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: UnifiedMapWidget(
        trackPoints: const [],
        markers: routeMarkers.map((m) => m.toMarkerPointModel()).toList(),
        config: MapWidgetConfig(
          height: double.infinity,
          enabledFeatures: {
            MapFeature.track,
            MapFeature.poiMarkers,
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: GestureDetector(
        onTap: onSearchTap,
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
              const Icon(
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
      ),
    );
  }

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

  Widget _buildLocationButton() {
    return Positioned(
      bottom: 10,
      left: 10,
      child: GestureDetector(
        onTap: onLocationTap,
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
          child: const Icon(
            CupertinoIcons.location,
            color: CupertinoColors.activeBlue,
            size: 16,
          ),
        ),
      ),
    );
  }

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
            onTap: () {},
          ),
          _buildQuickActionButton(
            icon: CupertinoIcons.star,
            label: '精选路线',
            color: CupertinoColors.activeOrange,
            onTap: () {},
          ),
          _buildQuickActionButton(
            icon: CupertinoIcons.heart,
            label: '收藏路线',
            color: CupertinoColors.systemRed,
            onTap: () {},
          ),
          _buildQuickActionButton(
            icon: CupertinoIcons.clock,
            label: '历史记录',
            color: CupertinoColors.systemGrey,
            onTap: () {},
          ),
        ],
      ),
    );
  }

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

class MapRouteMarker {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final Color color;
  final String? type;

  const MapRouteMarker({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.color = CupertinoColors.activeBlue,
    this.type,
  });

  MarkerPointModel toMarkerPointModel() {
    return MarkerPointModel(
      id: id,
      latitude: latitude,
      longitude: longitude,
      elevation: 0,
      name: name,
      markerType: _mapType(type),
      color: _colorToHex(color),
    );
  }

  MarkerPointType _mapType(String? type) {
    switch (type) {
      case 'hiking':
        return MarkerPointType.landmark;
      case 'cycling':
        return MarkerPointType.poi;
      default:
        return MarkerPointType.poi;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
