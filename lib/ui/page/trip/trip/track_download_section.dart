import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route/route_model.dart';
import '../../../../model/route/track_point_model.dart';
import '../../../../service/service_manager.dart';
import '../../../../service/track_format_service.dart';
import '../../../../theme/theme/app_colors.dart';
import '../../../widgets/common/cupertino_section.dart';
import '../../map/route_map_widget.dart';

/// 轨迹下载区域组件
class TrackDownloadSection extends StatefulWidget {
  /// 路线模型
  final RouteModel route;

  /// 构造函数
  TrackDownloadSection({
    super.key,
    required this.route,
  });

  @override
  State<TrackDownloadSection> createState() => _TrackDownloadSectionState();
}

class _TrackDownloadSectionState extends State<TrackDownloadSection> {
  /// 轨迹格式服务
  final TrackFormatService _trackFormatService =
      ServiceLocator.instance.getTrackFormatService();

  /// 当前地图类型
  MapType _currentMapType = MapType.standard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 地图预览
        _buildMapPreview(),

        const SizedBox(height: 16),

        // 轨迹信息
        _buildTrackInfo(),

        const SizedBox(height: 16),

        // 下载选项
        _buildDownloadOptions(context),
      ],
    );
  }

  /// 构建地图预览
  Widget _buildMapPreview() {
    return CupertinoSection(
      title: '轨迹预览',
      child: Column(
        children: [
          // 地图组件
          RouteMapWidget(
            route: widget.route,
            height: MediaQuery.of(context).size.height * 0.4,
            showCurrentLocation: false,
            mapType: _currentMapType,
            showMapTypeToolbar: true,
            onMapTypeChanged: (mapType) {
              setState(() {
                _currentMapType = mapType;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 构建轨迹信息
  Widget _buildTrackInfo() {
    // 计算轨迹统计信息
    final trackPoints = widget.route.trackPoints;
    final distance =
        _trackFormatService.calculateTrackDistance(trackPoints) / 1000; // 转换为公里
    final elevationGain =
        _trackFormatService.calculateElevationGain(trackPoints);
    final elevationLoss =
        _trackFormatService.calculateElevationLoss(trackPoints);
    final waypointCount = trackPoints.where((p) => p.name != null).length;

    return CupertinoSection(
      title: '轨迹信息',
      child: Column(
        children: [
          _buildInfoRow('总距离', '${distance.toStringAsFixed(1)} 公里'),
          _buildInfoRow('累计上升', '${elevationGain.toStringAsFixed(0)} 米'),
          _buildInfoRow('累计下降', '${elevationLoss.toStringAsFixed(0)} 米'),
          _buildInfoRow('轨迹点数', '${trackPoints.length} 个'),
          _buildInfoRow('途经点数', '$waypointCount 个'),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.label,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建下载选项
  Widget _buildDownloadOptions(BuildContext context) {
    return CupertinoSection(
      title: '下载选项',
      child: Column(
        children: [
          // GPX格式
          _buildDownloadButton(
            context,
            'GPX格式',
            '通用GPS交换格式，适用于大多数GPS设备和应用',
            CupertinoIcons.arrow_down_doc,
            () => _downloadTrack(TrackFormatType.gpx),
          ),

          const SizedBox(height: 12),

          // KML格式
          _buildDownloadButton(
            context,
            'KML格式',
            '谷歌地球格式，适用于谷歌地图和地球',
            CupertinoIcons.arrow_down_doc,
            () => _downloadTrack(TrackFormatType.kml),
          ),

          const SizedBox(height: 16),

          // 导航应用打开
          _buildNavigationOptions(),
        ],
      ),
    );
  }

  /// 构建下载按钮
  Widget _buildDownloadButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建导航选项
  Widget _buildNavigationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '在导航应用中打开',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationAppButton(
              'Apple 地图',
              'assets/icons/apple_maps.png',
              () => _openInNavigationApp('apple'),
            ),
            _buildNavigationAppButton(
              '高德地图',
              'assets/icons/amap.png',
              () => _openInNavigationApp('amap'),
            ),
            _buildNavigationAppButton(
              '百度地图',
              'assets/icons/baidu_maps.png',
              () => _openInNavigationApp('baidu'),
            ),
            _buildNavigationAppButton(
              '腾讯地图',
              'assets/icons/tencent_maps.png',
              () => _openInNavigationApp('tencent'),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建导航应用按钮
  Widget _buildNavigationAppButton(
    String name,
    String iconPath,
    VoidCallback onPressed,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                iconPath,
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  /// 下载轨迹
  void _downloadTrack(TrackFormatType formatType) {
    // 在实际应用中，这里需要实现文件下载和保存逻辑
    print('下载轨迹，格式: $formatType');
  }

  /// 在导航应用中打开
  void _openInNavigationApp(String appType) {
    // 在实际应用中，这里需要实现打开外部应用的逻辑
    print('在 $appType 中打开轨迹');
  }
}
