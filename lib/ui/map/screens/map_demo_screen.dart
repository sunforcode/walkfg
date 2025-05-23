import 'package:flutter/cupertino.dart';
import 'package:walk/model/model/map/map_data_model.dart';
import 'package:walk/ui/map/core/map_controller.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'package:walk/ui/map/providers/flutter_map/flutter_map_provider.dart';
import 'package:walk/ui/map/utils/kml_parser.dart';
import 'package:walk/ui/map/widgets/map_container.dart';
import 'package:walk/ui/map/widgets/elevation_chart.dart';

/// 地图演示页面
class MapDemoScreen extends StatefulWidget {
  const MapDemoScreen({super.key});

  @override
  State<MapDemoScreen> createState() => _MapDemoScreenState();
}

class _MapDemoScreenState extends State<MapDemoScreen> {
  late final MapProvider _mapProvider;
  MapController? _mapController;
  MapDataModel? _mapData;
  bool _isLoading = true;
  bool _showElevationChart = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _mapProvider = FlutterMapProvider();
    _loadKmlData();
  }

  /// 加载 KML 数据
  Future<void> _loadKmlData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 解析 KML 文件
      final mapData = await KmlParser.parseFromAsset('assets/maps/wutai.kml');

      setState(() {
        _mapData = mapData;
        _isLoading = false;
      });

      // 延迟一下再显示轨迹，确保地图已经初始化
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_mapController != null && mounted) {
          _mapController!.showEntireTrack();
          _mapController!.showTrack(useElevationGradient: true);
        }
      });
    } catch (e) {
      print('加载 KML 数据失败: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '无法加载地图数据: $e';
      });

      // 显示错误提示
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('加载失败'),
            content: Text(_errorMessage),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('五台山徒步路线'),
        // 添加地图类型切换按钮
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showElevationChart = !_showElevationChart;
                });
              },
              child: Icon(
                _showElevationChart
                    ? CupertinoIcons.chart_bar_fill
                    : CupertinoIcons.chart_bar,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(width: 16),
            const MapTypeSelector(),
          ],
        ),
      ),
      child: SafeArea(
        // 使用 Stack 替代 Column 来避免溢出问题
        child: Stack(
          children: [
            // 地图容器 - 占满整个空间
            Positioned.fill(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text('错误: $_errorMessage'))
                      : MapContainer(
                          mapData: _mapData,
                          mapProvider: _mapProvider,
                          initialMapType: MapType.terrain,
                          showUserLocation: false,
                          showToolbar: true,
                          showMapTypeSelector: true,
                          onMapControllerCreated: (controller) {
                            setState(() {
                              _mapController = controller;
                            });

                            // 确保地图数据已加载
                            if (_mapData != null) {
                              controller.showEntireTrack();
                              controller.showTrack(useElevationGradient: true);
                            }
                          },
                          onMapTap: (lat, lng) {
                            _showLocationInfo(lat, lng);
                          },
                        ),
            ),

            // 高程图表 - 固定在底部
            if (_showElevationChart && _mapData != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 200,
                  child: ElevationChart(
                    mapData: _mapData!,
                    height: 200,
                    onPointSelected: (index) {
                      if (_mapController != null && _mapData != null) {
                        final point = _mapData!.trackPoints[index];
                        _mapController!
                            .moveToLocation(point.latitude, point.longitude);
                        _mapController!.highlightTrackSegment(
                          index > 0 ? index - 1 : 0,
                          index < _mapData!.trackPoints.length - 1
                              ? index + 1
                              : index,
                        );
                      }
                    },
                  ),
                ),
              ),

            // 重新加载按钮 - 当出错时显示
            if (_errorMessage.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    child: const Text('重新加载'),
                    onPressed: _loadKmlData,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 显示位置信息
  void _showLocationInfo(double lat, double lng) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('位置信息'),
        message: Text('纬度: $lat\n经度: $lng'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 地图类型选择器
class MapTypeSelector extends StatelessWidget {
  const MapTypeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMapTypeSelector(context),
      child: const Icon(
        CupertinoIcons.layers,
        color: CupertinoColors.activeBlue,
      ),
    );
  }

  void _showMapTypeSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择地图类型'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              final controller = _getMapController(context);
              if (controller != null) {
                controller.setMapType(MapType.standard);
              }
              Navigator.pop(context);
            },
            child: const Text('标准地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              final controller = _getMapController(context);
              if (controller != null) {
                controller.setMapType(MapType.satellite);
              }
              Navigator.pop(context);
            },
            child: const Text('卫星地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              final controller = _getMapController(context);
              if (controller != null) {
                controller.setMapType(MapType.terrain);
              }
              Navigator.pop(context);
            },
            child: const Text('地形图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              final controller = _getMapController(context);
              if (controller != null) {
                controller.setMapType(MapType.hybrid);
              }
              Navigator.pop(context);
            },
            child: const Text('混合地图'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  MapController? _getMapController(BuildContext context) {
    final state = context.findAncestorStateOfType<_MapDemoScreenState>();
    return state?._mapController;
  }
}
