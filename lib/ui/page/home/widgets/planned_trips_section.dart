import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/theme/tokens/tokens.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import '../../trip/trip_list_screen.dart';
import '../../common/section_header.dart';
import '../../common/loading_indicator.dart';
import '../../common/error_widget.dart';
import '../../common/empty_content_widget.dart';

/// 规划行程部分组件
class PlannedTripsSection extends StatelessWidget {
  /// 规划行程列表Future
  final Future<List<TripModel>> plannedTripsFuture;

  /// 构造函数
  const PlannedTripsSection({
    super.key,
    required this.plannedTripsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 规划行程标题
        SectionHeader(
          title: '我的规划行程',
          actionText: '查看全部',
          onAction: () => _navigateToAllTrips(context),
        ),

        const SizedBox(height: 16),

        // 规划行程列表
        FutureBuilder<List<TripModel>>(
          future: plannedTripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(height: 120);
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: () {}, // 提供一个空函数而不是null
              );
            }

            final plannedTrips = snapshot.data;
            if (plannedTrips == null || plannedTrips.isEmpty) {
              return EmptyContentWidget(
                icon: CupertinoIcons.calendar,
                title: '暂无规划行程',
                subtitle: '开始规划你的第一个行程吧',
                actionText: '规划一个行程',
                onAction: () => _navigateToTripPlanning(context),
              );
            }
            return _buildPlannedTripsList(context, plannedTrips);
          },
        ),
      ],
    );
  }

  /// 构建规划行程列表
  Widget _buildPlannedTripsList(BuildContext context, List<TripModel> plannedTrips) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plannedTrips.length,
        itemBuilder: (context, index) {
          final trip = plannedTrips[index];
          final color = AppColors.getTripColor(index);

          // 计算行程天数
          final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;

          return Padding(
            padding: EdgeInsets.only(
              right: index == plannedTrips.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _navigateToTripDetail(context, trip),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: AppSpacing.allSm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: AppSpacing.allXs,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.calendar,
                            color: color,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            trip.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      trip.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$tripDays 天',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          trip.getStatusName(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(trip.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.completed:
        return CupertinoColors.systemGreen;
      case TripStatus.inProgress:
        return CupertinoColors.systemBlue;
      case TripStatus.planning:
        return CupertinoColors.activeOrange;
      case TripStatus.cancelled:
        return CupertinoColors.systemGrey;
      case TripStatus.confirmed:
        return CupertinoColors.systemGrey;
    }
  }

  /// 导航到所有行程页面
  void _navigateToAllTrips(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const TripListScreen(),
      ),
    );
  }

  /// 导航到行程详情页面
  void _navigateToTripDetail(BuildContext context, TripModel trip) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => TripDetailScreen(
          tripModel: trip,
        ),
      ),
    );
  }

  /// 导航到行程规划页面
  void _navigateToTripPlanning(BuildContext context) async {
    try {
      final routes = await RouteService.getPopularRoutes(limit: 5);
      if (routes.isEmpty) {
        // 如果没有推荐路线，直接创建空白行程
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const TripDetailScreen(),
          ),
        );
        return;
      }
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => TripDetailScreen(
            routeId: routes.first.id,
          ),
        ),
      );
    } catch (e) {
      debugPrint('获取推荐路线失败: $e');
      // 如果获取路线失败，直接创建空白行程
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => const TripDetailScreen(),
        ),
      );
    }
  }

  /// 显示没有路线的提示
  void _showNoRoutesAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('无法加载路线'),
        content: const Text('暂时无法获取推荐路线，请稍后再试。'),
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
