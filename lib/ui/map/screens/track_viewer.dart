import 'package:flutter/material.dart';
import 'package:walk/model/model/map/map_data_model.dart';
import 'package:walk/ui/map/core/map_controller.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'package:walk/ui/map/providers/flutter_map/flutter_map_provider.dart';
import 'package:walk/ui/map/widgets/map_container.dart';
import 'package:walk/ui/map/widgets/elevation_chart.dart';
import 'package:walk/ui/map/widgets/track_info_card.dart';

/// 轨迹查看器页面
class TrackViewer extends StatefulWidget {
  /// 轨迹数据
  final MapDataModel mapData;

  /// 构造函数
  const TrackViewer({
    Key? key,
    required this.mapData,
  }) : super(key: key);

  @override
  State<TrackViewer> createState() => _TrackViewerState();
}

class _TrackViewerState extends State<TrackViewer> {
  late final MapProvider _mapProvider;
  MapController? _mapController;
  bool _showElevationChart = true;
  bool _showTrackInfo = true;

  @override
  void initState() {
    super.initState();
    _mapProvider = FlutterMapProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('轨迹详情'),
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
          IconButton(
            icon: Icon(_showTrackInfo ? Icons.info : Icons.info_outline),
            onPressed: () {
              setState(() {
                _showTrackInfo = !_showTrackInfo;
              });
            },
            tooltip: _showTrackInfo ? '隐藏轨迹信息' : '显示轨迹信息',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图
          MapContainer(
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

              // 显示轨迹
              controller.showTrack(
                useElevationGradient: true,
                showStartMarker: true,
                showEndMarker: true,
                showHighestPoint: true,
                showLowestPoint: true,
              );
            },
          ),

          // 轨迹信息卡片
          if (_showTrackInfo)
            Positioned(
              top: 16,
              left: 16,
              child: TrackInfoCard(
                mapData: widget.mapData,
                onClose: () {
                  setState(() {
                    _showTrackInfo = false;
                  });
                },
              ),
            ),

          // 高程图表
          if (_showElevationChart)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: ElevationChart(
                  mapData: widget.mapData,
                  height: 150,
                  onPointSelected: (index) {
                    if (_mapController != null) {
                      final point = widget.mapData.trackPoints[index];
                      _mapController!
                          .moveToLocation(point.latitude, point.longitude);
                      _mapController!.highlightTrackSegment(
                        index > 0 ? index - 1 : 0,
                        index < widget.mapData.trackPoints.length - 1
                            ? index + 1
                            : index,
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
