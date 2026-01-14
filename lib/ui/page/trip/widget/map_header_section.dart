import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/widgets/simple_map_widget.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 地图头部部分
class MapHeaderSection extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 地图类型
  final MapType mapType;

  /// 地图提供商
  final MapProviderType mapProvider;

  /// 地图类型变更回调
  final ValueChanged<MapType>? onMapTypeChanged;

  /// 地图提供商变更回调
  final ValueChanged<MapProviderType>? onMapProviderChanged;

  /// 构造函数
  const MapHeaderSection({
    Key? key,
    required this.route,
    required this.trackPoints,
    required this.mapType,
    required this.mapProvider,
    this.onMapTypeChanged,
    this.onMapProviderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Stack(
        children: [
          SimpleMapWidget(
            trackPoints: trackPoints,
            config: SimpleMapConfig(
              height: MediaQuery.of(context).size.height * 0.25,
              mapType: mapType,
              mapProvider: mapProvider,
              showTrack: true,
              showStartEnd: true,
              showPointsOfInterest: true,
              showCurrentLocation: false,
            ),
            events: SimpleMapEvents(
              onMapTap: (position) {
                // 可以添加地图点击处理逻辑
                print('地图点击: $position');
              },
            ),
          ),

          // 路线信息悬浮卡片
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.map,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${route.distance}km | ${route.elevationGain}m爬升 | ${route.difficulty.getName()}',
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
