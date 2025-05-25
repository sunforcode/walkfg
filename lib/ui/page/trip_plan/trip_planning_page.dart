import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/service/trip_plan_service.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/unified_map_widget.dart';
import 'package:walk/ui/map/utils/kml_parser.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import 'package:walk/ui/page/trip_plan/components/ai_analysis_overlay.dart';
import 'package:walk/ui/page/trip_plan/sections/food_water_section.dart';
import 'package:walk/ui/page/trip_plan/sections/overview_section.dart';
import 'package:walk/ui/page/trip_plan/sections/itinerary_section.dart';
import 'package:walk/ui/page/trip_plan/sections/transportation_section.dart';
import 'package:walk/ui/page/trip_plan/sections/equipment_section.dart';
import 'package:walk/ui/page/trip_plan/sections/more_section.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 行程规划页面 (新版)
class TripPlanningPage2 extends StatefulWidget {
  /// 路线
  final RouteModel route;

  /// 行程计划(可选，用于编辑现有计划)
  final TripModel? tripPlan;

  /// 构造函数
  const TripPlanningPage2({
    Key? key,
    required this.route,
    this.tripPlan,
  }) : super(key: key);

  @override
  State<TripPlanningPage2> createState() => _TripPlanningPage2State();
}

class _TripPlanningPage2State extends State<TripPlanningPage2> {
  /// 出发日期
  DateTime? _startDate;

  /// 参与人数
  int _participantCount = 1;

  /// 出发城市
  String _departureCity = '';

  /// 完整路线数据（包含轨迹点）
  late Future<RouteModel> _routeFuture;

  /// 当前地图类型
  MapType _currentMapType = MapType.standard;

  /// 当前地图提供商
  MapProviderType _currentMapProvider = MapProviderType.apple;

  /// KML轨迹点
  List<TrackPointVO> _kmlTrackPoints = [];

  /// 行程规划服务
  late TripPlanService _tripPlanService;

  /// AI分析状态
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  List<String> _analysisSteps = [];
  String _analysisStatus = '';

  /// 当前选中的部分索引
  int _selectedTabIndex = 0;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tripPlanService = ServiceLocator.instance.getTripPlanService();
    _initTripPlan();
    _loadRouteDetail();

