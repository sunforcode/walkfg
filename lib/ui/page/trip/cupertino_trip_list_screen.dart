import 'package:flutter/cupertino.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/cupertino_trip_detail_screen.dart';
import 'package:walk/ui/widgets/common/empty_content_widget.dart';
import 'package:walk/ui/widgets/common/error_widget.dart';
import 'package:walk/ui/widgets/common/loading_indicator.dart';

/// 行程列表页面
class TripListScreen extends StatefulWidget {
  /// 构造函数
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  late Future<List<TripModel>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  /// 加载行程数据
  void _loadTrips() {
    // TODO: 替换为实际的API调用
    _tripsFuture = Future.delayed(
      const Duration(seconds: 1),
      () => _getMockTrips(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的行程'),
      ),
      child: SafeArea(
        child: FutureBuilder<List<TripModel>>(
          future: _tripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: _loadTrips,
              );
            }

            final trips = snapshot.data;
            if (trips == null || trips.isEmpty) {
              return const EmptyContentWidget(
                icon: CupertinoIcons.calendar,
                title: '暂无行程',
                subtitle: '开始规划你的第一个行程吧',
              );
            }

            return _buildTripList(trips);
          },
        ),
      ),
    );
  }

  /// 构建行程列表
  Widget _buildTripList(List<TripModel> trips) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(trip);
      },
    );
  }

  /// 构建行程卡片
  Widget _buildTripCard(TripModel trip) {
    // 计算行程天数
    final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;

    return GestureDetector(
      onTap: () => _navigateToTripDetail(trip),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey5.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            if (trip.coverUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  trip.coverUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: CupertinoColors.systemGrey5,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 行程名称
                  Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 行程描述
                  Text(
                    trip.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 行程信息
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.calendar,
                        '${trip.startDate.year}/${trip.startDate.month}/${trip.startDate.day}',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        CupertinoIcons.clock,
                        '$tripDays 天',
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(trip.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(TripStatus status) {
    Color color;
    String label = '';

    switch (status) {
      case TripStatus.planning:
        color = CupertinoColors.activeOrange;
        label = '计划中';
        break;
      case TripStatus.inProgress:
        color = CupertinoColors.activeBlue;
        label = '进行中';
        break;
      case TripStatus.completed:
        color = CupertinoColors.activeGreen;
        label = '已完成';
        break;
      case TripStatus.cancelled:
        color = CupertinoColors.systemGrey;
        label = '已取消';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 导航到行程详情页面
  void _navigateToTripDetail(TripModel trip) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripDetailScreen(
          tripId: trip.id,
        ),
      ),
    );
  }

  /// 获取模拟行程数据
  List<TripModel> _getMockTrips() {
    // 创建一些模拟行程数据
    return [
      TripModel(
        id: 'trip_001',
        name: '黄山三日游',
        description: '一次难忘的黄山徒步之旅，体验云海、奇松、怪石和温泉。',
        startDate: DateTime(2023, 7, 15),
        endDate: DateTime(2023, 7, 17),
        status: TripStatus.planning,
        participantCount: 3,
        organizerId: 'user_001',
        privacySetting: 'private',
        coverUrl: 'https://example.com/images/huangshan_trip_cover.jpg',
      ),
      TripModel(
        id: 'trip_002',
        name: '张家界探险',
        description: '探索张家界的神秘峰林，感受大自然的鬼斧神工。',
        startDate: DateTime(2023, 8, 5),
        endDate: DateTime(2023, 8, 8),
        status: TripStatus.planning,
        participantCount: 4,
        organizerId: 'user_001',
        privacySetting: 'private',
        coverUrl: 'https://example.com/images/zhangjiajie_trip_cover.jpg',
      ),
      TripModel(
        id: 'trip_003',
        name: '九寨沟摄影之旅',
        description: '欣赏九寨沟的五彩湖泊和原始森林，拍摄绝美风景。',
        startDate: DateTime(2023, 9, 10),
        endDate: DateTime(2023, 9, 13),
        status: TripStatus.planning,
        participantCount: 2,
        organizerId: 'user_001',
        privacySetting: 'private',
        coverUrl: 'https://example.com/images/jiuzhaigou_trip_cover.jpg',
      ),
    ];
  }
}
