import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/trip_plan_model.dart';
import '../../../service/service_locator.dart';
import '../../theme/app_colors.dart';
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
  late Future<List<TripPlanModel>> _tripPlansFuture;
  
  @override
  void initState() {
    super.initState();
    _loadTripPlans();
  }
  
  /// 加载行程规划
  void _loadTripPlans() {
    final apiService = ServiceLocator.instance.getApiService();
    _tripPlansFuture = apiService.getUserTripPlans();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的行程规划'),
      ),
      child: SafeArea(
        child: FutureBuilder<List<TripPlanModel>>(
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
            final inProgressPlans = tripPlans.where((plan) => 
                plan.status == TripPlanStatus.draft || 
                plan.status == TripPlanStatus.confirmed ||
                plan.status == TripPlanStatus.inProgress).toList();
            
            final historyPlans = tripPlans.where((plan) => 
                plan.status == TripPlanStatus.completed || 
                plan.status == TripPlanStatus.cancelled).toList();
            
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
  Widget _buildTripPlanCard(TripPlanModel plan) {
    final bool isCompleted = plan.status == TripPlanStatus.completed || plan.status == TripPlanStatus.cancelled;
    final Color statusColor = _getStatusColor(plan.status);
    
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
                      plan.routeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? CupertinoColors.systemGrey : CupertinoColors.label,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusName(plan.status),
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
                    plan.startDate != null 
                        ? '${plan.startDate!.year}-${plan.startDate!.month}-${plan.startDate!.day}'
                        : '未设置',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    CupertinoIcons.clock,
                    '${plan.customizedItinerary.length}天',
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
                    '最后编辑: ${_getTimeAgo(plan.lastEdited)}',
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
  
  /// 获取状态名称
  String _getStatusName(TripPlanStatus status) {
    switch (status) {
      case TripPlanStatus.draft:
        return '草稿';
      case TripPlanStatus.confirmed:
        return '已确认';
      case TripPlanStatus.inProgress:
        return '进行中';
      case TripPlanStatus.completed:
        return '已完成';
      case TripPlanStatus.cancelled:
        return '已取消';
    }
  }
  
  /// 获取状态颜色
  Color _getStatusColor(TripPlanStatus status) {
    switch (status) {
      case TripPlanStatus.draft:
        return CupertinoColors.systemBlue;
      case TripPlanStatus.confirmed:
        return CupertinoColors.systemGreen;
      case TripPlanStatus.inProgress:
        return CupertinoColors.systemOrange;
      case TripPlanStatus.completed:
        return CupertinoColors.systemGrey;
      case TripPlanStatus.cancelled:
        return CupertinoColors.systemRed;
    }
  }
  
  /// 获取相对时间
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 继续规划
  void _continuePlanning(TripPlanModel plan) {
    final apiService = ServiceLocator.instance.getApiService();
    apiService.getRouteById(plan.routeId).then((route) {
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