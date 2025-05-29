import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/trip/widgets/ai_trip_planner_widget.dart';

/// AI生成方案详细展示组件
class AIGeneratedPlanWidget extends StatelessWidget {
  final AITripPlan plan;
  final Function() onEdit;

  const AIGeneratedPlanWidget({
    super.key,
    required this.plan,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: CupertinoColors.systemGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI生成的行程方案',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 方案概览
          _buildPlanOverview(),

          // 大交通方案
          _buildTransportationSection(),

          // 每日行程安排
          _buildDailyItinerarySection(),

          // 装备清单
          _buildEquipmentSection(),

          // 食物水源
          _buildFoodWaterSection(),

          // 费用明细
          _buildBudgetSection(),
        ],
      ),
    );
  }

  Widget _buildPlanOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 方案概览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  '总预算',
                  '¥${plan.totalBudget}/人',
                  CupertinoColors.systemBlue,
                  CupertinoIcons.money_dollar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  '装备重量',
                  '${plan.equipmentWeight}kg/人',
                  CupertinoColors.systemOrange,
                  CupertinoIcons.bag,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  '安全等级',
                  plan.safetyLevel,
                  CupertinoColors.systemGreen,
                  CupertinoIcons.shield,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  '体力要求',
                  plan.physicalRequirement,
                  CupertinoColors.systemPurple,
                  CupertinoIcons.heart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationSection() {
    final transportation = plan.transportation;
    
    return _buildSection(
      title: '🚗 大交通方案',
      child: Column(
        children: [
          _buildTransportationItem(
            '去程',
            '${transportation['outbound']['date'].month}月${transportation['outbound']['date'].day}日',
            transportation['outbound']['details'],
            '¥${transportation['outbound']['cost']}',
          ),
          const SizedBox(height: 8),
          _buildTransportationItem(
            '返程',
            '${transportation['return']['date'].month}月${transportation['return']['date'].day}日',
            transportation['return']['details'],
            '¥${transportation['return']['cost']}',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.location,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${transportation['departure']} → ${transportation['destination']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  '总费用：¥${transportation['totalCost']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationItem(String type, String date, String details, String cost) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.train_style_one,
              size: 20,
              color: CupertinoColors.systemBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type $date',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.label,
                  ),
                ),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            cost,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyItinerarySection() {
    return _buildSection(
      title: '📅 每日行程安排',
      child: Column(
        children: plan.dailyItinerary.map((day) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${day['day']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        day['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                    Text(
                      day['duration'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (day['highlights'] as List<String>).map((highlight) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        highlight,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEquipmentSection() {
    final equipment = plan.equipment;
    
    return _buildSection(
      title: '🎒 装备清单',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 必需装备
          const Text(
            '✅ 必需装备',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          ...(equipment['essential'] as List).map((item) {
            return _buildEquipmentItem(
              item['name'],
              '× ${item['quantity']}',
              true,
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // 推荐装备
          const Text(
            '⚠️ 推荐装备',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          ...(equipment['recommended'] as List).map((item) {
            return _buildEquipmentItem(
              item['name'],
              '× ${item['quantity']}',
              false,
            );
          }).toList(),
          
          const SizedBox(height: 12),
          
          // 装备统计
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.bag,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  '总重量：${equipment['totalWeight']}kg',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  '预计费用：¥${equipment['estimatedCost']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(String name, String quantity, bool isEssential) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            isEssential ? CupertinoIcons.checkmark_circle : CupertinoIcons.info_circle,
            size: 16,
            color: isEssential ? CupertinoColors.systemGreen : CupertinoColors.systemOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.label,
              ),
            ),
          ),
          Text(
            quantity,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodWaterSection() {
    final foodWater = plan.foodWater;
    
    return _buildSection(
      title: '🍽️ 食物水源',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  '总热量需求',
                  '${foodWater['totalCalories']}卡',
                  CupertinoIcons.flame,
                  CupertinoColors.systemRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  '食物总重',
                  '${foodWater['totalWeight']}kg',
                  CupertinoIcons.cube_box,
                  CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  '水源补给',
                  '${foodWater['waterSources']}个安全补给点',
                  CupertinoIcons.drop,
                  CupertinoColors.systemBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 建议',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                ...(foodWater['recommendations'] as List<String>).map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Text('• ', style: TextStyle(color: CupertinoColors.systemGrey)),
                        Text(
                          rec,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    final budget = plan.budget;
    
    return _buildSection(
      title: '💰 费用明细',
      child: Column(
        children: [
          _buildBudgetItem('大交通', budget['transportation']),
          _buildBudgetItem('住宿', budget['accommodation']),
          _buildBudgetItem('门票', budget['tickets']),
          _buildBudgetItem('食物', budget['food']),
          _buildBudgetItem('装备', budget['equipment']),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CupertinoColors.systemBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.money_dollar_circle,
                  size: 20,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 12),
                const Text(
                  '总计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  '¥${budget['total']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String category, int amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
            ),
          ),
          const Spacer(),
          Text(
            '¥$amount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onEdit,
                child: const Text(
                  '调整',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}