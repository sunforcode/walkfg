import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/enums/route_status.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import '../../../service/service_manager.dart';
import '../../../theme/theme/app_colors.dart';
import '../../../common/utils/date_time_utils.dart';
import 'trip_planning_detail_screen.dart';

/// 我的行程规划页面
class MyTripPlansScreen extends StatefulWidget {
  /// 构造函数
  const MyTripPlansScreen({super.key});

  @override
  State<MyTripPlansScreen> createState() => _MyTripPlansScreenState();
}

class _MyTripPlansScreenState extends State<MyTripPlansScreen> {
  /// 行程规划列表Future
  late Future<List<TripModel>> _tripPlansFuture;

  @override
  void initState() {
    super.initState();
    _loadTripPlans();
  }

  /// 加载行程规划
  void _loadTripPlans() {
    // final apiService = ServiceLocator.instance.getTripPlanService();
    // _tripPlansFuture = apiService.getUserTripPlans();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的行程规划'),
      ),
      child: SafeArea(
        child: FutureBuilder<List<TripModel>>(
          future: _tripPlansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      child: const Text('重试'),
                      onPressed: () {
                        setState(() {
                          _loadTripPlans();
                        });
                      },
                    ),
                  ],
                ),
              );
            }

            final tripPlans = snapshot.data!;
            if (tripPlans.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.map,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '暂无行程规划',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '开始规划你的徒步旅行吧！',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      child: const Text('开始规划行程'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            }

            // 将行程规划按状态分组
            final inProgressPlans = tripPlans
                // .where((plan) => plan?.status == RouteStatus.planning)
                .toList();

            final historyPlans = tripPlans
                // .where((plan) => plan?.status == RouteStatus.completed)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (inProgressPlans.isNotEmpty) ...[
                  const Text(
                    '进行中的规划',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...inProgressPlans.map((plan) => _buildTripPlanCard(plan)),
                  const SizedBox(height: 24),
                ],
                if (historyPlans.isNotEmpty) ...[
                  const Text(
                    '历史规划',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...historyPlans.map((plan) => _buildTripPlanCard(plan)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建行程规划卡片
  Widget _buildTripPlanCard(TripModel plan) {
    final bool isCompleted = plan.status == RouteStatus.completed;
    final Color statusColor = Colors.red; //plan.getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _continuePlanning(plan);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 路线名称和状态
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.routeIds.first,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.label,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      plan.status.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 行程信息
              Row(
                children: [
                  _buildInfoChip(
                    CupertinoIcons.calendar,
                    DateTimeUtils.formatDate(plan.startDate),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    CupertinoIcons.clock,
                    '${1}天',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    CupertinoIcons.person_2,
                    '${plan.participantCount}人',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 最后编辑时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最后编辑: ${DateTimeUtils.getTimeAgo(plan.updatedAt ?? DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  if (!isCompleted)
                    const Text(
                      '继续规划 →',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 继续规划
  void _continuePlanning(TripModel plan) {
    final apiService = ServiceLocator.instance.getRouteService();
    apiService.getRouteById(plan.routeIds.first).then((route) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => TripPlanningDetailScreen(
            route: route,
            tripPlan: plan,
          ),
        ),
      );
    });
  }
}
