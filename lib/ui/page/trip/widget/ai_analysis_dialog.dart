import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// AI分析Dialog
class AIAnalysisDialog extends StatefulWidget {
  final String departureCity;
  final int participantCount;
  final DateTime departureDate;
  final int days;
  final Function(TripModel) onAnalysisComplete;
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
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  final List<String> _analysisSteps = [
    '分析路线数据...',
    '评估装备需求...',
    '计算预算方案...',
    '生成行程安排...',
    '优化推荐方案...',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // 开始分析
    _startAnalysis();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    // 启动进度动画
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

  Future<TripModel> _generateAIPlan() async {
    // 模拟AI分析延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 生成TripModel实例
    final endDate = widget.departureDate.add(Duration(days: widget.days));
    return TripModel(
      id: 'ai_trip_${DateTime.now().millisecondsSinceEpoch}',
      name: 'AI智能行程',
      description: 'AI智能生成的行程方案',
      startDate: widget.departureDate,
      endDate: endDate,
      status: TripStatus.planning,
      participantCount: widget.participantCount,
      organizerId: 'current_user',
      privacySetting: 'private',
      budget: _calculateBudget().toDouble(),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minHeight: 300,
        ),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 头部
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
                  Container(
                    width: 36,
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

            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '💡 基于路线数据 + 装备库分析',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI分析动画区域
                    Container(
                      height: 120,
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
                        children: [
                          // 进度条
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.gear_alt,
                                        size: 16,
                                        color: CupertinoColors.systemBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _currentStep < _analysisSteps.length
                                            ? _analysisSteps[_currentStep]
                                            : '分析完成',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.label,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemGrey5,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _progressAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.systemBlue,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 参数显示区域
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildParameterRow(
                                          '出发地', widget.departureCity),
                                      _buildParameterRow(
                                          '人数', '${widget.participantCount}人'),
                                      _buildParameterRow(
                                          '天数', '${widget.days}天'),
                                      _buildParameterRow('出发时间',
                                          '${widget.departureDate.month}月${widget.departureDate.day}日'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }
}
