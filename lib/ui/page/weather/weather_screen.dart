import 'package:flutter/cupertino.dart';

import '../../../model/weather/day_weather_model.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/typography.dart';

/// P11 天气 — 徒步日逐日天气预报与详细气象数据查看页
///
/// 从 P14 功能抽屉 "天气" / P6 行程详情天气段 进入。
/// v1 使用 mock 数据，不接入真实天气 API。
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgBase,
      navigationBar: CupertinoNavigationBar(
        middle: Text('天气', style: AppTypography.titleSm),
        backgroundColor: AppColors.bgBase,
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '← 返回',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: const [
            _CurrentWeatherCard(),
            _ForecastSection(),
            _DetailDataSection(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  3.2 当前天气卡
// ============================================================

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.iconBgWeather,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x14FFC850), // rgba(255,200,80,.08)
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 当前温度 48px / w200 / #fff
          Text(
            '${_mockCurrentTemp}°',
            style: AppTypography.displayHero,
          ),
          const SizedBox(height: 4),
          // 天气状况 16px / rgba(255,255,255,.6)
          Text(
            '${_mockConditionIcon} ${_mockCondition}',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          // 位置 13px / rgba(255,255,255,.3)
          Text(
            _mockLocation,
            style: AppTypography.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  3.3 徒步日预报区
// ============================================================

class _ForecastSection extends StatelessWidget {
  const _ForecastSection();

  @override
  Widget build(BuildContext context) {
    final days = _mockForecastDays;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区块标题
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              '徒步日预报',
              style: AppTypography.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
          // 卡片容器
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < days.length; i++) ...[
                  _ForecastDayItem(day: days[i]),
                  if (i < days.length - 1)
                    Container(
                      height: 1,
                      color: AppColors.surfaceDivider,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastDayItem extends StatelessWidget {
  const _ForecastDayItem({required this.day});

  final DayWeatherModel day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // 日期 14px / #fff / 固定宽度 80px
          SizedBox(
            width: 80,
            child: Text(
              _formatDate(day.date),
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
          ),
          // 天气图标 18px / 固定宽度 30px / 居中
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                day.conditionIcon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          // 温度范围 13px / rgba(255,255,255,.5) / flex:1
          Expanded(
            child: Text(
              _tempRange(day),
              style: AppTypography.caption.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ),
          // 降雨概率 12px / rgba(100,180,255,.6) / 固定宽度 50px / 右对齐
          SizedBox(
            width: 50,
            child: Text(
              _rainText(day),
              style: AppTypography.label.copyWith(
                color: const Color(0x9964B4FF), // rgba(100,180,255,.6)
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final wd = weekdays[date.weekday - 1];
    return '${date.month}月${date.day}日 $wd';
  }

  String _tempRange(DayWeatherModel d) {
    if (d.tempLow == null || d.tempHigh == null) return '--°';
    return '${d.tempLow!.toInt()}-${d.tempHigh!.toInt()}°';
  }

  String _rainText(DayWeatherModel d) {
    if (d.rainProbability == null) return '--';
    return '${d.rainProbability}%';
  }
}

// ============================================================
//  3.4 详细数据区
// ============================================================

class _DetailDataSection extends StatelessWidget {
  const _DetailDataSection();

  @override
  Widget build(BuildContext context) {
    final items = _mockDetailItems;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区块标题
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              '详细数据',
              style: AppTypography.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
          // 卡片容器
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _DetailItem(item: items[i]),
                  if (i < items.length - 1)
                    Container(
                      height: 1,
                      color: AppColors.surfaceDivider,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.item});

  final _DetailRow item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // 左侧标签 14px / #fff / 固定宽度 80px
          SizedBox(
            width: 80,
            child: Text(
              item.label,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
          ),
          // 右侧数值 13px / rgba(255,255,255,.5) / flex:1 / 右对齐
          Expanded(
            child: Text(
              item.value,
              style: AppTypography.caption.copyWith(
                color: AppColors.textBody,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  详细数据行模型
// ============================================================

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
}

// ============================================================
//  Mock 数据
// ============================================================

const int _mockCurrentTemp = 22;
const String _mockCondition = '晴转多云';
const String _mockConditionIcon = '⛅';
const String _mockLocation = '四川 · 甘孜 · 贡嘎西坡';

List<DayWeatherModel> get _mockForecastDays {
  final now = DateTime.now();
  return [
    DayWeatherModel(
      date: now,
      condition: DayWeatherCondition.cloudy,
      conditionText: '多云',
      tempHigh: 24,
      tempLow: 12,
      rainProbability: 10,
      windSpeed: 8,
      windDirection: '西北',
    ),
    DayWeatherModel(
      date: now.add(const Duration(days: 1)),
      condition: DayWeatherCondition.sunny,
      conditionText: '晴',
      tempHigh: 26,
      tempLow: 14,
      rainProbability: 5,
      windSpeed: 6,
      windDirection: '西',
    ),
    DayWeatherModel(
      date: now.add(const Duration(days: 2)),
      condition: DayWeatherCondition.lightRain,
      conditionText: '小雨',
      tempHigh: 18,
      tempLow: 10,
      rainProbability: 65,
      windSpeed: 15,
      windDirection: '东南',
    ),
  ];
}

List<_DetailRow> get _mockDetailItems => [
      const _DetailRow('风速', '8 km/h'),
      const _DetailRow('湿度', '58%'),
      const _DetailRow('紫外线', '8 (很强)'),
      const _DetailRow('日出/日落', '06:42 / 19:58'),
    ];
