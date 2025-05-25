import 'package:flutter/material.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/ui/map/core/map_controller.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'package:walk/ui/map/providers/flutter_map/flutter_map_provider.dart';
import 'package:walk/ui/map/widgets/map_container.dart';
import 'package:walk/ui/map/widgets/elevation_chart.dart';

/// 全屏地图页面
class FullMapScreen extends StatefulWidget {
  /// 地图数据
  final MapDataModel? mapData;

  /// 页面标题
  final String title;

  /// 构造函数
  const FullMapScreen({
    super.key,
    this.mapData,
    this.title = '地图',
  });

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  late final MapProvider _mapProvider;
  MapController? _mapController;
  bool _showElevationChart = true;

  @override
  void initState() {
    super.initState();
    _mapProvider = FlutterMapProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon:
                Icon(_showElevationChart ? Icons.show_chart : Icons.hide_image),
            onPressed: () {
              setState(() {
                _showElevationChart = !_showElevationChart;
              });
            },
            tooltip: _showElevationChart ? '隐藏高程图' : '显示高程图',
          ),
        ],
      ),
      body: Column(
        children: [
          // 地图
          Expanded(
            child: MapContainer(
              mapData: widget.mapData,
              mapProvider: _mapProvider,
              initialMapType: MapType.terrain,
              showUserLocation: true,
              showToolbar: true,
              showMapTypeSelector: true,
              onMapControllerCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              onMapTap: (lat, lng) {
                print('点击位置: $lat, $lng');
              },
            ),
          ),

          // 高程图表
          if (_showElevationChart && widget.mapData != null)
            ElevationChart(
              mapData: widget.mapData!,
              height: 150,
              onPointSelected: (index) {
                if (_mapController != null) {
                  final point = widget.mapData!.trackPoints[index];
                  _mapController!
                      .moveToLocation(point.latitude, point.longitude);
                  _mapController!.highlightTrackSegment(
                    index > 0 ? index - 1 : 0,
                    index < widget.mapData!.trackPoints.length - 1
                        ? index + 1
                        : index,
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
