import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/trip/widget/cards/trip_card_template.dart';
import 'package:walk/ui/page/trip/widget/trip_transportation_widget.dart';
import 'package:walk/model/trip/transportation_info_model.dart';

/// 行程交通卡片组件
///
/// 用于显示行程的交通安排，包括去程和返程
class TripTransportationCardWidget extends StatefulWidget {
  /// 交通信息列表
  final List<TransportationInfoModel> transportations;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 当前正在编辑的部分ID
  final String? editingSectionId;

  /// 编辑按钮点击回调
  final Function(String) onEdit;

  /// 保存按钮点击回调
  final Function(String) onSave;

  /// 构造函数
  const TripTransportationCardWidget({
    Key? key,
    required this.transportations,
    required this.isEditMode,
    required this.editingSectionId,
    required this.onEdit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TripTransportationCardWidget> createState() =>
      _TripTransportationCardWidgetState();
}

class _TripTransportationCardWidgetState
    extends State<TripTransportationCardWidget> {
  /// 当前方向（去程/返程）
  bool _isOutbound = true;

  @override
  Widget build(BuildContext context) {
    // 根据当前方向筛选交通信息
    final filteredTransportations = widget.transportations
        .where((t) => _isOutbound ? t.type == '去程' : t.type == '返程')
        .toList();

    // 检查是否有未预订的交通
    final hasUnbookedTransportation =
        widget.transportations.any((t) => !t.isBooked);

    // 创建编辑按钮
    final editButton = widget.isEditMode &&
            widget.editingSectionId != 'transportation'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '编辑',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => widget.onEdit('transportation'),
          )
        : null;

    // 创建保存按钮
    final saveButton = widget.isEditMode &&
            widget.editingSectionId == 'transportation'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => widget.onSave('transportation'),
          )
        : null;

    return Column(
      children: [
        // 方向切换按钮
        Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey5.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOutbound = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          _isOutbound ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: _isOutbound
                              ? CupertinoColors.white
                              : CupertinoColors.systemGrey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '去程',
                          style: TextStyle(
                            color: _isOutbound
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOutbound = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          !_isOutbound ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_left_circle_fill,
                          color: !_isOutbound
                              ? CupertinoColors.white
                              : CupertinoColors.systemGrey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '返程',
                          style: TextStyle(
                            color: !_isOutbound
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 交通信息卡片
        TripCardTemplate(
          title: _isOutbound ? '去程交通' : '返程交通',
          icon: _isOutbound
              ? CupertinoIcons.arrow_right_circle_fill
              : CupertinoIcons.arrow_left_circle_fill,
          usePrimaryHeader: true,
          actionButton: widget.isEditMode
              ? (widget.editingSectionId == 'transportation'
                  ? saveButton
                  : editButton)
              : null,
          content:
              widget.isEditMode && widget.editingSectionId == 'transportation'
                  ? Column(
                      children: [
                        TripTransportationWidget(
                          transportations: filteredTransportations,
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.add,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '添加交通方案',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            // TODO: 显示添加交通方案对话框
                          },
                        ),
                      ],
                    )
                  : TripTransportationWidget(
                      transportations: filteredTransportations,
                    ),
          warningText: hasUnbookedTransportation ? '您有未预订的交通，建议尽快完成预订' : null,
          buttonText: widget.isEditMode ? null : '预订交通',
          onButtonPressed: widget.isEditMode
              ? null
              : () {
                  // TODO: 跳转到预订页面
                },
        ),

        // 预订状态卡片
        if (!widget.isEditMode) ...[
          const SizedBox(height: 16),
          _buildBookingStatusCard(widget.transportations),
        ],
      ],
    );
  }

  /// 构建预订状态卡片
  Widget _buildBookingStatusCard(
      List<TransportationInfoModel> transportations) {
    final isBooked = transportations.every((t) => t.isBooked);

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBooked
                  ? CupertinoColors.activeGreen.withOpacity(0.1)
                  : CupertinoColors.systemYellow.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isBooked
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.exclamationmark_circle_fill,
                  color: isBooked
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '预订状态',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isBooked
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.systemYellow,
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBooked ? '所有交通已预订完成' : '还有未预订的交通项目',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBooked ? '您的行程交通已全部预订，请按时出行。' : '建议尽快完成交通预订，以免影响您的行程。',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (!isBooked) ...[
                  const SizedBox(height: 16),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '前往预订',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () {
                      // TODO: 跳转到预订页面
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
