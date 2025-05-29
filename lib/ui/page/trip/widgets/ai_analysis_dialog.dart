import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/trip/widgets/ai_trip_planner_widget.dart';

/// AI分析过程Dialog
class AIAnalysisDialog extends StatefulWidget {
  final String departureCity;
  final int participantCount;
  final DateTime departureDate;
  final int days;
  final Function(AITripPlan) onAnalysisComplete;
  final VoidCallback onCancel;

  const AIAnalysisDialog({
    super.key,
    required this.departureCity,
    required this.participantCount,
    required this.departureDate,
    required this.days,
    required this.onAnalysisComplete,
    required this.onCancel,
  });

  @override
  State<AIAnalysisDialog> createState() => _AIAnalysisDialogState();
}

class _AIAnalysisDialogState extends State<AIAnalysisDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  final List<String> _analysisSteps = [
    '正在分析路线数据...',
    '正在匹配装备库...',
    '正在计算最优方案...',
    '正在生成详细规划...',
    '分析完成！',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _startAnalysis();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startAnalysis() async {
    // 开始入场动画
    _animationController.forward();

    // 开始分析过程
    _progressController.forward();

    // 监听进度变化
    _progressController.addListener(() {
      final progress = _progressController.value;
      final newStep = (progress * (_analysisSteps.length - 1)).floor();

      if (newStep != _currentStep && newStep < _analysisSteps.length) {
        setState(() {
          _currentStep = newStep;
        });
      }
    });

    // 等待分析完成
    await _progressController.forward();

    // 等待一下显示完成状态
    await Future.delayed(const Duration(milliseconds: 800));

    // 生成AI方案
    final plan = await _generateAIPlan();

    // 通知完成
    widget.onAnalysisComplete(plan);

    // 关闭Dialog
    Navigator.of(context).pop();
  }

  Future<AITripPlan> _generateAIPlan() async {
    // 模拟AI分析延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 生成模拟的AI规划结果
    return AITripPlan(
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
  }

  int _calculateBudget() {
    int baseBudget = 800;
    baseBudget += (widget.days - 1) * 200;
    if (widget.departureCity.contains('北京') ||
        widget.departureCity.contains('上海')) {
      baseBudget += 200;
    }
    return baseBudget;
  }

  double _calculateEquipmentWeight() {
    double baseWeight = 6.0;
    baseWeight += (widget.days - 1) * 0.5;
    final month = widget.departureDate.month;
    if (month >= 12 || month <= 2) {
      baseWeight += 2.0;
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black.withOpacity(0.5),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.55, // 减小高度
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // 头部
                Container(
                  padding: const EdgeInsets.all(16), // 减小padding
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
                      Container(
                        width: 36, // 减小图标大小
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CupertinoColors.systemPurple,
                              CupertinoColors.systemBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.sparkles,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'AI智能分析中',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: widget.onCancel,
                        child: const Icon(
                          CupertinoIcons.xmark,
                          color: CupertinoColors.systemGrey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // 分析内容
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16), // 减小padding
                    child: Column(
                      children: [
                        // AI分析动画
                        Expanded(
                          flex: 3, // 调整比例
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // AI图标动画
                                AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _progressController.value *
                                          2 *
                                          3.14159,
                                      child: Container(
                                        width: 70, // 减小图标大小
                                        height: 70,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              CupertinoColors.systemPurple,
                                              CupertinoColors.systemBlue,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.sparkles,
                                          color: CupertinoColors.white,
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20), // 减小间距

                                // 进度条
                                Container(
                                  width: double.infinity,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey5,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _progressAnimation,
                                    builder: (context, child) {
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _progressAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                CupertinoColors.systemPurple,
                                                CupertinoColors.systemBlue,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 12), // 减小间距

                                // 进度百分比
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return Text(
                                      '${(_progressAnimation.value * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 16, // 减小字体
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.systemBlue,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 分析步骤
                        Expanded(
                          flex: 2, // 调整比例
                          child: Column(
                            children: [
                              const SizedBox(height: 16),

                              // 当前步骤
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _analysisSteps[_currentStep],
                                  key: ValueKey(_currentStep),
                                  style: const TextStyle(
                                    fontSize: 15, // 减小字体
                                    color: CupertinoColors.label,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 12), // 减小间距

                              // 分析参数
                              Container(
                                padding: const EdgeInsets.all(10), // 减小padding
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    _buildParameterRow(
                                        '出发地', widget.departureCity),
                                    _buildParameterRow(
                                        '人数', '${widget.participantCount}人'),
                                    _buildParameterRow('天数', '${widget.days}天'),
                                    _buildParameterRow('出发时间',
                                        '${widget.departureDate.month}月${widget.departureDate.day}日'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1), // 减小间距
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13, // 减小字体
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13, // 减小字体
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }
}
