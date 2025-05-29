import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip/widget/trip_card_template.dart';
import 'package:walk/model/trip/weather_info_model.dart';

/// 行程天气卡片组件
///
/// 用于显示行程期间的天气预报
class TripWeatherCardWidget extends StatelessWidget {
  /// 天气信息列表
  final List<WeatherInfoModel> weatherList;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 当前正在编辑的部分ID
  final String? editingSectionId;

  /// 编辑按钮点击回调
  final Function(String) onEdit;

  /// 保存按钮点击回调
  final Function(String) onSave;

  /// 构造函数
  const TripWeatherCardWidget({
    Key? key,
    required this.weatherList,
    required this.isEditMode,
    required this.editingSectionId,
    required this.onEdit,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 检查是否有雨天
    final hasRainyDay = weatherList.any((w) => !w.isSuitableForHiking);

    // 创建编辑按钮
    final editButton = isEditMode && editingSectionId != 'weather'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '编辑',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => onEdit('weather'),
          )
        : null;

    // 创建保存按钮
    final saveButton = isEditMode && editingSectionId == 'weather'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => onSave('weather'),
          )
        : null;

    return TripCardTemplate(
      title: '天气预报',
      icon: CupertinoIcons.cloud_sun,
      usePrimaryHeader: false,
      actionButton: isEditMode
          ? (editingSectionId == 'weather' ? saveButton : editButton)
          : null,
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              weatherList.map((weather) => _buildWeatherItem(weather)).toList(),
        ),
      ),
      warningText: hasRainyDay ? '行程期间有雨天，建议携带雨具和防水外套' : null,
      buttonText: isEditMode ? null : '查看详细天气',
      onButtonPressed: isEditMode
          ? null
          : () {
              // TODO: 跳转到详细天气页面
            },
    );
  }

  /// 构建天气项
  Widget _buildWeatherItem(WeatherInfoModel weather) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Text(
            weather.day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              weather.icon,
              color: CupertinoColors.systemYellow,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weather.weather,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weather.temperature,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
