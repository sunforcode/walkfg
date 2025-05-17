import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip_plan_model.dart';
import '../../../service/service_locator.dart';
import '../../theme/app_colors.dart';

/// 行程规划详情页面
class TripPlanningDetailScreen extends StatefulWidget {
  /// 路线
  final RouteModel route;

  /// 行程计划(可选，用于编辑现有计划)
  final TripPlanModel? tripPlan;

  /// 构造函数
  const TripPlanningDetailScreen({
    super.key,
    required this.route,
    this.tripPlan,
  });

  @override
  State<TripPlanningDetailScreen> createState() =>
      _TripPlanningDetailScreenState();
}

class _TripPlanningDetailScreenState extends State<TripPlanningDetailScreen> {
  /// 当前选中的标签页索引
  int _currentTabIndex = 0;

  /// 标签页标题
  final List<String> _tabTitles = [
    '行程概览',
    '每日行程',
    '交通接驳',
    '营地信息',
    '装备清单',
    '轨迹下载'
  ];

  /// 出发日期
  DateTime? _startDate;

  /// 参与人数
  int _participantCount = 1;

  /// 出发城市
  String _departureCity = '';

  /// 每日行程
  List<DailyItinerary> _dailyItineraries = [];

  /// 交通方案
  List<TransportationPlanModel> _transportationPlans = [];

  /// 装备清单
  List<EquipmentItemModel> _equipmentList = [];

  @override
  void initState() {
    super.initState();
    _initTripPlan();
  }

  /// 初始化行程计划
  void _initTripPlan() {
    if (widget.tripPlan != null) {
      // 编辑现有计划
      _startDate = widget.tripPlan!.startDate;
      _participantCount = widget.tripPlan!.participantCount;
      _departureCity = widget.tripPlan!.departureCity;
      _dailyItineraries = widget.tripPlan!.customizedItinerary;
      _transportationPlans = widget.tripPlan!.transportationPlans;
      _equipmentList = widget.tripPlan!.equipmentList;
    } else {
      // 创建新计划
      _loadDefaultItineraries();
      _loadDefaultEquipmentList();
    }
  }

  /// 加载默认每日行程
  void _loadDefaultItineraries() {
    final apiService = ServiceLocator.instance.getApiService();
    apiService.getRouteItineraries(widget.route.id).then((itineraries) {
      setState(() {
        _dailyItineraries = itineraries;
      });
    });
  }

  /// 加载默认装备清单
  void _loadDefaultEquipmentList() {
    final apiService = ServiceLocator.instance.getApiService();
    apiService.getRecommendedEquipment(widget.route.id).then((equipment) {
      setState(() {
        _equipmentList = equipment;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.route.name} - 行程规划'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('保存'),
          onPressed: _saveTripPlan,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 基本信息设置区
            _buildBasicInfoSection(),

            // 标签页导航
            _buildTabBar(),

            // 标签页内容
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息设置区
  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线基本信息
          Text(
            widget.route.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                CupertinoIcons.location,
                widget.route.region,
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                CupertinoIcons.clock,
                '${widget.route.durationDays}天',
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                CupertinoIcons.chart_bar,
                widget.route.getDifficultyName(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 行程设置
          Row(
            children: [
              // 出发日期
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '出发日期',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: _showDatePicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}'
                                : '选择日期',
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.calendar,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 人数
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '人数',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 100,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: _showParticipantPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_participantCount人',
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.person_2,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 出发城市
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '出发城市',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              CupertinoTextField(
                placeholder: '输入出发城市',
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) {
                  setState(() {
                    _departureCity = value;
                  });
                },
                controller: TextEditingController(text: _departureCity),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建标签页导航
  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabTitles.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentTabIndex;
          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _currentTabIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _tabTitles[index],
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.primary : CupertinoColors.label,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建标签页内容
  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildDailyItineraryTab();
      case 2:
        return _buildTransportationTab();
      case 3:
        return _buildCampsiteTab();
      case 4:
        return _buildEquipmentTab();
      case 5:
        return _buildTrackTab();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建行程概览标签页
  Widget _buildOverviewTab() {
    return const Center(
      child: Text('行程概览标签页'),
    );
  }

  /// 构建每日行程标签页
  Widget _buildDailyItineraryTab() {
    return const Center(
      child: Text('每日行程标签页'),
    );
  }

  /// 构建交通接驳标签页
  Widget _buildTransportationTab() {
    return const Center(
      child: Text('交通接驳标签页'),
    );
  }

  /// 构建营地信息标签页
  Widget _buildCampsiteTab() {
    return const Center(
      child: Text('营地信息标签页'),
    );
  }

  /// 构建装备清单标签页
  Widget _buildEquipmentTab() {
    return const Center(
      child: Text('装备清单标签页'),
    );
  }

  /// 构建轨迹下载标签页
  Widget _buildTrackTab() {
    return const Center(
      child: Text('轨迹下载标签页'),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 显示日期选择器
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _startDate ?? DateTime.now(),
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (date) {
                  setState(() {
                    _startDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示人数选择器
  void _showParticipantPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                    initialItem: _participantCount - 1),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _participantCount = index + 1;
                  });
                },
                children: List.generate(20, (index) {
                  return Center(
                    child: Text('${index + 1}人'),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示添加行程日对话框
  void _showAddDayDialog() {
    // TODO: 实现添加行程日对话框
  }

  /// 编辑每日行程
  void _editDailyItinerary(int dayIndex) {
    // TODO: 实现编辑每日行程
  }

  /// 删除每日行程
  void _deleteDailyItinerary(int dayIndex) {
    // TODO: 实现删除每日行程
  }

  /// 添加途经点
  void _addWaypoint(int dayIndex) {
    // TODO: 实现添加途经点
  }

  /// 保存行程计划
  void _saveTripPlan() {
    // TODO: 实现保存行程计划
    Navigator.of(context).pop();
  }
}
