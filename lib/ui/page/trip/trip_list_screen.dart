import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/tokens.dart';
import 'package:walk/ui/page/common/empty_content_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';

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
      backgroundColor: AppColors.bgBase,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.bgBase,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        middle: Text('我的行程', style: AppTypography.navTitle),
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
      padding: AppSpacing.page,
      itemCount: trips.length,
      separatorBuilder: (context, index) => AppSpacing.gapVerticalMd,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.borderControl,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            if (trip.coverUrl != null)
              NetworkImageWithFallback(
                url: trip.coverUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                fallbackColor: AppColors.bgPanel,
                fallbackIcon: CupertinoIcons.photo,
              ),

            Padding(
              padding: AppSpacing.component,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 行程名称
                  Text(
                    trip.name,
                    style: AppTypography.cardTitle,
                  ),

                  AppSpacing.gapVerticalSm,

                  // 行程描述
                  Text(
                    trip.description,
                    style: AppTypography.bodySm,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  AppSpacing.gapVerticalMd,

                  // 行程信息
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.calendar,
                        '${trip.startDate.year}/${trip.startDate.month}/${trip.startDate.day}',
                      ),
                      AppSpacing.gapSm,
                      _buildInfoChip(
                        CupertinoIcons.clock,
                        '$tripDays 天',
                      ),
                      AppSpacing.gapSm,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textWeak,
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(TripStatus status) {
    final (backgroundColor, foregroundColor, label) = switch (status) {
      TripStatus.planning => (
          AppColors.statusPlanningBg,
          AppColors.statusPlanningText,
          '计划中',
        ),
      TripStatus.inProgress => (
          AppColors.semanticSuccessBg,
          AppColors.statusProgress,
          '进行中',
        ),
      TripStatus.completed => (
          AppColors.statusCompletedBg,
          AppColors.statusCompletedText,
          '已完成',
        ),
      TripStatus.cancelled => (
          AppColors.statusCancelledBg,
          AppColors.statusCancelledText,
          '已取消',
        ),
      TripStatus.confirmed => (
          AppColors.statusConfirmedBg,
          AppColors.statusConfirmedText,
          '已确认',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: foregroundColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.withColor(
          AppTypography.label,
          foregroundColor,
        ),
      ),
    );
  }

  /// 导航到行程详情页面
  void _navigateToTripDetail(TripModel trip) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripDetailScreen(
          tripModel: trip,
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
