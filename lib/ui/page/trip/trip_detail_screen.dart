import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/service/trip_service.dart';
import 'package:walk/ui/page/trip/widget/trip_details_content_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_planning_button_widget.dart';
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
    final endDate = now.add(const Duration(days: 7));

    final emptyTrip = TripModel(
      id: 'new_trip_${DateTime.now().millisecondsSinceEpoch}',
      name: '新行程',
      description: '',
      startDate: now,
      endDate: endDate,
      status: TripStatus.planning,
      participantCount: 1,
      organizerId: 'current_user',
      privacySetting: 'private',
    );

    setState(() {
      _tripFuture = Future.value(emptyTrip);
      _isEditMode = true;
      _editingTrip = emptyTrip;
    });
  }

  /// 从路线加载新行程
  void _loadNewTripFromRoute() async {
    // 立即设置_tripFuture为加载中状态，避免未初始化错误
    setState(() {
      _tripFuture = Future.value(null);
      _isLoadingRoutes = true;
    });

    final route = await _routeService.getRouteById(widget.routeId!);
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));

    final newTrip = TripModel(
      id: 'new_trip_${DateTime.now().millisecondsSinceEpoch}',
      name: route.name,
      description: route.description,
      startDate: now,
      endDate: endDate,
      status: TripStatus.planning,
      routeIds: [route.id],
      primaryRouteId: route.id,
      participantCount: 1,
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
      }
    }).catchError((error) {
      // 处理错误情况
      print('加载行程详情失败: $error');
      // 可以选择创建一个空行程或显示错误
      _createEmptyTrip();
    });
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

  /// 显示路线选择对话框
  void _showRouteSelectionDialog(TripModel trip) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
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
                    '选择路线',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('关闭'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 搜索框
              CupertinoSearchTextField(
                placeholder: '搜索路线',
                onSubmitted: (value) {
                  // TODO: 实现路线搜索
                },
              ),

              const SizedBox(height: 16),

              // 路线列表
              Expanded(
                child: FutureBuilder<List<RouteModel>>(
                  future: _routeService.getRecommendedRoutes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text('无法加载路线'),
                      );
                    }

                    final routes = snapshot.data!;

                    return ListView.builder(
                      itemCount: routes.length,
                      itemBuilder: (context, index) {
                        final route = routes[index];
                        return GestureDetector(
                          onTap: () {
                            // 添加路线到行程
                            _addRouteToTrip(trip, route);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        route.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${route.basicInfo.distance}km | ${route.basicInfo.elevationGain}m爬升',
                                        style: const TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_right,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 添加路线到行程
  void _addRouteToTrip(TripModel trip, RouteModel route) {
    if (_editingTrip == null) {
      _editingTrip = trip;
    }

    // 创建新的路线ID列表
    final List<String> newRouteIds = List.from(_editingTrip!.routeIds);
    if (!newRouteIds.contains(route.id)) {
      newRouteIds.add(route.id);
    }

    // 更新行程数据
    final updatedTrip = _editingTrip!.copyWith(
      routeIds: newRouteIds,
      primaryRouteId: _editingTrip!.primaryRouteId ?? route.id,
    );

    _updateTrip(updatedTrip);

    // 重新加载关联的路线
    _loadRelatedRoutes(updatedTrip);

    // 显示提示
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('路线已添加'),
          content: Text('路线"${route.name}"已添加到行程中。'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('开始规划'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 开始规划行程
  void _startPlanning(TripModel trip) {}

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
              // 行程详情内容
              TripDetailsContentWidget(
                trip: displayTrip,
                isEditMode: _isEditMode,
                editingSectionId: _editingSectionId,
                editingTrip: _editingTrip,
                scrollController: _scrollController,
                onEdit: _editSection,
                onSave: _saveSection,
                onToggleEditMode: _toggleEditMode,
                onShowDatePicker: _showDatePicker,
                onTripUpdated: _updateTrip,
              ),

              // 规划按钮
              if (!_isEditMode)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: TripPlanningButtonWidget(
                    onAddRoute: () => _showRouteSelectionDialog(displayTrip),
                    onStartPlanning: () => _startPlanning(displayTrip),
                    hasRoutes: displayTrip.routeIds.isNotEmpty,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
