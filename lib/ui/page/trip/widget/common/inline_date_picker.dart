import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 内联日期选择器
class InlineDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final String label;
  final IconData? icon;

  const InlineDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.label,
    this.icon,
  });

  @override
  State<InlineDatePicker> createState() => _InlineDatePickerState();
}

class _InlineDatePickerState extends State<InlineDatePicker> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isExpanded 
              ? CupertinoColors.activeBlue 
              : CupertinoColors.separator,
          width: _isExpanded ? 2 : 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _isExpanded 
            ? CupertinoColors.systemBlue.withValues(alpha: 0.05)
            : CupertinoColors.systemBackground,
      ),
      child: Column(
        children: [
          // 日期显示和切换按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon!,
                      color: _isExpanded 
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                  ],
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN')
                              .format(widget.selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _isExpanded 
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 快速选择按钮
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuickButton('今天', DateTime.now()),
                      SizedBox(width: 8),
                      _buildQuickButton('明天', DateTime.now().add(Duration(days: 1))),
                      SizedBox(width: 8),
                      _buildQuickButton('下周', DateTime.now().add(Duration(days: 7))),
                    ],
                  ),
                  
                  SizedBox(width: 8),
                  
                  Icon(
                    _isExpanded 
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: _isExpanded 
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          
          // 展开的日期选择器
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: CupertinoColors.separator,
            ),
            Container(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: widget.selectedDate,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDate) {
                  widget.onDateChanged(newDate);
                  // 显示轻量级保存提示
                  _showSaveIndicator();
                },
              ),
            ),
            
            // 操作按钮
            Container(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey5,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      child: Text(
                        '收起',
                        style: TextStyle(
                          color: CupertinoColors.label,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                        });
                        _showSaveIndicator();
                      },
                      child: Text(
                        '确定',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 14,
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

  Widget _buildQuickButton(String label, DateTime date) {
    final isSelected = DateFormat('yyyy-MM-dd').format(widget.selectedDate) == 
                      DateFormat('yyyy-MM-dd').format(date);
    
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        widget.onDateChanged(date);
        _showSaveIndicator();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? CupertinoColors.activeBlue
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected 
                ? CupertinoColors.white
                : CupertinoColors.label,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showSaveIndicator() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill, 
                 color: CupertinoColors.systemGreen, size: 16),
            SizedBox(width: 8),
            Text('日期已更新', style: TextStyle(fontSize: 14)),
          ],
        ),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }
}