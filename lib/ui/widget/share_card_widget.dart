import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../model/trip/trip_model.dart';
import '../../theme/theme/app_colors.dart';

/// 行程分享卡片组件
class ShareCardWidget extends StatelessWidget {
  final TripModel trip;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  ShareCardWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 375,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部信息
            _buildHeader(),
            const SizedBox(height: 16),

            // 路线信息
            _buildRouteInfo(),
            const SizedBox(height: 16),

            // 统计信息
            _buildStatsRow(),
            const SizedBox(height: 16),

            // 装备重量信息
            _buildEquipmentInfo(),
            const SizedBox(height: 16),

            // 天气信息
            _buildWeatherInfo(),
            const SizedBox(height: 20),

            // 底部品牌信息
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // 计算行程天数
    final duration = trip.endDate.difference(trip.startDate).inDays + 1;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            CupertinoIcons.location_solid,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${duration}天',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    // 获取主路线信息（如果有的话）
    final routeName = trip.routeIds.isNotEmpty ? '已选择路线' : '未选择路线';
    final routeDescription = trip.description;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.map_fill,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                '路线信息',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            routeName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (routeDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              routeDescription,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: CupertinoIcons.location,
            label: '路线数',
            value: '${trip.routeIds.length}条',
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: CupertinoIcons.person_2_fill,
            label: '参与者',
            value: '${trip.participantCount}人',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: CupertinoIcons.star_fill,
            label: '状态',
            value: trip.getStatusName(),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentInfo() {
    // 获取装备清单信息
    final hasEquipmentList = trip.hasEquipmentList();
    final equipmentList = trip.getEquipmentList();
    final totalWeight = equipmentList?.totalWeight ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.bag_fill,
              color: Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '装备总重',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  hasEquipmentList
                      ? '${(totalWeight / 1000).toStringAsFixed(1)} kg'
                      : '未配置',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          if (hasEquipmentList)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    _getWeightLevelColor(totalWeight / 1000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getWeightLevel(totalWeight / 1000),
                style: TextStyle(
                  fontSize: 11,
                  color: _getWeightLevelColor(totalWeight / 1000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.cloud_sun_fill,
              color: Colors.cyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '天气预报',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _getWeatherInfo(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                CupertinoIcons.location_solid,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Walk - 徒步旅行助手',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Text(
          '分享我的徒步计划',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _getWeightLevel(double weight) {
    if (weight < 10) return '轻装';
    if (weight < 15) return '中等';
    if (weight < 20) return '重装';
    return '超重';
  }

  Color _getWeightLevelColor(double weight) {
    if (weight < 10) return Colors.green;
    if (weight < 15) return Colors.orange;
    if (weight < 20) return Colors.red;
    return Colors.red[800]!;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _getWeatherInfo() {
    // 根据出行时间和季节返回天气信息
    final month = trip.startDate.month;
    if (month >= 3 && month <= 5) {
      return '春季适宜 10-20°C';
    } else if (month >= 6 && month <= 8) {
      return '夏季炎热 20-35°C';
    } else if (month >= 9 && month <= 11) {
      return '秋季凉爽 5-20°C';
    } else {
      return '冬季寒冷 -5-10°C';
    }
  }

  /// 生成分享图片
  Future<Uint8List?> generateShareImage() async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('生成分享图片失败: $e');
      return null;
    }
  }
}