    // 如果是新建行程，触发AI分析
    if (widget.tripPlan == null) {
      _startAIAnalysis();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载路线详情（包含轨迹点）
  void _loadRouteDetail() {
    final apiService = ServiceLocator.instance.getRouteService();
    _routeFuture = apiService.getRouteDetail(widget.route.id);

    // 添加KML解析功能
    _loadKmlData();
  }

  /// 从KML文件加载轨迹数据
  Future<void> _loadKmlData() async {
    print('开始加载KML文件: assets/maps/wutai.kml');

    // 解析KML文件
    final mapData = await KmlParser.parseFromAsset('assets/maps/wutai.kml');

    print('KML解析成功，轨迹点数量: ${mapData.trackPoints.length}');

    // 即使API加载失败，也设置KML轨迹点作为备用
    setState(() {
      _kmlTrackPoints = mapData.trackPoints;
    });
  }

  /// 初始化行程计划
  void _initTripPlan() {
    if (widget.tripPlan != null) {
      // 编辑现有计划
      setState(() {
        _startDate = widget.tripPlan!.startDate;
        _participantCount = widget.tripPlan!.participants.length;
        _departureCity = '北京';
      });
    } else {
      // 创建新计划
      setState(() {
        _departureCity = '北京'; // 默认出发城市
        _startDate = DateTime.now().add(const Duration(days: 7)); // 默认一周后出发
      });
    }
  }

  /// 开始AI分析
  void _startAIAnalysis() {
    setState(() {
      _isAnalyzing = true;
      _analysisProgress = 0.0;
      _analysisSteps = ['分析路线特点', '查询交通选项', '规划每日行程', '匹配装备清单'];
      _analysisStatus = '正在分析您的行程需求...';
    });

    // 模拟AI分析过程
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _analysisProgress = 0.25;
        _analysisStatus = '正在分析路线特点...';
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _analysisProgress = 0.5;
        _analysisStatus = '正在查询交通选项...';
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _analysisProgress = 0.75;
        _analysisStatus = '正在规划每日行程...';
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _analysisProgress = 1.0;
        _analysisStatus = '正在匹配装备清单...';
      });
    });

    // 分析完成
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isAnalyzing = false;
      });

      // 显示分析完成通知
      _showAnalysisCompleteNotification();
    });
  }

  /// 显示分析完成通知
  void _showAnalysisCompleteNotification() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('行程规划已完成!'),
          content: Column(
            children: const [
              SizedBox(height: 16),
              Text('已为您规划3天行程'),
              SizedBox(height: 8),
              Text('已匹配15件装备'),
              SizedBox(height: 8),
              Text('已安排往返交通'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('查看行程'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 保存行程计划
  void _saveTripPlan() {
    // TODO: 实现保存行程计划
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.primary,
        middle: Text(
          '${widget.route.name} - 行程规划',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            '保存',
            style: TextStyle(
              color: CupertinoColors.white,
            ),
          ),
          onPressed: _saveTripPlan,
        ),
      ),
      child: Stack(
        children: [
          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 地图组件
                _buildMapHeader(),

                // 自定义标签页
                _buildCustomTabs(),

                // 当前选中部分的内容
                Expanded(
                  child: _buildSelectedSection(),
                ),
              ],
            ),
          ),

          // AI分析悬浮层
          if (_isAnalyzing)
            AIAnalysisOverlay(
              status: _analysisStatus,
              progress: _analysisProgress,
              steps: _analysisSteps,
            ),
        ],
      ),
    );
  }

  /// 构建自定义标签页
  Widget _buildCustomTabs() {
    final tabs = [
      _TabItem(icon: CupertinoIcons.doc_text_search, label: '概览'),
      _TabItem(icon: CupertinoIcons.calendar, label: '行程'),
      _TabItem(icon: CupertinoIcons.bus, label: '交通'),
      _TabItem(icon: CupertinoIcons.bag, label: '装备'),
      _TabItem(icon: CupertinoIcons.cart, label: '食物/水'),
      _TabItem(icon: CupertinoIcons.cloud_sun, label: '天气'),
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index].icon,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tabs[index].label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建地图头部
  Widget _buildMapHeader() {
    return FutureBuilder<RouteModel>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          print('加载路线详情失败: ${snapshot.error}');
          // 即使加载失败，也尝试使用原始路线数据和KML轨迹点
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: UnifiedMapWidget(
              route: widget.route,
              trackPoints: _kmlTrackPoints,
              height: MediaQuery.of(context).size.height * 0.25,
              showCurrentLocation: false,
              showMapTypeToolbar: true,
              mapType: _currentMapType,
              mapProvider: _currentMapProvider,
              onMapTypeChanged: (mapType) {
                setState(() {
                  _currentMapType = mapType;
                });
              },
              onMapProviderChanged: (provider) {
                setState(() {
                  _currentMapProvider = provider;
                });
              },
            ),
          );
        }

        // 使用加载的路线数据
        final routeWithTrack = snapshot.data!;
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Stack(
            children: [
              UnifiedMapWidget(
                route: routeWithTrack,
                trackPoints: _kmlTrackPoints, // 始终使用KML轨迹点
                height: MediaQuery.of(context).size.height * 0.25,
                showCurrentLocation: false,
                showMapTypeToolbar: true,
                mapType: _currentMapType,
                mapProvider: _currentMapProvider,
                onMapTypeChanged: (mapType) {
                  setState(() {
                    _currentMapType = mapType;
                  });
                },
                onMapProviderChanged: (provider) {
                  setState(() {
                    _currentMapProvider = provider;
                  });
                },
              ),
              // 路线信息悬浮卡片
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.map,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routeWithTrack.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${routeWithTrack.basicInfo.distance}km | ${routeWithTrack.basicInfo.elevationGain}m爬升 | ${routeWithTrack.basicInfo.difficulty.getName()}',
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建当前选中的部分
  Widget _buildSelectedSection() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewSection();
      case 1:
        return ItinerarySection(
          route: widget.route,
          startDate: _startDate,
          tripPlanService: _tripPlanService,
        );
      case 2:
        return TransportationSection(
          route: widget.route,
          startDate: _startDate,
          departureCity: _departureCity,
          tripPlanService: _tripPlanService,
        );
      case 3:
        return EquipmentSection(
          route: widget.route,
          participantCount: _participantCount,
          tripPlanService: _tripPlanService,
        );
      case 4:
        return FoodWaterSection(
          route: widget.route,
          participantCount: _participantCount,
          tripPlanService: _tripPlanService,
        );
      case 5:
        return MoreSection(
          route: widget.route,
          trackPoints: _kmlTrackPoints,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建概览部分（作为整个规划的总结）
  Widget _buildOverviewSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息卡片
          _buildSummaryCard(),

          const SizedBox(height: 16),

          // 行程概要卡片
          _buildItinerarySummaryCard(),

          const SizedBox(height: 16),

          // 装备准备进度卡片
          _buildEquipmentProgressCard(),

          const SizedBox(height: 16),

          // 天气预报卡片
          _buildWeatherSummaryCard(),

          const SizedBox(height: 16),

          // 交通概要卡片
          _buildTransportationSummaryCard(),

          const SizedBox(height: 16),

          // 食物/水概要卡片
          _buildFoodWaterSummaryCard(),
        ],
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text_search,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '行程概览',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // 卡片内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  '出发日期',
                  _startDate != null
                      ? '${_startDate!.year}年${_startDate!.month}月${_startDate!.day}日'
                      : '未设置',
                  CupertinoIcons.calendar,
                  AppColors.primary,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  '参与人数',
                  '$_participantCount 人',
                  CupertinoIcons.person_2_fill,
                  AppColors.primary,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  '出发城市',
                  _departureCity.isEmpty ? '未设置' : _departureCity,
                  CupertinoIcons.location_fill,
                  AppColors.primary,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  '行程天数',
                  '3天',
                  CupertinoIcons.time,
                  AppColors.primary,
                ),

                const SizedBox(height: 16),

                // 编辑按钮
                Center(
                  child: CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.pencil,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '编辑基本信息',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      // TODO: 显示编辑基本信息对话框
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建行程概要卡片
  Widget _buildItinerarySummaryCard() {
    return _buildSummaryCardTemplate(
      title: '行程安排',
      icon: CupertinoIcons.calendar,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDaySummary('第1天', '显通寺 → 塔院寺', '徒步12.5km，爬升850m'),
          const Divider(),
          _buildDaySummary('第2天', '塔院寺 → 南山寺', '徒步8.3km，爬升450m'),
          const Divider(),
          _buildDaySummary('第3天', '南山寺 → 五台山', '徒步5.2km，爬升200m'),
        ],
      ),
      buttonText: '查看详细行程',
      onButtonPressed: () {
        setState(() {
          _selectedTabIndex = 1;
        });
      },
    );
  }

  /// 构建装备准备进度卡片
  Widget _buildEquipmentProgressCard() {
    return _buildSummaryCardTemplate(
      title: '装备准备',
      icon: CupertinoIcons.bag,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '装备准备进度',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 12,
              backgroundColor: CupertinoColors.systemGrey5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            '已准备: 13/20 (65%)',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 分类进度
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCategoryProgress('必备', '5/6', CupertinoColors.systemRed),
              _buildCategoryProgress('推荐', '6/8', CupertinoColors.activeOrange),
              _buildCategoryProgress('可选', '2/6', CupertinoColors.systemGrey),
            ],
          ),
        ],
      ),
      buttonText: '查看装备清单',
      onButtonPressed: () {
        setState(() {
          _selectedTabIndex = 3;
        });
      },
    );
  }

  /// 构建天气预报概要卡片
  Widget _buildWeatherSummaryCard() {
    return _buildSummaryCardTemplate(
      title: '天气预报',
      icon: CupertinoIcons.cloud_sun,
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildWeatherItem('周一', '晴', '18°/8°', CupertinoIcons.sun_max_fill),
            _buildWeatherItem(
                '周二', '多云', '16°/7°', CupertinoIcons.cloud_sun_fill),
            _buildWeatherItem(
                '周三', '小雨', '14°/6°', CupertinoIcons.cloud_rain_fill),
            _buildWeatherItem('周四', '阴', '15°/7°', CupertinoIcons.cloud_fill),
            _buildWeatherItem('周五', '晴', '17°/8°', CupertinoIcons.sun_max_fill),
          ],
        ),
      ),
      buttonText: '查看详细天气',
      onButtonPressed: () {
        setState(() {
          _selectedTabIndex = 5;
        });
      },
      warningText: '周三有雨，建议携带雨具和防水外套',
    );
  }

  /// 构建交通概要卡片
  Widget _buildTransportationSummaryCard() {
    return _buildSummaryCardTemplate(
      title: '交通安排',
      icon: CupertinoIcons.bus,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransportItem(
            '去程',
            '北京 → 五台山',
            '高铁 + 大巴',
            '6月15日 08:30',
            CupertinoIcons.arrow_right_circle_fill,
          ),
          const Divider(),
          _buildTransportItem(
            '返程',
            '五台山 → 北京',
            '大巴 + 高铁',
            '6月17日 16:00',
            CupertinoIcons.arrow_left_circle_fill,
          ),
        ],
      ),
      buttonText: '查看交通详情',
      onButtonPressed: () {
        setState(() {
          _selectedTabIndex = 2;
        });
      },
      warningText: '您有未预订的交通，建议尽快完成预订',
    );
  }

  /// 构建食物/水概要卡片
  Widget _buildFoodWaterSummaryCard() {
    return _buildSummaryCardTemplate(
      title: '食物与饮水',
      icon: CupertinoIcons.cart,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '膳食计划',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 早餐: 能量棒、麦片、牛奶粉\n• 午餐: 三明治、坚果、巧克力\n• 晚餐: 冻干食品、汤',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '饮水计划',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 每日饮水需求: 每人约2-3升\n• 水源: 路线上有3处水源点',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      buttonText: '查看详细计划',
      onButtonPressed: () {
        setState(() {
          _selectedTabIndex = 4;
        });
      },
      infoText: '根据行程强度，每人每天需要约2500-3000卡路里的热量摄入',
    );
  }

  /// 构建概要卡片模板
  Widget _buildSummaryCardTemplate({
    required String title,
    required IconData icon,
    required Widget content,
    required String buttonText,
    required VoidCallback onButtonPressed,
    String? warningText,
    String? infoText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // 卡片内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,

                const SizedBox(height: 16),

                // 警告文本
                if (warningText != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: CupertinoColors.systemYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warningText,
                            style: const TextStyle(
                              color: CupertinoColors.systemYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 信息文本
                if (infoText != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle,
                          color: CupertinoColors.systemBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            infoText,
                            style: const TextStyle(
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // 查看详情按钮
                Center(
                  child: CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_right,
                          color: CupertinoColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onPressed: onButtonPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
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
        ),
      ],
    );
  }

  /// 构建天气项
  Widget _buildWeatherItem(
      String day, String weather, String temperature, IconData icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: CupertinoColors.systemYellow,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weather,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分类进度
  Widget _buildCategoryProgress(String name, String progress, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.checkmark_circle,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          progress,
          style: TextStyle(
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建日程概要
  Widget _buildDaySummary(String day, String route, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              day,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建交通项
  Widget _buildTransportItem(
      String type, String route, String method, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type: $route',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  method,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签项
class _TabItem {
  final IconData icon;
  final String label;

  _TabItem({required this.icon, required this.label});
}
