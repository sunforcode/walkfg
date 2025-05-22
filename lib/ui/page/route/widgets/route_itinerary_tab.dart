import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';

/// 路线行程标签页
class RouteItineraryTab extends StatefulWidget {
  /// 路线数据
  final RouteModel route;
  
  /// 每日计划数据Future
  final Future<Map<String, dynamic>> dailyPlansFuture;

  /// 构造函数
  const RouteItineraryTab({
    super.key,
    required this.route,
    required this.dailyPlansFuture,
  });

  @override
  State<RouteItineraryTab> createState() => _RouteItineraryTabState();
}

class _RouteItineraryTabState extends State<RouteItineraryTab> {
  /// 当前选中的天数
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.dailyPlansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('暂无行程数据'),
          );
        }
        
        final dailyPlans = snapshot.data!['dailyPlans'] as List<dynamic>;
        
        if (dailyPlans.isEmpty) {
          return const Center(
            child: Text('暂无行程数据'),
          );
        }
        
        // 确保选中的天数有效
        if (_selectedDay > dailyPlans.length) {
          _selectedDay = 1;
        }
        
        return Column(
          children: [
            // 天数选择器
            _buildDaySelector(dailyPlans.length),
            
            // 当日行程详情
            Expanded(
              child: _buildDailyPlanDetail(dailyPlans[_selectedDay - 1]),
            ),
          ],
        );
      },
    );
  }

  /// 构建天数选择器
  Widget _buildDaySelector(int totalDays) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = day == _selectedDay;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '第$day天',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                      ),
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

  /// 构建每日行程详情
  Widget _buildDailyPlanDetail(Map<String, dynamic> dailyPlan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行程标题
          Text(
            '第${dailyPlan['day']}天: ${dailyPlan['title']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 行程基本信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey5.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow('距离', '${dailyPlan['distance']} km'),
                const SizedBox(height: 8),
                _buildInfoRow('时长', '${dailyPlan['estimatedTime']} 小时'),
                const SizedBox(height: 8),
                _buildInfoRow('难度', _buildDifficultyStars(dailyPlan['difficulty'])),
                const SizedBox(height: 8),
                _buildInfoRow('爬升', '${dailyPlan['elevationGain']} m'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 起点和终点
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey5.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPointRow(
                  '起点',
                  dailyPlan['startPoint'],
                  CupertinoIcons.flag_fill,
                  CupertinoColors.activeGreen,
                ),
                const SizedBox(height: 16),
                _buildPointRow(
                  '终点',
                  dailyPlan['endPoint'],
                  CupertinoIcons.flag_slash_fill,
                  CupertinoColors.systemRed,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 亮点和提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey5.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '亮点',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (dailyPlan['highlights'] as List).join(', '),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '提示',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dailyPlan['tips'] ?? '暂无提示',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 营地信息
          if (dailyPlan['campsite'] != null)
            _buildCampsiteInfo(dailyPlan['campsite']),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        value is Widget ? value : Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建难度星级
  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < difficulty ? CupertinoIcons.star_fill : CupertinoIcons.star,
          size: 14,
          color: index < difficulty ? CupertinoColors.systemYellow : CupertinoColors.systemGrey3,
        );
      }),
    );
  }

  /// 构建点位行
  Widget _buildPointRow(String label, String pointName, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
            Text(
              pointName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建营地信息
  Widget _buildCampsiteInfo(Map<String, dynamic> campsite) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.news,
                color: CupertinoColors.activeGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '营地信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            campsite['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildFacilityRow('设施', _buildFacilityIcons(campsite['facilities'] as List)),
          const SizedBox(height: 8),
          _buildInfoRow('容量', '约${campsite['capacity']}帐篷'),
          if (campsite['reservationRequired'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    campsite['reservationRequired'] 
                        ? CupertinoIcons.exclamationmark_circle
                        : CupertinoIcons.check_mark_circled,
                    size: 16,
                    color: campsite['reservationRequired']
                        ? CupertinoColors.systemRed
                        : CupertinoColors.activeGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    campsite['reservationRequired'] ? '需要预订' : '无需预订',
                    style: TextStyle(
                      fontSize: 14,
                      color: campsite['reservationRequired']
                          ? CupertinoColors.systemRed
                          : CupertinoColors.activeGreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建设施行
  Widget _buildFacilityRow(String label, Widget facilities) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: facilities),
      ],
    );
  }

  /// 构建设施图标
  Widget _buildFacilityIcons(List facilities) {
    final Map<String, IconData> facilityIcons = {
      '水源': CupertinoIcons.drop_fill,
      '厕所': CupertinoIcons.house_fill,
      '遮蔽': CupertinoIcons.umbrella_fill,
      '充电': CupertinoIcons.bolt_fill,
      '网络': CupertinoIcons.wifi,
      '商店': CupertinoIcons.cart_fill,
    };
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: facilities.map((facility) {
        final bool available = facility.toString().contains('✓');
        final String facilityName = facility.toString().replaceAll('✓', '').trim();
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              facilityIcons[facilityName] ?? CupertinoIcons.circle_fill,
              size: 16,
              color: available ? CupertinoColors.activeGreen : CupertinoColors.systemGrey3,
            ),
            const SizedBox(width: 4),
            Text(
              facilityName,
              style: TextStyle(
                fontSize: 14,
                color: available ? CupertinoColors.black : CupertinoColors.systemGrey3,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              available ? CupertinoIcons.check_mark : CupertinoIcons.xmark,
              size: 14,
              color: available ? CupertinoColors.activeGreen : CupertinoColors.systemGrey3,
            ),
          ],
        );
      }).toList(),
    );
  }
}