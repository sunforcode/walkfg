import 'package:flutter/cupertino.dart';

/// 日期选择器对话框组件
class DatePickerDialog extends StatefulWidget {
  /// 初始日期
  final DateTime? initialDate;
  
  /// 日期选择回调
  final ValueChanged<DateTime> onDateChanged;
  
  /// 构造函数
  const DatePickerDialog({
    super.key,
    this.initialDate,
    required this.onDateChanged,
  });
  
  /// 显示日期选择器对话框
  static void show({
    required BuildContext context,
    DateTime? initialDate,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: initialDate,
        onDateChanged: onDateChanged,
      ),
    );
  }

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  /// 选中的日期
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: CupertinoColors.systemBackground,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              minimumDate: DateTime.now(),
              maximumDate: DateTime.now().add(const Duration(days: 365)),
              onDateTimeChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建头部
  Widget _buildHeader() {
    return Container(
      height: 50,
      color: CupertinoColors.white,
      child: Row(
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
              widget.onDateChanged(_selectedDate);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}