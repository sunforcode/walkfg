import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/trip_service.dart';
import 'package:walk/ui/page/trip/widget/trip_collapsible_section_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/utils/toast_utils.dart';

/// 行程编辑页面
class TripEditScreen extends StatefulWidget {
  /// 行程ID
  final String tripId;

  /// 构造函数
  const TripEditScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends State<TripEditScreen> {
  late Future<TripModel> _tripFuture;

  /// 编辑中的行程数据
  TripModel? _editingTrip;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 行程名称编辑控制器
  final TextEditingController _nameController = TextEditingController();

  /// 行程描述编辑控制器
  final TextEditingController _descriptionController = TextEditingController();

  /// 是否有未保存的更改
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 加载行程详情
  void _loadTripDetails() {
    setState(() {
      _tripFuture = TripService.getTripById(widget.tripId);
    });

    _tripFuture.then((trip) {
      if (!mounted) return;
      setState(() {
        _editingTrip = trip;
      });
    }).catchError((error) {
      debugPrint('加载行程详情失败: $error');
    });
  }

  /// 保存行程
  Future<void> _saveTrip() async {
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

    try {
      await TripService.updateTrip(_editingTrip!);

      // 关闭保存中对话框
      if (mounted) Navigator.of(context).pop();

      // 显示保存成功提示
      ToastUtils.showToast(context, '保存成功');

      // 返回上一页面，并传递更新标识
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      // 关闭保存中对话框
      if (mounted) Navigator.of(context).pop();

      // 显示错误提示
      ToastUtils.showToast(context, '保存失败: ${error.toString()}');
    }
  }

  /// 取消编辑
  void _cancelEdit() {
    if (_hasUnsavedChanges) {
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
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  /// 更新行程数据
  void _updateTrip(TripModel updatedTrip) {
    setState(() {
      _editingTrip = updatedTrip;
      _hasUnsavedChanges = true;
    });
  }

  /// 显示提示信息

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.primary,
        middle: const Text(
          '编辑行程',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            '取消',
            style: TextStyle(
              color: AppColors.textBody,
            ),
          ),
          onPressed: _cancelEdit,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            '保存',
            style: TextStyle(
              color: AppColors.interactiveAccent,
            ),
          ),
          onPressed: _saveTrip,
        ),
      ),
      child: FutureBuilder<TripModel>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorMessageWidget(
              errorMessage: snapshot.error.toString(),
              onRetry: _loadTripDetails,
            );
          }

          final trip = snapshot.data;
          if (trip == null) {
            return const Center(
              child: Text('未找到行程信息'),
            );
          }

          final displayTrip = _editingTrip ?? trip;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 基础信息编辑
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgPanel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📝 基础信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 行程名称
                      const Text(
                        '行程名称',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBody,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        placeholder: '请输入行程名称',
                        controller: _nameController
                          ..text = displayTrip.name,
                        onChanged: (value) {
                          _updateTrip(displayTrip.copyWith(name: value));
                        },
                      ),
                      const SizedBox(height: 16),

                      // 出发日期 (PRD §3.2: read-only display)
                      _DateRow(label: '出发日期', value: _fmtDate(displayTrip.startDate)),
                      const SizedBox(height: 16),

                      // 返回日期
                      _DateRow(label: '返回日期', value: _fmtDate(displayTrip.endDate)),
                      const SizedBox(height: 16),

                      // 行程描述
                      const Text(
                        '行程描述',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBody,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        placeholder: '请输入行程描述',
                        controller: _descriptionController
                          ..text = displayTrip.description,
                        maxLines: 3,
                        onChanged: (value) {
                          _updateTrip(displayTrip.copyWith(description: value));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 每日行程编辑 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '📅 每日行程',
                  subtitle: '编辑详细行程安排',
                  icon: CupertinoIcons.calendar_today,
                  iconColor: AppColors.interactiveAccent,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '每日行程编辑功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 参与者管理 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '👥 参与者',
                  subtitle: '管理参与者信息',
                  icon: CupertinoIcons.person_2_fill,
                  iconColor: AppColors.badgeRecommendedBg,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '参与者管理功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 装备管理 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '🎒 装备清单',
                  subtitle: '管理装备清单',
                  icon: CupertinoIcons.bag_fill,
                  iconColor: AppColors.badgeVerifiedBg,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '装备管理功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 预算管理 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '💰 费用预算',
                  subtitle: '管理预算分配',
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  iconColor: AppColors.statusCompletedText,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '预算管理功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 食物饮水规划 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '🍽️ 食物饮水',
                  subtitle: '规划餐食和饮水',
                  icon: CupertinoIcons.flame_fill,
                  iconColor: AppColors.statusPlanningText,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '食物饮水规划功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 交通住宿预订 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '🚗 交通住宿',
                  subtitle: '预订交通和住宿',
                  icon: CupertinoIcons.car_fill,
                  iconColor: AppColors.interactiveAccent,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '交通住宿预订功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 安全备注 (可折叠)
              SliverToBoxAdapter(
                child: TripCollapsibleSectionWidget(
                  title: '🌤️ 安全备注',
                  subtitle: '添加安全提醒',
                  icon: CupertinoIcons.cloud_sun_fill,
                  iconColor: AppColors.statusPlanningText,
                  initiallyExpanded: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '安全备注功能开发中...',
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  ),
                ),
              ),

              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 格式化日期
  String _fmtDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
//  日期行：标签 + 日期值
// ---------------------------------------------------------------------------

class _DateRow extends StatelessWidget {
  final String label;
  final String value;

  const _DateRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBody,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
