import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 内联编辑字段组件
class InlineEditField extends StatefulWidget {
  final String value;
  final String placeholder;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;

  const InlineEditField({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = '',
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.prefix,
    this.suffix,
  });

  @override
  State<InlineEditField> createState() => _InlineEditFieldState();
}

class _InlineEditFieldState extends State<InlineEditField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isEditing) {
      setState(() {
        _isEditing = true;
        _originalValue = _controller.text;
      });
    } else if (!_focusNode.hasFocus && _isEditing) {
      _saveChanges();
    }
  }

  void _saveChanges() {
    if (_controller.text != _originalValue) {
      widget.onChanged(_controller.text);
      // 显示轻量级保存提示
      _showSaveIndicator();
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _showSaveIndicator() {
    // 显示轻量级的保存指示器
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill, 
                 color: CupertinoColors.systemGreen, size: 16),
            SizedBox(width: 8),
            Text('已保存', style: TextStyle(fontSize: 14)),
          ],
        ),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: _isEditing 
            ? Border.all(color: CupertinoColors.activeBlue, width: 2)
            : Border.all(color: CupertinoColors.separator, width: 0.5),
        borderRadius: BorderRadius.circular(8),
        color: _isEditing 
            ? CupertinoColors.systemBlue.withOpacity(0.05)
            : CupertinoColors.systemBackground,
      ),
      child: Row(
        children: [
          if (widget.prefix != null) ...[
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: widget.prefix!,
            ),
            SizedBox(width: 8),
          ],
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              placeholder: widget.placeholder,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              decoration: BoxDecoration(),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              style: TextStyle(
                fontSize: 16,
                color: _isEditing 
                    ? CupertinoColors.label 
                    : CupertinoColors.label,
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: widget.suffix!,
            ),
          ],
          if (_isEditing) ...[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                CupertinoIcons.pencil,
                size: 16,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}