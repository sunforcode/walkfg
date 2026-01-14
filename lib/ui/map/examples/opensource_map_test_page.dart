import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/widgets/map_3d_widget.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// 开源地图测试页面
class OpenSourceMapTestPage extends StatefulWidget {
  const OpenSourceMapTestPage({super.key});

  @override
  State<OpenSourceMapTestPage> createState() => _OpenSourceMapTestPageState();
}

class _OpenSourceMapTestPageState extends State<OpenSourceMapTestPage> {
  // 当前选择的路线
  int _currentRouteIndex = 0;

  // 多条测试路线
  late List<List<TrackPointVO>> _testRoutes;
  late List<String> _routeNames;
  late List<LatLng> _routeCenters;

  MapType _currentMapType = MapType.threeD;
  double _currentPitch = 45.0;
  double _currentBearing = 0.0;
  Color _trackColor = const Color(0xFF2196F3);
  double _trackWidth = 3.0;
  bool _enable3DBuildings = true;
  bool _enableTerrain = true;

  @override
  void initState() {
    super.initState();
    _initializeTestData();
  }

  /// 初始化测试数据
  void _initializeTestData() {
    _testRoutes = [
      _generateBeijingHikingRoute(),
      _generateCityRoute(),
      _generateCoastalRoute(),
      _generateMountainRoute(),
    ];

    _routeNames = [
      '北京香山徒步',
      '城市环线',
      '青岛海岸线',
      '山区穿越',
    ];

    _routeCenters = [
      const LatLng(39.9988, 116.1955), // 香山
      const LatLng(39.9375, 116.4375), // 北京市区
      const LatLng(36.0640, 120.3340), // 青岛
      const LatLng(40.2500, 116.8000), // 山区
    ];
  }

  /// 生成北京香山徒步路线
  List<TrackPointVO> _generateBeijingHikingRoute() {
    return [
      // 香山公园入口
      TrackPointVO(latitude: 39.9926, longitude: 116.1889, elevation: 100.0),
      TrackPointVO(latitude: 39.9930, longitude: 116.1895, elevation: 120.0),
      TrackPointVO(latitude: 39.9935, longitude: 116.1902, elevation: 140.0),
      TrackPointVO(latitude: 39.9940, longitude: 116.1908, elevation: 160.0),
      TrackPointVO(latitude: 39.9945, longitude: 116.1915, elevation: 180.0),

      // 沿山路上行
      TrackPointVO(latitude: 39.9950, longitude: 116.1920, elevation: 200.0),
      TrackPointVO(latitude: 39.9955, longitude: 116.1925, elevation: 230.0),
      TrackPointVO(latitude: 39.9960, longitude: 116.1930, elevation: 260.0),
      TrackPointVO(latitude: 39.9965, longitude: 116.1935, elevation: 290.0),
      TrackPointVO(latitude: 39.9970, longitude: 116.1940, elevation: 320.0),

      // 到达观景台
      TrackPointVO(latitude: 39.9975, longitude: 116.1945, elevation: 350.0),
      TrackPointVO(latitude: 39.9980, longitude: 116.1950, elevation: 380.0),
      TrackPointVO(latitude: 39.9985, longitude: 116.1955, elevation: 410.0),
      TrackPointVO(latitude: 39.9990, longitude: 116.1960, elevation: 440.0),
      TrackPointVO(latitude: 39.9995, longitude: 116.1965, elevation: 470.0),

      // 继续向山顶
      TrackPointVO(latitude: 40.0000, longitude: 116.1970, elevation: 500.0),
      TrackPointVO(latitude: 40.0005, longitude: 116.1975, elevation: 530.0),
      TrackPointVO(latitude: 40.0010, longitude: 116.1980, elevation: 560.0),
      TrackPointVO(latitude: 40.0015, longitude: 116.1985, elevation: 590.0),
      TrackPointVO(latitude: 40.0020, longitude: 116.1990, elevation: 620.0),

      // 山顶区域
      TrackPointVO(latitude: 40.0025, longitude: 116.1995, elevation: 650.0),
      TrackPointVO(latitude: 40.0030, longitude: 116.2000, elevation: 680.0),
      TrackPointVO(latitude: 40.0035, longitude: 116.2005, elevation: 710.0),
      TrackPointVO(latitude: 40.0040, longitude: 116.2010, elevation: 740.0),
      TrackPointVO(latitude: 40.0045, longitude: 116.2015, elevation: 770.0),

      // 香山最高点
      TrackPointVO(latitude: 40.0050, longitude: 116.2020, elevation: 800.0),
    ];
  }

