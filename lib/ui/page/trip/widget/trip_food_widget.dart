import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:walk/model/model/food/day_meal_plan_model.dart';
import 'package:walk/model/model/food/meal_plan_model.dart';
import 'package:walk/model/model/food/food_item_model.dart';

class TripFoodWidget extends StatefulWidget {
  final MealPlanModel? mealPlan;
  const TripFoodWidget({
    super.key,
    required this.mealPlan,
  });

  @override
  State<TripFoodWidget> createState() => _TripFoodWidgetState();
}

class _TripFoodWidgetState extends State<TripFoodWidget> {
  bool _isExpanded = false;
  List<bool> _dayExpanded = [];
  Map<int, Map<String, bool>> _mealTypeExpanded = {};

  @override
  void initState() {
    super.initState();
    _initExpandedStates();
  }

  @override
  void didUpdateWidget(TripFoodWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mealPlan != widget.mealPlan) {
      _initExpandedStates();
    }
  }

  void _initExpandedStates() {
    if (widget.mealPlan != null) {
      _dayExpanded =
          List.generate(widget.mealPlan!.dayMealPlans.length, (_) => false);

      // 初始化每天的餐食类型展开状态
      _mealTypeExpanded = {};
      for (int i = 0; i < widget.mealPlan!.dayMealPlans.length; i++) {
        _mealTypeExpanded[i] = {
          'breakfast': false,
          'lunch': false,
          'dinner': false,
          'snacks': false,
          'drinks': false,
        };
      }
    } else {
      _dayExpanded = [];
      _mealTypeExpanded = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mealPlan == null || widget.mealPlan!.dayMealPlans.isEmpty) {
      return const Text(
        '暂无膳食计划',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return _buildFoodPlanCard();
  }

  Widget _buildFoodPlanCard() {
    final mealPlan = widget.mealPlan!;

    // 计算总卡路里和总食物数量
    double totalCalories = 0;
    int totalFoodItems = 0;

    for (final dayPlan in mealPlan.dayMealPlans) {
      totalFoodItems += dayPlan.allFoodItems.length;
      totalCalories += dayPlan.totalCalories;
    }

    // 计算人均每日卡路里
    final caloriesPerPersonPerDay =
        totalCalories ~/ (mealPlan.personCount * mealPlan.tripDays);

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和展开/折叠按钮
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.flame_fill,
                          color: CupertinoColors.systemGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          mealPlan.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: CupertinoColors.systemGrey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 关键数据行
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeyMetric(
                          label: '总热量',
                          value:
                              '${(totalCalories / 1000).toStringAsFixed(1)}k卡',
                          icon: CupertinoIcons.flame_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '人均/天',
                          value: '${caloriesPerPersonPerDay}卡',
                          icon: CupertinoIcons.person_crop_circle_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '食物数',
                          value: '${totalFoodItems}种',
                          icon: CupertinoIcons.cart_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '天数',
                          value: '${mealPlan.tripDays}天',
                          icon: CupertinoIcons.calendar,
                        ),
                      ),
                    ],
                  ),

                  if (!_isExpanded) ...[
                    const SizedBox(height: 16),
                    // 简短描述
                    Text(
                      mealPlan.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 展开的详细内容
          if (_isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // 详细内容
                  _buildDetailedContentContainer(),

                  // 收起按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '点击收起详情',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGreen
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_up,
                                size: 12,
                                color: CupertinoColors.systemGreen
                                    .withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedContentContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: _buildDetailedContent(),
        ),
      ),
    );
  }

  Widget _buildKeyMetric({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? CupertinoColors.systemGreen,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailedContent() {
    final mealPlan = widget.mealPlan!;

    return [
      // 详细描述
      if (mealPlan.description.isNotEmpty) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
          ),
          child: Text(
            mealPlan.description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],

      // 每日膳食计划
      ...List.generate(
        mealPlan.dayMealPlans.length,
        (index) => _buildDayMealPlanCollapsible(
          mealPlan.dayMealPlans[index],
          index,
        ),
      ),
    ];
  }

  Widget _buildDayMealPlanCollapsible(DayMealPlanModel dayPlan, int dayIndex) {
    // 计算当天总卡路里
    final totalCalories = dayPlan.totalCalories;
    final isLast = dayIndex == widget.mealPlan!.dayMealPlans.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 可点击的日期标题
          GestureDetector(
            onTap: () {
              setState(() {
                _dayExpanded[dayIndex] = !_dayExpanded[dayIndex];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGreen.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${dayPlan.dayNumber}',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '第${dayPlan.dayNumber}天膳食计划',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 卡路里概览
                  Text(
                    '${totalCalories.toInt()}卡',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _dayExpanded[dayIndex]
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 展开时显示详情
          if (_dayExpanded[dayIndex]) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 早餐
                  if (dayPlan.breakfast.isNotEmpty)
                    _buildMealTypeCollapsible(
                      '早餐',
                      dayPlan.breakfast,
                      dayIndex,
                      'breakfast',
                      CupertinoIcons.sunrise_fill,
                    ),

                  // 午餐
                  if (dayPlan.lunch.isNotEmpty)
                    _buildMealTypeCollapsible(
                      '午餐',
                      dayPlan.lunch,
                      dayIndex,
                      'lunch',
                      CupertinoIcons.sun_max_fill,
                    ),

                  // 晚餐
                  if (dayPlan.dinner.isNotEmpty)
                    _buildMealTypeCollapsible(
                      '晚餐',
                      dayPlan.dinner,
                      dayIndex,
                      'dinner',
                      CupertinoIcons.sunset_fill,
                    ),

                  // 零食
                  if (dayPlan.snacks.isNotEmpty)
                    _buildMealTypeCollapsible(
                      '零食',
                      dayPlan.snacks,
                      dayIndex,
                      'snacks',
                      CupertinoIcons.gift_fill,
                    ),

                  // 饮料
                  if (dayPlan.drinks.isNotEmpty)
                    _buildMealTypeCollapsible(
                      '饮料',
                      dayPlan.drinks,
                      dayIndex,
                      'drinks',
                      CupertinoIcons.drop_fill,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealTypeCollapsible(
    String title,
    List<FoodItemModel> foodItems,
    int dayIndex,
    String mealType,
    IconData icon,
  ) {
    // 计算这餐的总卡路里
    final totalCalories = foodItems.fold(
        0, (sum, item) => sum + (item.calories * item.quantity).toInt());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 可点击的餐食类型标题
          GestureDetector(
            onTap: () {
              setState(() {
                _mealTypeExpanded[dayIndex]![mealType] =
                    !_mealTypeExpanded[dayIndex]![mealType]!;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: CupertinoColors.systemGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // 卡路里概览
                  Text(
                    '${totalCalories}卡',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _mealTypeExpanded[dayIndex]![mealType]!
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 展开时显示食物列表
          if (_mealTypeExpanded[dayIndex]![mealType]!) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Column(
                children:
                    foodItems.map((item) => _buildFoodItem(item)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 食物图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFoodIcon(item),
              color: CupertinoColors.systemGreen,
            ),
          ),

          const SizedBox(width: 12),

          // 食物信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.systemGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${item.calories.toInt() * item.quantity}卡',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.weight}g × ${item.quantity} · 蛋白质: ${item.protein}g · 脂肪: ${item.fat}g · 碳水: ${item.carbs}g',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(FoodItemModel item) {
    // 简单的图标选择逻辑，可以根据食物名称选择不同图标
    if (item.name.contains('肉') ||
        item.name.contains('牛肉') ||
        item.name.contains('猪肉')) {
      return CupertinoIcons.gear;
    }
    if (item.name.contains('饭') ||
        item.name.contains('米饭') ||
        item.name.contains('意面')) {
      return CupertinoIcons.rectangle_grid_1x2_fill;
    }
    if (item.name.contains('麦片') || item.name.contains('燕麦')) {
      return CupertinoIcons.circle_grid_3x3_fill;
    }
    if (item.name.contains('咖啡')) return CupertinoIcons.book;
    if (item.name.contains('能量棒') || item.name.contains('蛋白棒')) {
      return CupertinoIcons.rectangle_fill;
    }
    if (item.name.contains('巧克力')) return CupertinoIcons.square_split_2x2_fill;
    if (item.name.contains('坚果') || item.name.contains('干果')) {
      return CupertinoIcons.circle_grid_hex_fill;
    }
    if (item.name.contains('饮料') || item.name.contains('水')) {
      return CupertinoIcons.drop_fill;
    }
    if (item.name.contains('蔬菜')) return CupertinoIcons.clear_fill;
    // 默认图标
    return CupertinoIcons.circle_fill;
  }
}
