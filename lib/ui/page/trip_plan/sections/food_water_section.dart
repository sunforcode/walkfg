import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/service/trip_plan_service.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';

/// 食物和水部分
class FoodWaterSection extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 参与人数
  final int participantCount;

  /// 行程规划服务
  final TripPlanService tripPlanService;

  /// 构造函数
  const FoodWaterSection({
    Key? key,
    required this.route,
    required this.participantCount,
    required this.tripPlanService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 膳食计划卡片
          _buildMealPlanCard(context),

          const SizedBox(height: 16),

          // 饮水计划卡片
          _buildWaterPlanCard(context),
        ],
      ),
    );
  }

  /// 构建膳食计划卡片
  Widget _buildMealPlanCard(BuildContext context) {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitleWidget(title: '膳食计划'),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('编辑'),
                onPressed: () {
                  _showEditMealPlanDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 每日膳食计划
          _buildDailyMealPlan('第1天', [
            _buildMeal('早餐', '能量棒、坚果、干果'),
            _buildMeal('午餐', '三明治、巧克力'),
            _buildMeal('晚餐', '冻干食品、饼干'),
          ]),

          const Divider(),

          _buildDailyMealPlan('第2天', [
            _buildMeal('早餐', '麦片、牛奶粉、饼干'),
            _buildMeal('午餐', '能量棒、巧克力、坚果'),
            _buildMeal('晚餐', '冻干食品、汤'),
          ]),

          const Divider(),

          _buildDailyMealPlan('第3天', [
            _buildMeal('早餐', '麦片、牛奶粉、能量棒'),
            _buildMeal('午餐', '三明治、坚果、巧克力'),
            _buildMeal('晚餐', '当地餐厅'),
          ]),

          const SizedBox(height: 16),

          // 膳食提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.info_circle,
                  color: CupertinoColors.systemBlue,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '根据行程强度，每人每天需要约2500-3000卡路里的热量摄入',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建每日膳食计划
  Widget _buildDailyMealPlan(String day, List<Widget> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...meals,
      ],
    );
  }

  /// 构建膳食项
  Widget _buildMeal(String mealType, String food) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$mealType: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(food),
          ),
        ],
      ),
    );
  }

  /// 构建饮水计划卡片
  Widget _buildWaterPlanCard(BuildContext context) {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitleWidget(title: '饮水计划'),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('编辑'),
                onPressed: () {
                  _showEditWaterPlanDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 每日饮水需求
          _buildInfoRow(
            '每日饮水需求',
            '每人约2-3升',
            CupertinoIcons.drop,
          ),

          const SizedBox(height: 12),

          // 水源信息
          _buildInfoRow(
            '水源信息',
            '路线上有3处水源点',
            CupertinoIcons.map,
          ),

          const SizedBox(height: 16),

          // 水源列表
          const Text(
            '水源点位置:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildWaterSourceItem('水源1', '显通寺附近的山泉', '需要过滤'),
          _buildWaterSourceItem('水源2', '塔院寺的饮用水', '可直接饮用'),
          _buildWaterSourceItem('水源3', '南山寺的饮用水', '可直接饮用'),

          const SizedBox(height: 16),

          // 饮水提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: CupertinoColors.systemYellow,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '自然水源需要过滤或煮沸后饮用，建议携带便携式水过滤器',
                    style: TextStyle(
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建水源项
  Widget _buildWaterSourceItem(String name, String location, String note) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.drop_fill,
            size: 16,
            color: CupertinoColors.activeBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示编辑膳食计划对话框
  void _showEditMealPlanDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '编辑膳食计划',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('完成'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 编辑界面
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: 实现膳食计划编辑界面
                      const Text('膳食计划编辑功能开发中...'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 显示编辑饮水计划对话框
  void _showEditWaterPlanDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '编辑饮水计划',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('完成'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 编辑界面
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: 实现饮水计划编辑界面
                      const Text('饮水计划编辑功能开发中...'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}