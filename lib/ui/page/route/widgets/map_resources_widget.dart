import 'package:flutter/cupertino.dart';

/// 地图水源补给点详解组件
class MapResourcesWidget extends StatelessWidget {
  /// 水源点列表
  final List<Map<String, dynamic>> waterSources;
  
  /// 补给点列表
  final List<Map<String, dynamic>> supplyPoints;

  const MapResourcesWidget({
    super.key,
    required this.waterSources,
    required this.supplyPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                CupertinoIcons.map,
                size: 20,
                color: CupertinoColors.systemTeal,
              ),
              const SizedBox(width: 8),
              const Text(
                '地图资源详解',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 水源点详解
          if (waterSources.isNotEmpty) ...[
            _buildResourceSection(
              title: '水源点详解',
              icon: CupertinoIcons.drop_fill,
              color: CupertinoColors.systemTeal,
              resources: waterSources,
              resourceType: 'water',
            ),
            const SizedBox(height: 16),
          ],
          
          // 补给点详解
          if (supplyPoints.isNotEmpty) ...[
            _buildResourceSection(
              title: '补给点详解',
              icon: CupertinoIcons.bag_fill,
              color: CupertinoColors.systemOrange,
              resources: supplyPoints,
              resourceType: 'supply',
            ),
          ],
        ],
      ),
    );
  }

  /// 构建资源区域
  Widget _buildResourceSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> resources,
    required String resourceType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区域标题
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${resources.length}个',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 资源列表
          ...resources.asMap().entries.map((entry) {
            final index = entry.key;
            final resource = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < resources.length - 1 ? 12 : 0),
              child: _buildResourceItem(resource, resourceType, color),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建资源项
  Widget _buildResourceItem(Map<String, dynamic> resource, String resourceType, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 资源名称和距离
          Row(
            children: [
              Expanded(
                child: Text(
                  resource['name'] ?? '未知资源点',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              if (resource['distance'] != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${resource['distance']}km',
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 资源详细信息
          if (resourceType == 'water') ...[
            _buildWaterSourceDetails(resource),
          ] else if (resourceType == 'supply') ...[
            _buildSupplyPointDetails(resource),
          ],
          
          // 位置信息
          if (resource['location'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  CupertinoIcons.location,
                  size: 12,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    resource['location'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // 注意事项
          if (resource['notes'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    size: 12,
                    color: CupertinoColors.systemYellow,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      resource['notes'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.systemGrey,
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

  /// 构建水源详细信息
  Widget _buildWaterSourceDetails(Map<String, dynamic> waterSource) {
    return Column(
      children: [
        // 水质和可用性
        Row(
          children: [
            // 水质
            if (waterSource['quality'] != null) ...[
              _buildDetailChip(
                icon: CupertinoIcons.drop,
                label: '水质',
                value: waterSource['quality'],
                color: _getWaterQualityColor(waterSource['quality']),
              ),
              const SizedBox(width: 8),
            ],
            
            // 可用性
            if (waterSource['availability'] != null) ...[
              _buildDetailChip(
                icon: CupertinoIcons.clock,
                label: '可用性',
                value: waterSource['availability'],
                color: _getAvailabilityColor(waterSource['availability']),
              ),
            ],
          ],
        ),
        
        // 处理建议
        if (waterSource['treatment'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.gear,
                size: 12,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 4),
              const Text(
                '处理建议：',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: Text(
                  waterSource['treatment'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 构建补给点详细信息
  Widget _buildSupplyPointDetails(Map<String, dynamic> supplyPoint) {
    return Column(
      children: [
        // 补给类型和营业时间
        Row(
          children: [
            // 补给类型
            if (supplyPoint['type'] != null) ...[
              _buildDetailChip(
                icon: CupertinoIcons.bag,
                label: '类型',
                value: supplyPoint['type'],
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 8),
            ],
            
            // 营业状态
            if (supplyPoint['status'] != null) ...[
              _buildDetailChip(
                icon: CupertinoIcons.time,
                label: '状态',
                value: supplyPoint['status'],
                color: _getSupplyStatusColor(supplyPoint['status']),
              ),
            ],
          ],
        ),
        
        // 可购买物品
        if (supplyPoint['items'] != null && supplyPoint['items'].isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.cart,
                size: 12,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 4),
              const Text(
                '可购买：',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: Text(
                  (supplyPoint['items'] as List).join('、'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),
        ],
        
        // 营业时间
        if (supplyPoint['hours'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 12,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 4),
              const Text(
                '营业时间：',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: Text(
                  supplyPoint['hours'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 构建详细信息标签
  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取水质颜色
  Color _getWaterQualityColor(String quality) {
    switch (quality) {
      case '优':
        return CupertinoColors.systemGreen;
      case '良':
        return CupertinoColors.systemBlue;
      case '一般':
        return CupertinoColors.systemYellow;
      case '差':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  /// 获取可用性颜色
  Color _getAvailabilityColor(String availability) {
    switch (availability) {
      case '全年':
        return CupertinoColors.systemGreen;
      case '季节性':
        return CupertinoColors.systemOrange;
      case '不确定':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  /// 获取补给点状态颜色
  Color _getSupplyStatusColor(String status) {
    switch (status) {
      case '营业':
        return CupertinoColors.systemGreen;
      case '季节性营业':
        return CupertinoColors.systemOrange;
      case '暂停营业':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}