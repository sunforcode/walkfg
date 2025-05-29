import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/service/trip_service.dart';
import 'package:walk/ui/page/trip/widgets/trip_map_header_widget.dart';
import 'package:walk/ui/page/trip/widgets/trip_adjustment_bottom_sheet.dart';
import 'package:walk/ui/page/trip/widgets/ai_analysis_dialog.dart';
import 'package:walk/ui/page/trip/widgets/ai_trip_planner_widget.dart';
import 'package:walk/ui/page/trip/widgets/ai_generated_plan_widget.dart';
import 'package:walk/ui/page/trip/widgets/floating_ai_button.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 行程详情页面
class TripDetailScreen extends StatefulWidget {
  /// 行程ID
  final String? tripId;

  /// 是否是新行程
  final bool isNewTrip;

  /// 路线ID（用于从路线开始规划）
  final String? routeId;

  /// 构造函数
  const TripDetailScreen({
    super.key,
    this.tripId,
    this.isNewTrip = false,
    this.routeId,
  });

  /// 导航到行程规划页面
  static Future<void> createFromRoute(
      BuildContext context, String routeId) async {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripDetailScreen(
          routeId: routeId,
          isNewTrip: true,
        ),
      ),
    );
  }

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  // 将_tripFuture初始化为一个空的Future，避免LateInitializationError
  Future<TripModel?> _tripFuture = Future.value(null);

  final TripService _tripService = ServiceLocator.instance.getTripService();
  final RouteService _routeService = ServiceLocator.instance.getRouteService();

  /// 编辑模式状态
  bool _isEditMode = false;

  /// 当前正在编辑的部分ID
  String? _editingSectionId;

  /// 编辑中的行程数据
  TripModel? _editingTrip;

  /// 关联的路线数据
  List<RouteModel> _relatedRoutes = [];

  /// 是否正在加载路线
  bool _isLoadingRoutes = false;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 行程参数
  String _departureCity = '上海市';
  int _participantCount = 2;
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  int _days = 4;

  /// AI生成的方案
  AITripPlan? _aiGeneratedPlan;

  /// 是否显示悬浮AI按钮
  bool _showFloatingAIButton = false;

  /// 是否已经完成初始AI分析
  bool _hasCompletedInitialAnalysis = false;

  @override
  void initState() {
    super.initState();

    // 确保在initState中初始化_tripFuture
    if (widget.routeId != null) {
      _loadNewTripFromRoute();
    } else if (widget.tripId != null) {
      _loadTripDetails();
    } else {
      // 如果既没有路线ID也没有行程ID，创建一个空行程
      _createEmptyTrip();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 创建空行程
  void _createEmptyTrip() {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: _days));

    final emptyTrip = TripModel(
      id: 'new_trip_${DateTime.now().millisecondsSinceEpoch}',
      name: '新行程',
      description: '',
      startDate: _departureDate,
      endDate: endDate,
      status: TripStatus.planning,
      participantCount: _participantCount,
      organizerId: 'current_user',
      privacySetting: 'private',
    );

    setState(() {
      _tripFuture = Future.value(emptyTrip);
      _isEditMode = true;
      _editingTrip = emptyTrip;
    });

    // 延迟启动AI分析
    _startInitialAIAnalysis();
  }

  /// 从路线加载新行程
  void _loadNewTripFromRoute() async {
    // 立即设置_tripFuture为加载中状态，避免未初始化错误
    setState(() {
      _tripFuture = Future.value(null);
      _isLoadingRoutes = true;
    });

    final route = await _routeService.getRouteById(widget.routeId!);
    final endDate = _departureDate.add(Duration(days: _days));

    final newTrip = TripModel(
      id: 'new_trip_${DateTime.now().millisecondsSinceEpoch}',
      name: route.name,
      description: route.description,
      startDate: _departureDate,
      endDate: endDate,
      status: TripStatus.planning,
      routeIds: [route.id],
      primaryRouteId: route.id,
      participantCount: _participantCount,
      organizerId: 'current_user',
      privacySetting: 'private',
    );

    setState(() {
      _tripFuture = Future.value(newTrip);
      _isEditMode = true;
      _editingTrip = newTrip;
      _relatedRoutes = [route];
      _isLoadingRoutes = false;
    });

    // 延迟启动AI分析
    _startInitialAIAnalysis();
  }

  /// 加载行程详情
  void _loadTripDetails() {
    if (widget.tripId == null) {
      // 如果tripId为空，创建一个空行程
      _createEmptyTrip();
      return;
    }

    setState(() {
      _tripFuture = _tripService.getTripById(widget.tripId!);
    });

    _tripFuture.then((trip) {
      if (trip != null) {
        _loadRelatedRoutes(trip);
        // 从行程数据中提取参数
        setState(() {
          _departureCity = '上海市'; // 这里可以从trip数据中获取
          _participantCount = trip.participantCount;
          _departureDate = trip.startDate;
          _days = trip.endDate.difference(trip.startDate).inDays + 1;
        });

        // 如果是已有行程，也启动AI分析
        _startInitialAIAnalysis();
      }
    }).catchError((error) {
      // 处理错误情况
      print('加载行程详情失败: $error');
      // 可以选择创建一个空行程或显示错误
      _createEmptyTrip();
    });
  }

  /// 启动初始AI分析
  void _startInitialAIAnalysis() {
    // 等待页面渲染完成后再显示Dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCompletedInitialAnalysis && mounted) {
        _showAIAnalysisDialog();
      }
    });
  }

  /// 显示AI分析Dialog
  void _showAIAnalysisDialog() {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIAnalysisDialog(
        departureCity: _departureCity,
        participantCount: _participantCount,
        departureDate: _departureDate,
        days: _days,
        onAnalysisComplete: _handleInitialAIAnalysisComplete,
        onCancel: () {
          Navigator.of(context).pop();
          setState(() {
            _showFloatingAIButton = true;
          });
        },
      ),
    );
  }

  /// 处理初始AI分析完成
  void _handleInitialAIAnalysisComplete(AITripPlan plan) {
    setState(() {
      _aiGeneratedPlan = plan;
      _hasCompletedInitialAnalysis = true;
      _showFloatingAIButton = true;
    });

    // 显示成功提示
    _showToast('AI规划生成完成！');
  }

  /// 加载关联的路线
  Future<void> _loadRelatedRoutes(TripModel trip) async {
    if (trip.routeIds.isEmpty) return;

    setState(() {
      _isLoadingRoutes = true;
    });

    try {
      final routes = <RouteModel>[];
      for (final routeId in trip.routeIds) {
        final route = await _routeService.getRouteById(routeId);
        routes.add(route);
      }

      setState(() {
        _relatedRoutes = routes;
        _isLoadingRoutes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoutes = false;
      });
    }
  }

  /// 显示行程微调弹框
  void _showTripAdjustmentBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TripAdjustmentBottomSheet(
        initialDepartureCity: _departureCity,
        initialParticipantCount: _participantCount,
        initialDepartureDate: _departureDate,
        initialDays: _days,
        onConfirm: _updateTripParameters,
      ),
    );
  }

  /// 显示AI助手弹框
  void _showAIAssistantBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AIAssistantBottomSheet(
        departureCity: _departureCity,
        participantCount: _participantCount,
        departureDate: _departureDate,
        days: _days,
        onParametersChanged: _updateTripParameters,
        onRegenerateAI: _regenerateAIPlan,
      ),
    );
  }

  /// 重新生成AI规划
  void _regenerateAIPlan() {
    setState(() {
      _aiGeneratedPlan = null;
    });
    _showAIAnalysisDialog();
  }

  /// 更新行程参数
  void _updateTripParameters(String city, int count, DateTime date, int days) {
    setState(() {
      _departureCity = city;
      _participantCount = count;
      _departureDate = date;
      _days = days;
    });

    // 更新行程数据
    if (_editingTrip != null) {
      final updatedTrip = _editingTrip!.copyWith(
        participantCount: count,
        startDate: date,
        endDate: date.add(Duration(days: days)),
      );
      _updateTrip(updatedTrip);
    }

    // 清除之前的AI方案，因为参数已改变
    setState(() {
      _aiGeneratedPlan = null;
    });
  }

  /// 处理AI方案生成
  void _handleAIPlanGenerated(AITripPlan plan) {
    setState(() {
      _aiGeneratedPlan = plan;
    });

    // 显示成功提示
    _showToast('AI规划生成完成！');
  }

  /// 切换编辑模式
  void _toggleEditMode() {
    if (_isEditMode) {
      // 从编辑模式切换到查看模式，保存更改
      _saveTrip();
    } else {
      // 从查看模式切换到编辑模式
      setState(() {
        _isEditMode = true;
      });
    }
  }

  /// 取消编辑
  void _cancelEdit() {
    // 显示确认对话框
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('放弃更改?'),
          content: const Text('您的更改将不会被保存。'),
          actions: [
            CupertinoDialogAction(
              child: const Text('继续编辑'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('放弃更改'),
              onPressed: () {
                Navigator.of(context).pop();

                // 如果是新行程且从路线创建，则返回上一页
                if (widget.isNewTrip && widget.tripId == null) {
                  Navigator.of(context).pop();
                  return;
                }

                setState(() {
                  _isEditMode = false;
                  _editingSectionId = null;
                  _editingTrip = null;
                });

                if (widget.tripId != null) {
                  _loadTripDetails(); // 重新加载原始数据
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 保存行程
  void _saveTrip() {
    if (_editingTrip == null) return;

    // 显示保存中指示器
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const CupertinoAlertDialog(
          title: Text('保存中'),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );

    // 保存行程
    Future<TripModel> saveFuture;
    if (widget.isNewTrip || widget.tripId == null) {
      saveFuture = _tripService.createTrip(_editingTrip!);
    } else {
      saveFuture = _tripService.updateTrip(_editingTrip!);
    }

    saveFuture.then((savedTrip) {
      // 关闭保存中对话框
      Navigator.of(context).pop();

      // 显示保存成功提示
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('保存成功'),
            content: const Text('行程已成功保存。'),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isEditMode = false;
                    _editingSectionId = null;
                    _tripFuture = Future.value(savedTrip);
                  });
                },
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      // 关闭保存中对话框
      Navigator.of(context).pop();

      // 显示错误提示
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('保存失败'),
            content: Text('发生错误: ${error.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  /// 编辑特定部分
  void _editSection(String sectionId) {
    setState(() {
      _editingSectionId = sectionId;
    });
  }

  /// 保存特定部分
  void _saveSection(String sectionId) {
    // 根据部分ID保存相应数据
    setState(() {
      _editingSectionId = null;
    });
  }

  /// 显示日期选择器
  void _showDatePicker(
      DateTime initialDate, Function(DateTime) onDateSelected) {
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
                  initialDateTime: initialDate,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: onDateSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 更新行程数据
  void _updateTrip(TripModel updatedTrip) {
    setState(() {
      _editingTrip = updatedTrip;
    });
  }

  /// 显示提示信息
  void _showToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  /// 格式化日期
  String _formatDateRange() {
    final endDate = _departureDate.add(Duration(days: _days - 1));
    return '${_departureDate.year}-${_departureDate.month.toString().padLeft(2, '0')}-${_departureDate.day.toString().padLeft(2, '0')} ~ ${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} ($_days天)';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.primary,
        middle: Text(
          widget.isNewTrip ? '创建行程' : '行程详情',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: _isEditMode
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: CupertinoColors.white,
                      ),
                    ),
                    onPressed: _cancelEdit,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        color: CupertinoColors.white,
                      ),
                    ),
                    onPressed: _saveTrip,
                  ),
                ],
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text(
                  '编辑',
                  style: TextStyle(
                    color: CupertinoColors.white,
                  ),
                ),
                onPressed: _toggleEditMode,
              ),
      ),
      child: FutureBuilder<TripModel?>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isEditMode) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError && !_isEditMode) {
            return ErrorMessageWidget(
              errorMessage: snapshot.error.toString(),
              onRetry: widget.tripId != null
                  ? _loadTripDetails
                  : _loadNewTripFromRoute,
            );
          }

          final trip = snapshot.data;
          if (trip == null && !_isEditMode) {
            return const Center(
              child: Text('未找到行程信息'),
            );
          }

          // 使用编辑中的行程或从服务器获取的行程
          final displayTrip = _editingTrip ?? trip;

          if (displayTrip == null) {
            return const LoadingIndicator();
          }

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 地图头部
                  SliverToBoxAdapter(
                    child: TripMapHeaderWidget(
                      route: _relatedRoutes.isNotEmpty
                          ? _relatedRoutes.first
                          : null,
                      height: 220,
                    ),
                  ),

                  // 基础信息
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.separator,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📍 基础信息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 路线信息
                          if (_relatedRoutes.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.map,
                                  size: 20,
                                  color: CupertinoColors.systemBlue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _relatedRoutes.first.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 时间信息
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.calendar,
                                size: 20,
                                color: CupertinoColors.systemGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatDateRange(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 人数和出发地
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.person_2,
                                size: 20,
                                color: CupertinoColors.systemOrange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_participantCount人',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                CupertinoIcons.location,
                                size: 20,
                                color: CupertinoColors.systemPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_departureCity出发',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // AI生成的方案
                  if (_aiGeneratedPlan != null)
                    SliverToBoxAdapter(
                      child: AIGeneratedPlanWidget(
                        plan: _aiGeneratedPlan!,
                        onEdit: () {
                          // 这里可以实现编辑功能
                          _showToast('编辑功能开发中');
                        },
                      ),
                    ),

                  // 确认操作
                  if (_aiGeneratedPlan != null)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoButton.filled(
                                child: const Text('确认此方案'),
                                onPressed: () {
                                  _showToast('方案已确认');
                                  // 这里可以保存方案并进入下一步
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton(
                                color: CupertinoColors.systemGrey5,
                                child: const Text(
                                  '邀请同行',
                                  style:
                                      TextStyle(color: CupertinoColors.label),
                                ),
                                onPressed: () {
                                  _showToast('邀请功能开发中');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 底部间距，避免被悬浮按钮遮挡
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120), // 增加底部间距
                  ),
                ],
              ),

              // 悬浮AI按钮
              FloatingAIButton(
                isVisible: _showFloatingAIButton,
                onPressed: _showAIAssistantBottomSheet,
              ),
            ],
          );
        },
      ),
    );
  }
}
