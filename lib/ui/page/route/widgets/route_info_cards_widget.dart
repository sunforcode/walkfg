import 'package:flutter/cupertino.dart';
import '../../../../model/route/route_model.dart';

/// 路线信息卡片组件
class RouteInfoCardsWidget extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  const RouteInfoCardsWidget({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 基础参数卡片
          _buildInfoCard(
            title: '路线参数',
            icon: CupertinoIcons.info_circle,
            children: [
              _buildInfoRow('总距离', '${route.distance.toStringAsFixed(1)}km'),
              _buildInfoRow('累计爬升', '${route.elevationGain.toInt()}m'),
              _buildInfoRow(
                  '累计下降', '${route.elevationLoss.toStringAsFixed(0)}m'),
              _buildInfoRow('建议天数', '${route.dailyPlans.length}天'),
              _buildInfoRow('难度等级', route.difficulty.getName()),
            ],
          ),

          const SizedBox(height: 16),

          // 实用信息卡片
          _buildInfoCard(
            title: '实用信息',
            icon: CupertinoIcons.location_circle,
            children: [
              _buildInfoRow('最佳季节', route.bestSeason.join(',')),
              _buildInfoRow('起点', route.startPoint),
              _buildInfoRow('终点', route.endPoint),
            ],
          ),

          const SizedBox(height: 16),

          // 设施信息卡片
          _buildInfoCard(
            title: '设施信息',
            icon: CupertinoIcons.house_alt,
            children: [
              _buildInfoRow('补给点', '${_getSupplyPointCount()}个'),
              _buildInfoRow('住宿点', '${_getAccommodationCount()}个'),
              _buildInfoRow('水源点', '${_getWaterSourceCount()}个'),
              _buildInfoRow('观景点', '${_getViewPointCount()}个'),
            ],
          ),

          // 安全信息卡片（如果有安全提醒）
          if (route.safetyWarnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSafetyCard(),
          ],
        ],
      ),
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 信息行
          ...children,
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建安全信息卡片
  Widget _buildSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 安全警告标题
          Row(
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 20,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(width: 8),
              const Text(
                '安全提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 安全警告列表
          ...route.safetyWarnings.map((warning) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      warning,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 获取补给点数量
  int _getSupplyPointCount() {
    // 这里应该从路线数据中获取实际的补给点数量
    // 临时返回模拟数据
    return route.dailyPlans.length + 1; // 假设每天有一个补给点，起点额外一个
  }

  /// 获取住宿点数量
  int _getAccommodationCount() {
    // 这里应该从路线数据中获取实际的住宿点数量
    // 临时返回模拟数据
    return route.dailyPlans.length - 1; // 假设除了最后一天，每天都有住宿点
  }

  /// 获取水源点数量
  int _getWaterSourceCount() {
    // 这里应该从路线数据中获取实际的水源点数量
    // 临时返回模拟数据
    return (route.distance / 5).ceil(); // 假设每5km有一个水源点
  }

  /// 获取观景点数量
  int _getViewPointCount() {
    // 这里应该从路线数据中获取实际的观景点数量
    // 临时返回模拟数据
    return (route.distance / 8).ceil(); // 假设每8km有一个观景点
  }
}

/// 路线概览组件
class RouteOverviewWidget extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  const RouteOverviewWidget({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线标题和评分
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.region,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),

              // 评分和标签
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        size: 16,
                        color: CupertinoColors.systemYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (route.tags.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        route.tags.first,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.activeBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 快速信息栏
          Row(
            children: [
              _buildQuickInfo(
                icon: CupertinoIcons.location,
                value: '${route.distance.toStringAsFixed(1)}km',
                label: '总距离',
              ),
              const SizedBox(width: 16),
              _buildQuickInfo(
                icon: CupertinoIcons.arrow_up,
                value: '${route.elevationGain.toInt()}m',
                label: '爬升',
              ),
              const SizedBox(width: 16),
              _buildQuickInfo(
                icon: CupertinoIcons.calendar,
                value: '${route.dailyPlans.length}天',
                label: '建议',
              ),
              const SizedBox(width: 16),
              _buildQuickInfo(
                icon: CupertinoIcons.gauge,
                value: route.difficulty.getName(),
                label: '难度',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快速信息项
  Widget _buildQuickInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.activeBlue,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