  /// 生成城市路线数据
  List<TrackPointVO> _generateCityRoute() {
    return [
      // 天安门广场起点
      TrackPointVO(latitude: 39.9042, longitude: 116.4074, elevation: 50.0),
      TrackPointVO(latitude: 39.9100, longitude: 116.4100, elevation: 52.0),
      TrackPointVO(latitude: 39.9150, longitude: 116.4150, elevation: 54.0),
      TrackPointVO(latitude: 39.9200, longitude: 116.4200, elevation: 56.0),
      TrackPointVO(latitude: 39.9250, longitude: 116.4250, elevation: 58.0),

      // 沿二环路
      TrackPointVO(latitude: 39.9300, longitude: 116.4300, elevation: 60.0),
      TrackPointVO(latitude: 39.9350, longitude: 116.4350, elevation: 62.0),
      TrackPointVO(latitude: 39.9400, longitude: 116.4400, elevation: 64.0),
      TrackPointVO(latitude: 39.9450, longitude: 116.4450, elevation: 66.0),
      TrackPointVO(latitude: 39.9500, longitude: 116.4500, elevation: 68.0),

      // 继续环行
      TrackPointVO(latitude: 39.9550, longitude: 116.4550, elevation: 70.0),
      TrackPointVO(latitude: 39.9600, longitude: 116.4600, elevation: 72.0),
      TrackPointVO(latitude: 39.9650, longitude: 116.4650, elevation: 74.0),
      TrackPointVO(latitude: 39.9700, longitude: 116.4700, elevation: 76.0),
      TrackPointVO(latitude: 39.9750, longitude: 116.4750, elevation: 78.0),
    ];
  }

  /// 生成海边路线数据
  List<TrackPointVO> _generateCoastalRoute() {
    return [
      // 青岛栈桥
      TrackPointVO(latitude: 36.0570, longitude: 120.3200, elevation: 5.0),
      TrackPointVO(latitude: 36.0580, longitude: 120.3220, elevation: 8.0),
      TrackPointVO(latitude: 36.0590, longitude: 120.3240, elevation: 12.0),
      TrackPointVO(latitude: 36.0600, longitude: 120.3260, elevation: 15.0),
      TrackPointVO(latitude: 36.0610, longitude: 120.3280, elevation: 18.0),

      // 沿海岸线
      TrackPointVO(latitude: 36.0620, longitude: 120.3300, elevation: 20.0),
      TrackPointVO(latitude: 36.0630, longitude: 120.3320, elevation: 25.0),
      TrackPointVO(latitude: 36.0640, longitude: 120.3340, elevation: 30.0),
      TrackPointVO(latitude: 36.0650, longitude: 120.3360, elevation: 35.0),
      TrackPointVO(latitude: 36.0660, longitude: 120.3380, elevation: 40.0),

      // 到达海水浴场
      TrackPointVO(latitude: 36.0670, longitude: 120.3400, elevation: 45.0),
      TrackPointVO(latitude: 36.0680, longitude: 120.3420, elevation: 50.0),
      TrackPointVO(latitude: 36.0690, longitude: 120.3440, elevation: 55.0),
      TrackPointVO(latitude: 36.0700, longitude: 120.3460, elevation: 60.0),
      TrackPointVO(latitude: 36.0710, longitude: 120.3480, elevation: 65.0),
    ];
  }

