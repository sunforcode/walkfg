import 'package:flutter/cupertino.dart';

/// 行程微调底部弹框
class TripAdjustmentBottomSheet extends StatefulWidget {
  final String initialDepartureCity;
  final int initialParticipantCount;
  final DateTime initialDepartureDate;
  final int initialDays;
  final Function(String, int, DateTime, int) onConfirm;

  const TripAdjustmentBottomSheet({
    super.key,
    required this.initialDepartureCity,
    required this.initialParticipantCount,
    required this.initialDepartureDate,
    required this.initialDays,
    required this.onConfirm,
  });

  @override
  State<TripAdjustmentBottomSheet> createState() => _TripAdjustmentBottomSheetState();
}

class _TripAdjustmentBottomSheetState extends State<TripAdjustmentBottomSheet> {
  late String _selectedCity;
  late int _selectedParticipantCount;
  late DateTime _selectedDepartureDate;
  late int _selectedDays;

  // 城市选项
  final List<String> _cities = [
    '北京市',
    '上海市',
    '广州市',
    '深圳市',
    '杭州市',
    '南京市',
    '成都市',
    '重庆市',
    '武汉市',
    '西安市',
  ];

  // 人数选项
  final List<int> _participantCounts = [1, 2, 3, 4, 5, 6, 7, 8];

  // 天数选项
  final List<int> _dayOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialDepartureCity;
    _selectedParticipantCount = widget.initialParticipantCount;
    _selectedDepartureDate = widget.initialDepartureDate;
    _selectedDays = widget.initialDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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

          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '⚙️ 行程微调',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),

          // 调整选项
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 出发地
                  _buildSectionTitle('📍 出发地'),
                  const SizedBox(height: 8),
                  _buildCitySelector(),
                  
                  const SizedBox(height: 24),

                  // 参与人数
                  _buildSectionTitle('👥 参与人数'),
                  const SizedBox(height: 8),
                  _buildParticipantCountSelector(),
                  
                  const SizedBox(height: 24),

                  // 出发时间
                  _buildSectionTitle('📅 出发时间'),
                  const SizedBox(height: 8),
                  _buildDateSelector(),
                  
                  const SizedBox(height: 24),

                  // 行程天数
                  _buildSectionTitle('⏱️ 行程天数'),
                  const SizedBox(height: 8),
                  _buildDaysSelector(),
                ],
              ),
            ),
          ),

          // 底部操作按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey5,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    onPressed: _confirmChanges,
                    child: const Text(
                      '确认修改',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: CupertinoColors.label,
      ),
    );
  }

  Widget _buildCitySelector() {
    return GestureDetector(
      onTap: _showCityPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.location,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCity,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCountSelector() {
    return GestureDetector(
      onTap: _showParticipantCountPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.person_2,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_selectedParticipantCount人',
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.calendar,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDate(_selectedDepartureDate),
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelector() {
    return GestureDetector(
      onTap: _showDaysPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.time,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_selectedDays天${_selectedDays > 1 ? "${_selectedDays - 1}夜" : ""}',
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  void _showCityPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCity = _cities[index];
                  });
                },
                children: _cities.map((city) => Text(city)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParticipantCountPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedParticipantCount = _participantCounts[index];
                  });
                },
                children: _participantCounts.map((count) => Text('$count人')).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDepartureDate,
                minimumDate: DateTime.now(),
                onDateTimeChanged: (date) {
                  setState(() {
                    _selectedDepartureDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDaysPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDays = _dayOptions[index];
                  });
                },
                children: _dayOptions.map((days) => Text('$days天${days > 1 ? "${days - 1}夜" : ""}')).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 $weekday';
  }

  void _confirmChanges() {
    widget.onConfirm(
      _selectedCity,
      _selectedParticipantCount,
      _selectedDepartureDate,
      _selectedDays,
    );
    Navigator.of(context).pop();
  }
}