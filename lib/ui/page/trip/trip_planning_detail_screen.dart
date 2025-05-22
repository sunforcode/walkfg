import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';
import '../../../model/model/route/route_model.dart';
import '../../../service/service_manager.dart';
import '../../../theme/theme/app_colors.dart';
import 'trip/trip_info_section.dart';
import 'trip/trip_tab_bar.dart';
import 'trip/date_picker_dialog.dart';
import 'trip/number_picker_dialog.dart';
import 'trip/track_download_section.dart';
import '../map/route_map_widget.dart';

/// 行程规划详情页面
class TripPlanningDetailScreen extends StatefulWidget {
  /// 路线
  final RouteModel route;

  /// 行程计划(可选，用于编辑现有计划)
  final TripModel? tripPlan;

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

  /// 完整路线数据（包含轨迹点）
  late Future<RouteModel> _routeFuture;

  /// 当前地图类型
  MapType _currentMapType = MapType.standard;

  @override
  void initState() {
    super.initState();
    _initTripPlan();
    _loadRouteDetail();
  }

  /// 加载路线详情（包含轨迹点）
  void _loadRouteDetail() {
    final apiService = ServiceLocator.instance.getRouteService();
    _routeFuture = apiService.getRouteDetail(widget.route.id);
  }

  /// 初始化行程计划
  void _initTripPlan() {
    if (widget.tripPlan != null) {
      // 编辑现有计划
      // _startDate = widget.tripPlan!.startDate;
      // _participantCount = widget.tripPlan!.participantCount;
      // _departureCity = widget.tripPlan!.departureCity;
      // _dailyItineraries = widget.tripPlan!.customizedItinerary;
      // _transportationPlans = widget.tripPlan!.transportationPlans;
      // _equipmentList = widget.tripPlan!.equipmentList;
    } else {
      // 创建新计划
      _loadDefaultItineraries();
      _loadDefaultEquipmentList();
    }
  }

  /// 加载默认每日行程
  void _loadDefaultItineraries() {
    final apiService = ServiceLocator.instance.getTripPlanService();
    // apiService.getRouteItineraries(widget.route.id).then((itineraries) {
    //   setState(() {
    //     _dailyItineraries = itineraries;
    //   });
    // });
  }

  /// 加载默认装备清单
  void _loadDefaultEquipmentList() {
    final apiService = ServiceLocator.instance.getTripPlanService();
    // apiService.getRecommendedEquipment(widget.route.id, 5).then((equipment) {
    //   setState(() {
    //     _equipmentList = equipment;
    //   });
    // });
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
            // 地图组件 - 放在页面最上方
            _buildMapHeader(),

            // 基本信息设置区
            TripInfoSection(
              route: widget.route,
              startDate: _startDate,
              participantCount: _participantCount,
              departureCity: _departureCity,
              onSelectDate: _showDatePicker,
              onSelectParticipants: _showParticipantPicker,
              onCityChanged: (value) {
                setState(() {
                  _departureCity = value;
                });
              },
            ),

            // 标签页导航
            TripTabBar(
              tabTitles: _tabTitles,
              currentIndex: _currentTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
            ),

            // 标签页内容
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地图头部
  Widget _buildMapHeader() {
    return FutureBuilder<RouteModel>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          print('加载路线详情失败: ${snapshot.error}');
          // 即使加载失败，也尝试使用原始路线数据
          return RouteMapWidget(
            route: widget.route,
            height: MediaQuery.of(context).size.height * 0.3,
            showCurrentLocation: false,
            showMapTypeToolbar: true,
            mapType: _currentMapType,
            onMapTypeChanged: (mapType) {
              setState(() {
                _currentMapType = mapType;
              });
            },
          );
        }

        // 使用加载的路线数据（包含轨迹点）
        final routeWithTrack = snapshot.data!;
        // print('地图头部 - 轨迹点数量: ${routeWithTrack.trackPoints!.length}');

        return RouteMapWidget(
          route: routeWithTrack,
          height: MediaQuery.of(context).size.height * 0.3,
          showCurrentLocation: false,
          showMapTypeToolbar: true,
          mapType: _currentMapType,
          onMapTypeChanged: (mapType) {
            setState(() {
              _currentMapType = mapType;
            });
          },
        );
      },
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线概览卡片
          _buildRouteOverviewCard(),
        ],
      ),
    );
  }

  /// 构建路线概览卡片
  Widget _buildRouteOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线名称
          Text(
            widget.route.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 路线描述
          Text(
            widget.route.description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),

          const SizedBox(height: 16),

          // 路线统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('距离', '${widget.route.basicInfo.distance} 公里'),
              _buildStatItem('时长', '${widget.route.basicInfo.duration} 天'),
              _buildStatItem('难度', widget.route.getDifficultyName()),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
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
    return FutureBuilder<RouteModel>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (snapshot.hasError) {
          print('加载路线详情失败: ${snapshot.error}');
          // 即使加载失败，也尝试使用原始路线数据
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TrackDownloadSection(route: widget.route),
          );
        }

        // 使用加载的路线数据（包含轨迹点）
        final routeWithTrack = snapshot.data!;
        // print('轨迹下载 - 轨迹点数量: ${routeWithTrack.trackPoints!.length}');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TrackDownloadSection(route: routeWithTrack),
        );
      },
    );
  }

  /// 显示日期选择器
  void _showDatePicker() {
    DatePickerDialog.show(
      context: context,
      initialDate: _startDate,
      onDateChanged: (date) {
        setState(() {
          _startDate = date;
        });
      },
    );
  }

  /// 显示人数选择器
  void _showParticipantPicker() {
    NumberPickerDialog.show(
      context: context,
      initialValue: _participantCount,
      unit: '人',
      onValueChanged: (value) {
        setState(() {
          _participantCount = value;
        });
      },
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
