import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';
import '../../map/route_map_widget.dart';
import 'elevation_chart.dart';

/// 路线地图标签页
class RouteMapTab extends StatefulWidget {
  /// 路线数据
  final RouteModel route;

  /// 路线关键点数据Future
  final Future<Map<String, dynamic>> waypointsFuture;

  /// 构造函数
  const RouteMapTab({
    super.key,
    required this.route,
    required this.waypointsFuture,
  });

  @override
  State<RouteMapTab> createState() => _RouteMapTabState();
}

class _RouteMapTabState extends State<RouteMapTab> {
  /// 当前地图类型
  MapType _currentMapType = MapType.standard;

  /// 是否显示3D地图
  bool _show3DMap = false;

  /// 是否显示所有关键点
  bool _showAllWaypoints = true;

  /// 选中的关键点类型
  String _selectedWaypointType = '全部';

  /// 关键点类型列表
  final List<String> _waypointTypes = ['全部', '营地', '补给', '景点', '危险'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地图组件
        _buildMapSection(),

        // 高程图
        _buildElevationChart(),

        // 地图控制按钮
        _buildMapControls(),

        // 关键点筛选
        _buildWaypointFilter(),

        // 关键点列表
        Expanded(
          child: _buildWaypointsList(),
        ),
      ],
    );
  }

  /// 构建地图部分
  Widget _buildMapSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: RouteMapWidget(
        route: widget.route,
        showCurrentLocation: false,
        showMapTypeToolbar: false,
        mapType: _currentMapType,
        onMapTypeChanged: (mapType) {
          setState(() {
            _currentMapType = mapType;
          });
        },
      ),
    );
  }

  /// 构建高程图
  Widget _buildElevationChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text("data"),
      // child: ElevationChart(
      // trackPoints: widget.route.trackPoints!,
      // highestPoint: widget.route.highestPoint!.elevation.toInt(),
      // lowestPoint: widget.route.lowestPoint!.elevation.toInt(),
      // ),
    );
  }

  /// 构建地图控制按钮
  Widget _buildMapControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMapControlButton(
            _show3DMap ? CupertinoIcons.map : CupertinoIcons.map_fill,
            _show3DMap ? '2D' : '3D',
            () {
              setState(() {
                _show3DMap = !_show3DMap;
              });
            },
          ),
          _buildMapControlButton(
            CupertinoIcons.zoom_in,
            '缩放',
            () {
              // 实现缩放功能
            },
          ),
          _buildMapControlButton(
            CupertinoIcons.location,
            '定位',
            () {
              // 实现定位功能
            },
          ),
          _buildMapControlButton(
            CupertinoIcons.layers,
            '图层',
            () {
              _showMapTypeSelector();
            },
          ),
        ],
      ),
    );
  }

  /// 构建地图控制按钮
  Widget _buildMapControlButton(
      IconData icon, String label, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: CupertinoColors.activeBlue,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示地图类型选择器
  void _showMapTypeSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择地图类型'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.standard;
              });
              Navigator.pop(context);
            },
            child: const Text('标准地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.satellite;
              });
              Navigator.pop(context);
            },
            child: const Text('卫星地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.terrain;
              });
              Navigator.pop(context);
            },
            child: const Text('地形图'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 构建关键点筛选
  Widget _buildWaypointFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _waypointTypes.length,
        itemBuilder: (context, index) {
          final type = _waypointTypes[index];
          final isSelected = type == _selectedWaypointType;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(20),
              minSize: 30,
              onPressed: () {
                setState(() {
                  _selectedWaypointType = type;
                });
              },
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建关键点列表
  Widget _buildWaypointsList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.waypointsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('暂无关键点数据'),
          );
        }

        final waypoints = snapshot.data!['waypoints'] as List<dynamic>;

        // 根据选中的类型筛选关键点
        final filteredWaypoints = _selectedWaypointType == '全部'
            ? waypoints
            : waypoints
                .where((w) => w['type']
                    .toString()
                    .toLowerCase()
                    .contains(_selectedWaypointType.toLowerCase()))
                .toList();

        if (filteredWaypoints.isEmpty) {
          return Center(
            child: Text('暂无${_selectedWaypointType}类型的关键点'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredWaypoints.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final waypoint = filteredWaypoints[index];
            return _buildWaypointItem(waypoint);
          },
        );
      },
    );
  }

  /// 构建关键点项
  Widget _buildWaypointItem(Map<String, dynamic> waypoint) {
    final IconData icon = _getWaypointIcon(waypoint['type']);
    final Color color = _getWaypointColor(waypoint['type']);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waypoint['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '海拔: ${waypoint['coordinates']['altitude']}m | 距起点: ${waypoint['distanceFromStart'] ?? 0}km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('详情'),
                onPressed: () {
                  // 显示关键点详情
                  _showWaypointDetail(waypoint);
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.map, size: 20),
                onPressed: () {
                  // 在地图上显示关键点
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示关键点详情
  void _showWaypointDetail(Map<String, dynamic> waypoint) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  waypoint['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.xmark_circle),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              waypoint['description'] ?? '暂无描述',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '详细信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildWaypointDetailRow(
                '类型', _getWaypointTypeName(waypoint['type'])),
            _buildWaypointDetailRow(
                '海拔', '${waypoint['coordinates']['altitude']}m'),
            _buildWaypointDetailRow(
                '距起点', '${waypoint['distanceFromStart'] ?? 0}km'),
            if (waypoint['facilities'] != null)
              _buildWaypointDetailRow(
                  '设施', (waypoint['facilities'] as List).join(', ')),
            if (waypoint['tips'] != null)
              _buildWaypointDetailRow('提示', waypoint['tips']),
          ],
        ),
      ),
    );
  }

  /// 构建关键点详情行
  Widget _buildWaypointDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取关键点图标
  IconData _getWaypointIcon(String type) {
    switch (type.toLowerCase()) {
      case 'campsite':
        return CupertinoIcons.ant_fill;
      case 'water':
        return CupertinoIcons.drop_fill;
      case 'viewpoint':
        return CupertinoIcons.photo_fill;
      case 'danger':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'start':
        return CupertinoIcons.flag_fill;
      case 'end':
        return CupertinoIcons.flag_slash_fill;
      case 'rest':
        return CupertinoIcons.bed_double_fill;
      default:
        return CupertinoIcons.location_fill;
    }
  }

  /// 获取关键点颜色
  Color _getWaypointColor(String type) {
    switch (type.toLowerCase()) {
      case 'campsite':
        return CupertinoColors.systemGreen;
      case 'water':
        return CupertinoColors.systemBlue;
      case 'viewpoint':
        return CupertinoColors.systemIndigo;
      case 'danger':
        return CupertinoColors.systemRed;
      case 'start':
        return CupertinoColors.systemTeal;
      case 'end':
        return CupertinoColors.systemPurple;
      case 'rest':
        return CupertinoColors.systemOrange;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  /// 获取关键点类型名称
  String _getWaypointTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'campsite':
        return '营地';
      case 'water':
        return '水源';
      case 'viewpoint':
        return '景点';
      case 'danger':
        return '危险点';
      case 'start':
        return '起点';
      case 'end':
        return '终点';
      case 'rest':
        return '休息点';
      default:
        return '其他';
    }
  }
}
