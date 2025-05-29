import 'package:flutter/cupertino.dart';

/// 悬浮AI按钮
class FloatingAIButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isVisible;

  const FloatingAIButton({
    super.key,
    required this.onPressed,
    this.isVisible = true,
  });

  @override
  State<FloatingAIButton> createState() => _FloatingAIButtonState();
}

class _FloatingAIButtonState extends State<FloatingAIButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // 开始脉冲动画
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 120, // 调整位置，避免与底部按钮冲突
      right: 20,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 60, // 稍微减小按钮大小
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CupertinoColors.systemPurple,
                      CupertinoColors.systemBlue,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemPurple.withOpacity(0.3),
                      blurRadius: 12 * _pulseAnimation.value,
                      spreadRadius: 2 * _pulseAnimation.value,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 主按钮
                    Center(
                      child: Icon(
                        CupertinoIcons.sparkles,
                        color: CupertinoColors.white,
                        size: 26, // 稍微减小图标大小
                      ),
                    ),

                    // 脉冲效果
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CupertinoColors.white.withOpacity(
                                  0.5 * (2 - _pulseAnimation.value),
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// AI助手底部弹框
class AIAssistantBottomSheet extends StatelessWidget {
  final String departureCity;
  final int participantCount;
  final DateTime departureDate;
  final int days;
  final Function(String, int, DateTime, int) onParametersChanged;
  final VoidCallback onRegenerateAI;

  const AIAssistantBottomSheet({
    super.key,
    required this.departureCity,
    required this.participantCount,
    required this.departureDate,
    required this.days,
    required this.onParametersChanged,
    required this.onRegenerateAI,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65, // 稍微减小高度
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 头部
          Container(
            padding: const EdgeInsets.all(20),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemPurple,
                        CupertinoColors.systemBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.sparkles,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI智能助手',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: CupertinoColors.systemGrey,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当前参数显示
                  const Text(
                    '当前行程参数',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildParameterRow(
                            '出发地', departureCity, CupertinoIcons.location),
                        _buildParameterRow('参与人数', '$participantCount人',
                            CupertinoIcons.person_2),
                        _buildParameterRow(
                            '出发时间',
                            '${departureDate.month}月${departureDate.day}日',
                            CupertinoIcons.calendar),
                        _buildParameterRow(
                            '行程天数', '$days天', CupertinoIcons.time),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 操作按钮
                  const Text(
                    '智能操作',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 调整参数按钮
                  Container(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemBlue,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showParameterAdjustment(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.settings,
                            color: CupertinoColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '调整行程参数',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 重新生成按钮
                  Container(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemPurple,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRegenerateAI();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.sparkles,
                            color: CupertinoColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI重新生成规划',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 提示信息
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.info,
                          color: CupertinoColors.systemBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI会根据你的参数调整，生成最适合的行程规划',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemBlue,
                            ),
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
    );
  }

  Widget _buildParameterRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  void _showParameterAdjustment(BuildContext context) {
    // 这里可以调用参数调整弹框
    // 暂时用简单的提示代替
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('参数调整'),
        content: const Text('参数调整功能开发中'),
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
