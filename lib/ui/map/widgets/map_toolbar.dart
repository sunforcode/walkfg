import 'package:flutter/material.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/map_state.dart';

/// 地图工具栏
class MapToolbar extends StatelessWidget {
  final MapState mapState;
  final bool showMapTypeSelector;

  const MapToolbar({
    Key? key,
    required this.mapState,
    this.showMapTypeSelector = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 缩放按钮
            _buildToolbarButton(
              icon: Icons.add,
              tooltip: '放大',
              onPressed: () => mapState.zoomIn(),
            ),
            const SizedBox(height: 8),
            _buildToolbarButton(
              icon: Icons.remove,
              tooltip: '缩小',
              onPressed: () => mapState.zoomOut(),
            ),
            const SizedBox(height: 8),

            // 定位按钮
            _buildToolbarButton(
              icon: Icons.my_location,
              tooltip: '我的位置',
              onPressed: () => mapState.showUserLocation(),
            ),
            const SizedBox(height: 8),

            // 显示整个轨迹
            _buildToolbarButton(
              icon: Icons.route,
              tooltip: '显示整个轨迹',
              onPressed: () => mapState.showEntireTrack(),
            ),

            // 地图类型选择器
            if (showMapTypeSelector) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildMapTypeSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildMapTypeSelector() {
    return Column(
      children: [
        _buildMapTypeButton(
          icon: Icons.map,
          label: '标准',
          mapType: MapType.standard,
        ),
        const SizedBox(height: 8),
        _buildMapTypeButton(
          icon: Icons.satellite,
          label: '卫星',
          mapType: MapType.satellite,
        ),
        const SizedBox(height: 8),
        _buildMapTypeButton(
          icon: Icons.terrain,
          label: '地形',
          mapType: MapType.terrain,
        ),
      ],
    );
  }

  Widget _buildMapTypeButton({
    required IconData icon,
    required String label,
    required MapType mapType,
  }) {
    final isSelected = mapState.currentMapType == mapType;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => mapState.setMapType(mapType),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
            shape: BoxShape.circle,
            border:
                isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.blue : Colors.black54,
          ),
        ),
      ),
    );
  }
}
