import 'package:flutter/cupertino.dart';

/// 数字选择器对话框组件
class NumberPickerDialog extends StatefulWidget {
  /// 初始值
  final int initialValue;
  
  /// 最小值
  final int minValue;
  
  /// 最大值
  final int maxValue;
  
  /// 单位
  final String unit;
  
  /// 值变更回调
  final ValueChanged<int> onValueChanged;
  
  /// 构造函数
  const NumberPickerDialog({
    super.key,
    required this.initialValue,
    this.minValue = 1,
    this.maxValue = 20,
    required this.unit,
    required this.onValueChanged,
  });
  
  /// 显示数字选择器对话框
  static void show({
    required BuildContext context,
    required int initialValue,
    int minValue = 1,
    int maxValue = 20,
    required String unit,
    required ValueChanged<int> onValueChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => NumberPickerDialog(
        initialValue: initialValue,
        minValue: minValue,
        maxValue: maxValue,
        unit: unit,
        onValueChanged: onValueChanged,
      ),
    );
  }

  @override
  State<NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  /// 选中的值
  late int _selectedValue;
  
  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
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
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(
                initialItem: _selectedValue - widget.minValue,
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedValue = index + widget.minValue;
                });
              },
              children: List.generate(
                widget.maxValue - widget.minValue + 1,
                (index) {
                  final value = index + widget.minValue;
                  return Center(
                    child: Text('$value${widget.unit}'),
                  );
                },
              ),
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
              widget.onValueChanged(_selectedValue);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}