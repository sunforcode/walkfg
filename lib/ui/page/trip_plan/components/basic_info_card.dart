import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 基本信息卡片
class BasicInfoCard extends StatelessWidget {
  /// 出发日期
  final DateTime? startDate;
  
  /// 参与人数
  final int participantCount;
  
  /// 出发城市
  final String departureCity;
  
  /// 出发日期变更回调
  final Function(DateTime) onStartDateChanged;
  
  /// 参与人数变更回调
  final Function(int) onParticipantCountChanged;
  
  /// 出发城市变更回调
  final Function(String) onDepartureCityChanged;
  
  /// 构造函数
  const BasicInfoCard({
    Key? key,
    this.startDate,
    required this.participantCount,
    required this.departureCity,
    required this.onStartDateChanged,
    required this.onParticipantCountChanged,
    required this.onDepartureCityChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TripPlanCard(
      title: '基本信息',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 出发日期
          _buildInfoItem(
            context,
            '出发日期',
            startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '请选择',
            () => _showDatePicker(context),
          ),
          
          const SizedBox(height: 16),
          
          // 参与人数
          _buildInfoItem(
            context,
            '参与人数',
            '$participantCount人',
            () => _showParticipantPicker(context),
          ),
          
          const SizedBox(height: 16),
          
          // 出发城市
          _buildInfoItem(
            context,
            '出发城市',
            departureCity.isEmpty ? '请选择' : departureCity,
            () => _showCityPicker(context),
          ),
        ],
      ),
    );
  }
  
  /// 构建信息项
  Widget _buildInfoItem(BuildContext context, String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 显示日期选择器
  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: startDate ?? DateTime.now().add(const Duration(days: 7)),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: onStartDateChanged,
                  minimumDate: DateTime.now(),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 显示人数选择器
  void _showParticipantPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: participantCount - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    onParticipantCountChanged(index + 1);
                  },
                  children: List<Widget>.generate(20, (index) {
                    return Center(
                      child: Text('${index + 1}人'),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 显示城市选择器
  void _showCityPicker(BuildContext context) {
    // 这里简化为文本输入，实际应用中可能需要更复杂的城市选择器
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        String tempCity = departureCity;
        return CupertinoAlertDialog(
          title: const Text('选择出发城市'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: CupertinoTextField(
              placeholder: '请输入城市名称',
              controller: TextEditingController(text: departureCity),
              onChanged: (value) {
                tempCity = value;
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                onDepartureCityChanged(tempCity);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}