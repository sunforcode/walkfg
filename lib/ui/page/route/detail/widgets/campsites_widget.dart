import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/campsite_model.dart';

/// 营地资源Widget
class CampsitesWidget extends StatefulWidget {
  final List<CampsiteModel> campsites;

  const CampsitesWidget({
    super.key,
    required this.campsites,
  });

  @override
  State<CampsitesWidget> createState() => _CampsitesWidgetState();
}

class _CampsitesWidgetState extends State<CampsitesWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.campsites.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCampsites = _showAll
        ? widget.campsites
        : widget.campsites.take(_maxDisplayCount).toList();
    final hasMore = widget.campsites.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.house,
                size: 20,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                '营地资源',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.campsites.length}个',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 营地列表
          ...displayCampsites.map((campsite) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCampsiteCard(campsite),
            );
          }).toList(),

          // 更多按钮
          if (hasMore && !_showAll)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _showAll = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '查看更多营地',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.campsites.length - _maxDisplayCount}个)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: CupertinoColors.systemGreen,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建营地卡片
  Widget _buildCampsiteCard(CampsiteModel campsite) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(
                campsite.campsiteTypeIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  campsite.name ?? '未命名营地',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),

          if (campsite.description != null) ...[
            const SizedBox(height: 8),
            Text(
              campsite.description!,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 位置和海拔信息
          Row(
            children: [
              const Icon(
                CupertinoIcons.location,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${campsite.latitude.toStringAsFixed(4)}, ${campsite.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const Spacer(),
              const Icon(
                CupertinoIcons.arrow_up,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '海拔${campsite.elevation.toInt()}m',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 营地特性
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.house,
                    size: 14,
                    color: CupertinoColors.systemGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    campsite.campsiteTypeText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.person_2,
                    size: 14,
                    color: CupertinoColors.systemPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    campsite.capacityText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (campsite.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.info_circle,
                    size: 14,
                    color: CupertinoColors.systemYellow,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      campsite.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建特性标签
  Widget _buildFeatureTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFacilityColor(CampsiteFacility facility) {
    switch (facility) {
      case CampsiteFacility.excellent:
        return CupertinoColors.systemGreen;
      case CampsiteFacility.good:
        return CupertinoColors.systemBlue;
      case CampsiteFacility.fair:
        return CupertinoColors.systemOrange;
      case CampsiteFacility.none:
        return CupertinoColors.systemRed;
      case CampsiteFacility.unknown:
        return CupertinoColors.systemGrey;
    }
  }
}
