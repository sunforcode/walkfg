import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';

/// AI智能行程规划组件
class AITripPlannerWidget extends StatefulWidget {
  final RouteModel? baseRoute;
  final String departureCity;
  final int participantCount;
  final DateTime departureDate;
  final int days;
  final Function(AITripPlan) onPlanGenerated;

  const AITripPlannerWidget({
    super.key,
    this.baseRoute,
    required this.departureCity,
    required this.participantCount,
    required this.departureDate,
    required this.days,
    required this.onPlanGenerated,
  });

  @override
  State<AITripPlannerWidget> createState() => _AITripPlannerWidgetState();
}

class _AITripPlannerWidgetState extends State<AITripPlannerWidget> {
  bool _isGenerating = false;
  AITripPlan? _generatedPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CupertinoColors.systemPurple.withOpacity(0.1),
            CupertinoColors.systemBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.sparkles,
                    size: 18,
                    color: CupertinoColors.systemPurple,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI智能分析',
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

          // 分析内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 基于路线数据 + 装备库分析',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),

                // 分析结果
                _buildAnalysisResults(),

                const SizedBox(height: 20),

                // 生成按钮
                _buildGenerateButton(),

                // 生成的方案
                if (_generatedPlan != null) ...[
                  const SizedBox(height: 20),
                  _buildGeneratedPlan(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 分析结果：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),

          _buildAnalysisItem(
            '• 路线匹配度：95% ✅',
            CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 8),

          _buildAnalysisItem(
            '• 季节适宜性：${_getSeasonSuitability()}',
            CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 8),

          _buildAnalysisItem(
            '• 团队规模：${widget.participantCount}人${_getTeamSizeComment()}',
            CupertinoColors.systemOrange,
          ),
          const SizedBox(height: 8),

          _buildAnalysisItem(
            '• 行程安排：${widget.days}天${_getDurationComment()}',
            CupertinoColors.systemPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      child: CupertinoButton(
        color: CupertinoColors.systemPurple,
        onPressed: _isGenerating ? null : _generateAIPlan,
        child: _isGenerating
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI正在分析中...',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.sparkles,
                    size: 18,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '生成完整行程方案',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGeneratedPlan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: CupertinoColors.systemGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI生成的行程方案',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 方案概览
          _buildPlanOverview(),

          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  color: CupertinoColors.systemGreen,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: () => _applyPlan(),
                  child: const Text(
                    '确认此方案',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  color: CupertinoColors.systemGrey5,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: _regeneratePlan,
                  child: const Text(
                    '重新生成',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOverview() {
    if (_generatedPlan == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 方案概览',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),

        _buildOverviewItem('总预算', '¥${_generatedPlan!.totalBudget}/人'),
        _buildOverviewItem('装备重量', '${_generatedPlan!.equipmentWeight}kg/人'),
        _buildOverviewItem('安全等级', _generatedPlan!.safetyLevel),
        _buildOverviewItem('体力要求', _generatedPlan!.physicalRequirement),
      ],
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '• $label：',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.label,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getSeasonSuitability() {
    final month = widget.departureDate.month;
    if (month >= 3 && month <= 5) {
      return '春季最佳时期';
    } else if (month >= 6 && month <= 8) {
      return '夏季适宜，注意防晒';
    } else if (month >= 9 && month <= 11) {
      return '秋季最佳时期';
    } else {
      return '冬季需要特殊装备';
    }
  }

  String _getTeamSizeComment() {
    if (widget.participantCount <= 2) {
      return '适合';
    } else if (widget.participantCount <= 4) {
      return '很好';
    } else {
      return '需要更多协调';
    }
  }

  String _getDurationComment() {
    if (widget.days <= 2) {
      return '时间紧凑';
    } else if (widget.days <= 4) {
      return '时间充足';
    } else {
      return '时间很充裕';
    }
  }

  Future<void> _generateAIPlan() async {
    setState(() {
      _isGenerating = true;
    });

    // 模拟AI分析延迟
    await Future.delayed(const Duration(seconds: 2));

    // 生成模拟的AI规划结果
    final plan = AITripPlan(
      totalBudget: _calculateBudget(),
      equipmentWeight: _calculateEquipmentWeight(),
      safetyLevel: _calculateSafetyLevel(),
      physicalRequirement: _calculatePhysicalRequirement(),
      transportation: _generateTransportation(),
      dailyItinerary: _generateDailyItinerary(),
      equipment: _generateEquipment(),
      foodWater: _generateFoodWater(),
      budget: _generateBudgetBreakdown(),
    );

    setState(() {
      _generatedPlan = plan;
      _isGenerating = false;
    });
  }

  int _calculateBudget() {
    // 基础预算计算
    int baseBudget = 800;
    
    // 根据天数调整
    baseBudget += (widget.days - 1) * 200;
    
    // 根据出发城市调整
    if (widget.departureCity.contains('北京') || widget.departureCity.contains('上海')) {
      baseBudget += 200;
    }
    
    return baseBudget;
  }

  double _calculateEquipmentWeight() {
    // 基础装备重量
    double baseWeight = 6.0;
    
    // 根据天数调整
    baseWeight += (widget.days - 1) * 0.5;
    
    // 根据季节调整
    final month = widget.departureDate.month;
    if (month >= 12 || month <= 2) {
      baseWeight += 2.0; // 冬季装备更重
    }
    
    return baseWeight;
  }

  String _calculateSafetyLevel() {
    if (widget.days <= 2) {
      return '低风险';
    } else if (widget.days <= 4) {
      return '中等风险';
    } else {
      return '较高风险';
    }
  }

  String _calculatePhysicalRequirement() {
    if (widget.days <= 2) {
      return '轻度强度';
    } else if (widget.days <= 4) {
      return '中等强度';
    } else {
      return '高强度';
    }
  }

  Map<String, dynamic> _generateTransportation() {
    return {
      'departure': widget.departureCity,
      'destination': '黄山',
      'outbound': {
        'date': widget.departureDate,
        'mode': '高铁',
        'details': 'G1509 07:17-10:33',
        'cost': 154,
      },
      'return': {
        'date': widget.departureDate.add(Duration(days: widget.days - 1)),
        'mode': '高铁',
        'details': 'G1512 16:45-19:58',
        'cost': 154,
      },
      'totalCost': 308,
    };
  }

  List<Map<String, dynamic>> _generateDailyItinerary() {
    final List<Map<String, dynamic>> itinerary = [];
    
    for (int i = 0; i < widget.days; i++) {
      final day = i + 1;
      final date = widget.departureDate.add(Duration(days: i));
      
      if (day == 1) {
        itinerary.add({
          'day': day,
          'date': date,
          'title': '到达→云谷寺→白鹅岭→北海',
          'duration': '6小时',
          'highlights': ['云谷寺索道', '白鹅岭观景', '北海住宿'],
        });
      } else if (day == widget.days) {
        itinerary.add({
          'day': day,
          'date': date,
          'title': '玉屏楼→慈光阁→返程',
          'duration': '3小时',
          'highlights': ['迎客松', '慈光阁', '返程交通'],
        });
      } else {
        itinerary.add({
          'day': day,
          'date': date,
          'title': '北海→光明顶→天海→住宿',
          'duration': '5小时',
          'highlights': ['光明顶日出', '天海景区', '山上住宿'],
        });
      }
    }
    
    return itinerary;
  }

  Map<String, dynamic> _generateEquipment() {
    return {
      'essential': [
        {'name': '登山包45L', 'quantity': widget.participantCount},
        {'name': '徒步鞋防滑', 'quantity': widget.participantCount},
        {'name': '冲锋衣防风', 'quantity': widget.participantCount},
        {'name': '睡袋-5°C', 'quantity': widget.participantCount},
      ],
      'recommended': [
        {'name': '登山杖', 'quantity': widget.participantCount},
        {'name': '头灯', 'quantity': widget.participantCount},
        {'name': '防潮垫', 'quantity': widget.participantCount},
      ],
      'totalWeight': _calculateEquipmentWeight() * widget.participantCount,
      'estimatedCost': 524,
    };
  }

  Map<String, dynamic> _generateFoodWater() {
    final totalCalories = 2800 * widget.days * widget.participantCount;
    final totalWeight = 1.2 * widget.days * widget.participantCount;
    
    return {
      'totalCalories': totalCalories,
      'totalWeight': totalWeight,
      'waterSources': 3,
      'recommendations': [
        '携带净水片',
        '保温杯必备',
        '高热量食物优先',
      ],
    };
  }

  Map<String, dynamic> _generateBudgetBreakdown() {
    final transportation = 308 * widget.participantCount;
    final accommodation = 400 * widget.participantCount;
    final tickets = 230 * widget.participantCount;
    final food = 200 * widget.participantCount;
    final equipment = 524;
    
    return {
      'transportation': transportation,
      'accommodation': accommodation,
      'tickets': tickets,
      'food': food,
      'equipment': equipment,
      'total': transportation + accommodation + tickets + food + equipment,
    };
  }

  void _applyPlan() {
    if (_generatedPlan != null) {
      widget.onPlanGenerated(_generatedPlan!);
    }
  }

  void _regeneratePlan() {
    setState(() {
      _generatedPlan = null;
    });
    _generateAIPlan();
  }
}

/// AI生成的行程方案数据模型
class AITripPlan {
  final int totalBudget;
  final double equipmentWeight;
  final String safetyLevel;
  final String physicalRequirement;
  final Map<String, dynamic> transportation;
  final List<Map<String, dynamic>> dailyItinerary;
  final Map<String, dynamic> equipment;
  final Map<String, dynamic> foodWater;
  final Map<String, dynamic> budget;

  AITripPlan({
    required this.totalBudget,
    required this.equipmentWeight,
    required this.safetyLevel,
    required this.physicalRequirement,
    required this.transportation,
    required this.dailyItinerary,
    required this.equipment,
    required this.foodWater,
    required this.budget,
  });
}