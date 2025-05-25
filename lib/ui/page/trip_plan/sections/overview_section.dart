import 'package:flutter/cupertino.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';

/// 概览部分
class OverviewSection extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 出发日期
  final DateTime? startDate;

  /// 参与人数
  final int participantCount;

  /// 出发城市
  final String departureCity;

  /// 出发日期变更回调
  final ValueChanged<DateTime?> onStartDateChanged;

  /// 参与人数变更回调
  final ValueChanged<int> onParticipantCountChanged;

  /// 出发城市变更回调
  final ValueChanged<String> onDepartureCityChanged;

  /// 构造函数
  const OverviewSection({
    Key? key,
    required this.route,
    required this.startDate,
    required this.participantCount,
    required this.departureCity,
    required this.onStartDateChanged,
    required this.onParticipantCountChanged,
    required this.onDepartureCityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息卡片
          _buildBasicInfoCard(context),

          const SizedBox(height: 16),

          // 路线概览卡片
          _buildRouteOverviewCard(),

          const SizedBox(height: 16),

          // 行程描述卡片
          _buildDescriptionCard(),
        ],
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard(BuildContext context) {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitleWidget(title: '基本信息'),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('编辑'),
                onPressed: () {
                  _showEditBasicInfoDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 出发日期
          _buildInfoRow(
            '出发日期',
            startDate != null
                ? '${startDate!.year}年${startDate!.month}月${startDate!.day}日'
                : '未设置',
            CupertinoIcons.calendar,
          ),

          const SizedBox(height: 12),

          // 参与人数
          _buildInfoRow(
            '参与人数',
            '$participantCount 人',
            CupertinoIcons.person_2_fill,
          ),

          const SizedBox(height: 12),

          // 出发城市
          _buildInfoRow(
            '出发城市',
            departureCity.isEmpty ? '未设置' : departureCity,
            CupertinoIcons.location_fill,
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建路线概览卡片
  Widget _buildRouteOverviewCard() {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(title: '路线概览'),
          const SizedBox(height: 8),

          // 路线名称
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 路线数据
          Row(
            children: [
              _buildRouteDataItem('距离', '${route.basicInfo.distance}km'),
              _buildRouteDataItem('爬升', '${route.basicInfo.elevationGain}m'),
              _buildRouteDataItem('难度', route.basicInfo.difficulty.getName()),
            ],
          ),

          const SizedBox(height: 12),

          // 路线位置
          Row(
            children: [
              const Icon(
                CupertinoIcons.location,
                size: 16,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '未知位置',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建路线数据项
  Widget _buildRouteDataItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建行程描述卡片
  Widget _buildDescriptionCard() {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitleWidget(title: '行程描述'),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('编辑'),
                onPressed: () {
                  // TODO: 显示编辑行程描述对话框
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            route.description ?? '暂无描述',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示编辑基本信息对话框
  void _showEditBasicInfoDialog(BuildContext context) {
    DateTime? tempStartDate = startDate;
    int tempParticipantCount = participantCount;
    String tempDepartureCity = departureCity;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '编辑基本信息',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('完成'),
                        onPressed: () {
                          onStartDateChanged(tempStartDate);
                          onParticipantCountChanged(tempParticipantCount);
                          onDepartureCityChanged(tempDepartureCity);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 出发日期
                  const Text(
                    '出发日期',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showDatePicker(
                        context,
                        tempStartDate ??
                            DateTime.now().add(const Duration(days: 7)),
                        (date) {
                          setState(() {
                            tempStartDate = date;
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tempStartDate != null
                                ? '${tempStartDate!.year}年${tempStartDate!.month}月${tempStartDate!.day}日'
                                : '选择日期',
                          ),
                          const Icon(
                            CupertinoIcons.calendar,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 参与人数
                  const Text(
                    '参与人数',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.minus_circle),
                        onPressed: tempParticipantCount > 1
                            ? () {
                                setState(() {
                                  tempParticipantCount--;
                                });
                              }
                            : null,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$tempParticipantCount 人',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.plus_circle),
                        onPressed: () {
                          setState(() {
                            tempParticipantCount++;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 出发城市
                  const Text(
                    '出发城市',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    padding: const EdgeInsets.all(12),
                    placeholder: '输入出发城市',
                    controller: TextEditingController(text: tempDepartureCity),
                    onChanged: (value) {
                      tempDepartureCity = value;
                    },
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 显示日期选择器
  void _showDatePicker(BuildContext context, DateTime initialDate,
      ValueChanged<DateTime> onDateChanged) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              initialDateTime: initialDate,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: onDateChanged,
              minimumDate: DateTime.now(),
              maximumDate: DateTime.now().add(const Duration(days: 365)),
            ),
          ),
        );
      },
    );
  }

  /// 获取难度文本
  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '中等';
      case 3:
        return '困难';
      case 4:
        return '极难';
      default:
        return '未知';
    }
  }
}
