import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/cupertino_trip_detail_screen.dart';
import '../../trip/cupertino_trip_list_screen.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/empty_content_widget.dart';

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
              return const EmptyContentWidget(
                icon: CupertinoIcons.calendar,
                title: '暂无规划行程',
                subtitle: '开始规划你的第一个行程吧',
              );
            }

            return _buildPlannedTripsList(context, plannedTrips);
          },
        ),
      ],
    );
  }

  /// 构建规划行程列表
  Widget _buildPlannedTripsList(
      BuildContext context, List<TripModel> plannedTrips) {
    // 绿色系颜色列表
    final List<Color> greenColors = [
      const Color(0xFF388E3C), // 深绿色
      const Color(0xFF4CAF50), // 绿色
      const Color(0xFF66BB6A), // 浅绿色
      const Color(0xFF81C784), // 更浅的绿色
      const Color(0xFF1B5E20), // 深邃绿色
      const Color(0xFF00C853), // 亮绿色
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plannedTrips.length,
        itemBuilder: (context, index) {
          final trip = plannedTrips[index];
          final color = greenColors[index % greenColors.length];

          // 计算行程天数
          final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;

          return Padding(
            padding: EdgeInsets.only(
              right: index == plannedTrips.length - 1 ? 0 : 12,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _navigateToTripDetail(context, trip),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
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
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 8),
                    Text(
                      trip.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey.darkColor,
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
          tripId: trip.id,
        ),
      ),
    );
  }
}
