import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 轨迹下载卡片
class TrackDownloadCard extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 轨迹点列表
  final List<TrackPointVO> trackPoints;

  /// 构造函数
  const TrackDownloadCard({
    Key? key,
    required this.route,
    required this.trackPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TripPlanCard(
      title: '轨迹下载',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 完整轨迹下载
          Text(
            '下载完整轨迹',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 下载按钮组
          Row(
            children: [
              _buildDownloadButton(
                'GPX格式',
                CupertinoIcons.cloud_download,
                () => _downloadTrack('gpx'),
              ),
              const SizedBox(width: 12),
              _buildDownloadButton(
                'KML格式',
                CupertinoIcons.cloud_download,
                () => _downloadTrack('kml'),
              ),
              const SizedBox(width: 12),
              _buildDownloadButton(
                'TCX格式',
                CupertinoIcons.cloud_download,
                () => _downloadTrack('tcx'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 每日轨迹下载
          Text(
            '下载每日轨迹',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 每日轨迹列表
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日期和路线
                Text(
                  '第1天: ${route.waypoints.isNotEmpty ? '${route.waypoints.first.name} → ${route.waypoints.last.name}' : '暂无轨迹'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // 下载按钮
                Row(
                  children: [
                    _buildDownloadButton(
                      'GPX格式',
                      CupertinoIcons.cloud_download,
                      () => _downloadDailyTrack(0, 'gpx'),
                      small: true,
                    ),
                    const SizedBox(width: 12),
                    _buildDownloadButton(
                      'KML格式',
                      CupertinoIcons.cloud_download,
                      () => _downloadDailyTrack(0, 'kml'),
                      small: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建下载按钮
  Widget _buildDownloadButton(
      String label, IconData icon, VoidCallback onPressed,
      {bool small = false}) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: small ? 8 : 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: CupertinoColors.white,
                size: small ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: small ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 下载完整轨迹
  void _downloadTrack(String format) {
    // TODO: 实现轨迹下载
    print('下载完整轨迹，格式: $format，轨迹点数量: ${trackPoints.length}');
  }

  /// 下载每日轨迹
  void _downloadDailyTrack(int dayIndex, String format) {
    // TODO: 实现每日轨迹下载
    print('下载第${dayIndex + 1}天轨迹，格式: $format');
  }
}