  /// 生成山区路线数据
  List<TrackPointVO> _generateMountainRoute() {
    return [
      // 山区起点
      TrackPointVO(latitude: 40.2000, longitude: 116.7500, elevation: 800.0),
      TrackPointVO(latitude: 40.2050, longitude: 116.7550, elevation: 850.0),
      TrackPointVO(latitude: 40.2100, longitude: 116.7600, elevation: 900.0),
      TrackPointVO(latitude: 40.2150, longitude: 116.7650, elevation: 950.0),
      TrackPointVO(latitude: 40.2200, longitude: 116.7700, elevation: 1000.0),

      // 山脊线
      TrackPointVO(latitude: 40.2250, longitude: 116.7750, elevation: 1100.0),
      TrackPointVO(latitude: 40.2300, longitude: 116.7800, elevation: 1200.0),
      TrackPointVO(latitude: 40.2350, longitude: 116.7850, elevation: 1300.0),
      TrackPointVO(latitude: 40.2400, longitude: 116.7900, elevation: 1400.0),
      TrackPointVO(latitude: 40.2450, longitude: 116.7950, elevation: 1500.0),

      // 高峰区域
      TrackPointVO(latitude: 40.2500, longitude: 116.8000, elevation: 1600.0),
      TrackPointVO(latitude: 40.2550, longitude: 116.8050, elevation: 1700.0),
      TrackPointVO(latitude: 40.2600, longitude: 116.8100, elevation: 1800.0),
      TrackPointVO(latitude: 40.2650, longitude: 116.8150, elevation: 1900.0),
      TrackPointVO(latitude: 40.2700, longitude: 116.8200, elevation: 2000.0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('开源3D地图测试'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 路线选择
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '选择测试路线',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoSegmentedControl<int>(
                    children: {
                      for (int i = 0; i < _routeNames.length; i++)
                        i: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _routeNames[i],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    },
                    groupValue: _currentRouteIndex,
                    onValueChanged: (value) {
                      setState(() {
                        _currentRouteIndex = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // 地图类型选择
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSegmentedControl<MapType>(
                children: const {
                  MapType.threeD: Text('标准'),
                  MapType.threeDTerrain: Text('地形'),
                  MapType.threeDSatellite: Text('卫星'),
                },
                groupValue: _currentMapType,
                onValueChanged: (value) {
                  setState(() {
                    _currentMapType = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // 3D地图
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Map3DWidget(
                    key: ValueKey('${_currentRouteIndex}_${_currentMapType}'),
                    trackPoints: _testRoutes[_currentRouteIndex],
                    config: Map3DConfig(
                      height: double.infinity,
                      mapType: _currentMapType,
                      initialPitch: _currentPitch,
                      initialBearing: _currentBearing,
                      showTrack: true,
                      trackColor: _trackColor,
                      trackWidth: _trackWidth,
                      enable3DBuildings: _enable3DBuildings,
                      enableTerrain: _enableTerrain,
                    ),
                    initialCenter: _routeCenters[_currentRouteIndex],
                    events: Map3DEvents(
                      onMapTap: (position) {
                        print(
                            '地图点击: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
                        _showToast(
                            '地图点击: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
                      },
                      onMapReady: () {
                        print(
                            '开源3D地图准备就绪 - ${_routeNames[_currentRouteIndex]}');
                        _showToast('${_routeNames[_currentRouteIndex]} 地图加载完成');
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 控制面板
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemGroupedBackground,
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: _buildControlPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    final currentRoute = _testRoutes[_currentRouteIndex];
    final routeName = _routeNames[_currentRouteIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前路线信息
          _buildSection(
            title: '当前路线信息',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('路线名称', routeName),
                _buildInfoRow('轨迹点数', '${currentRoute.length}个'),
                _buildInfoRow(
                    '起点海拔', '${currentRoute.first.elevation.toInt()}m'),
                _buildInfoRow(
                    '终点海拔', '${currentRoute.last.elevation.toInt()}m'),
                _buildInfoRow('海拔差',
                    '${(currentRoute.last.elevation - currentRoute.first.elevation).toInt()}m'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 开源数据源
          _buildSection(
            title: '开源数据源',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('标准地图', 'OpenStreetMap'),
                _buildInfoRow('卫星图像', 'Esri World Imagery'),
                _buildInfoRow('地形数据', 'Wikimedia Labs'),
                _buildInfoRow('3D引擎', 'MapLibre GL'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 视角控制
          _buildSection(
            title: '视角控制',
            child: Column(
              children: [
                _buildSlider(
                  label: '倾斜角度: ${_currentPitch.toInt()}°',
                  value: _currentPitch,
                  min: 0.0,
                  max: 60.0,
                  onChanged: (value) {
                    setState(() {
                      _currentPitch = value;
                    });
                  },
                ),
                _buildSlider(
                  label: '旋转角度: ${_currentBearing.toInt()}°',
                  value: _currentBearing,
                  min: 0.0,
                  max: 360.0,
                  onChanged: (value) {
                    setState(() {
                      _currentBearing = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 测试按钮
          _buildSection(
            title: '测试功能',
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: _switchToNextRoute,
                    child: const Text('下一条路线'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: _generateRandomRoute,
                    child: const Text('随机路线'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建区域
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建滑块
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        CupertinoSlider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 切换到下一条路线
  void _switchToNextRoute() {
    setState(() {
      _currentRouteIndex = (_currentRouteIndex + 1) % _testRoutes.length;
    });
    _showToast('已切换到: ${_routeNames[_currentRouteIndex]}');
  }

  /// 生成随机路线
  void _generateRandomRoute() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final baseLatitude = 39.9 + (random % 100) / 1000.0;
    final baseLongitude = 116.4 + (random % 100) / 1000.0;

    final randomRoute = List.generate(20, (index) {
      return TrackPointVO(
        latitude: baseLatitude + index * 0.001,
        longitude: baseLongitude + index * 0.001,
        elevation: 100.0 + index * 10.0,
      );
    });

    setState(() {
      _testRoutes.add(randomRoute);
      _routeNames.add('随机路线${_testRoutes.length - 4}');
      _routeCenters.add(LatLng(baseLatitude + 0.01, baseLongitude + 0.01));
      _currentRouteIndex = _testRoutes.length - 1;
    });

    _showToast('已生成随机路线');
  }

  /// 显示提示
  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
