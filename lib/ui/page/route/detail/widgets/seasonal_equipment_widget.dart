import 'package:flutter/cupertino.dart';

/// 当季出行装备推荐组件
class SeasonalEquipmentWidget extends StatelessWidget {
  /// 当前季节
  final String currentSeason;
  
  /// 路线难度
  final String difficulty;

  const SeasonalEquipmentWidget({
    super.key,
    required this.currentSeason,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final equipmentData = _getSeasonalEquipment();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                CupertinoIcons.bag,
                size: 20,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 8),
              Text(
                '$currentSeason装备推荐',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 装备分类
          ...equipmentData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildEquipmentCategory(entry.key, entry.value),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建装备分类
  Widget _buildEquipmentCategory(String category, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题
          Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 装备列表
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildEquipmentItem(item),
          )).toList(),
        ],
      ),
    );
  }

  /// 构建装备项
  Widget _buildEquipmentItem(Map<String, dynamic> item) {
    return Row(
      children: [
        // 图标
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item['icon'],
            size: 16,
            color: item['color'],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 装备信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                ),
              ),
              if (item['description'] != null) ...[
                const SizedBox(height: 2),
                Text(
                  item['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // 重要性标签
        if (item['importance'] == 'essential') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CupertinoColors.systemRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '必备',
              style: TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else if (item['importance'] == 'recommended') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CupertinoColors.systemOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '推荐',
              style: TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 获取当季装备数据
  Map<String, List<Map<String, dynamic>>> _getSeasonalEquipment() {
    switch (currentSeason) {
      case '春季':
        return _getSpringEquipment();
      case '夏季':
        return _getSummerEquipment();
      case '秋季':
        return _getAutumnEquipment();
      case '冬季':
        return _getWinterEquipment();
      default:
        return _getGeneralEquipment();
    }
  }

  /// 春季装备
  Map<String, List<Map<String, dynamic>>> _getSpringEquipment() {
    return {
      '服装装备': [
        {
          'name': '冲锋衣',
          'description': '防风防雨，应对春季多变天气',
          'icon': CupertinoIcons.cloud_rain,
          'color': CupertinoColors.systemBlue,
          'importance': 'essential',
        },
        {
          'name': '抓绒衣',
          'description': '保暖层，早晚温差大时使用',
          'icon': CupertinoIcons.thermometer,
          'color': CupertinoColors.systemOrange,
          'importance': 'recommended',
        },
        {
          'name': '速干衣裤',
          'description': '透气排汗，适合春季徒步',
          'icon': CupertinoIcons.t_bubble,
          'color': CupertinoColors.systemGreen,
          'importance': 'essential',
        },
      ],
      '鞋袜装备': [
        {
          'name': '徒步鞋',
          'description': '防滑耐磨，适合湿滑路面',
          'icon': CupertinoIcons.sportscourt,
          'color': CupertinoColors.systemBrown,
          'importance': 'essential',
        },
        {
          'name': '防水袜套',
          'description': '防止鞋袜进水',
          'icon': CupertinoIcons.drop,
          'color': CupertinoColors.systemTeal,
          'importance': 'recommended',
        },
      ],
      '安全装备': [
        {
          'name': '头灯',
          'description': '早出晚归必备',
          'icon': CupertinoIcons.lightbulb,
          'color': CupertinoColors.systemYellow,
          'importance': 'essential',
        },
        {
          'name': '雨具',
          'description': '春雨频繁，必备防雨装备',
          'icon': CupertinoIcons.umbrella,
          'color': CupertinoColors.systemBlue,
          'importance': 'essential',
        },
      ],
    };
  }

  /// 夏季装备
  Map<String, List<Map<String, dynamic>>> _getSummerEquipment() {
    return {
      '服装装备': [
        {
          'name': '速干T恤',
          'description': '透气排汗，防晒',
          'icon': CupertinoIcons.t_bubble,
          'color': CupertinoColors.systemGreen,
          'importance': 'essential',
        },
        {
          'name': '防晒衣',
          'description': '防紫外线，轻薄透气',
          'icon': CupertinoIcons.sun_max,
          'color': CupertinoColors.systemYellow,
          'importance': 'recommended',
        },
        {
          'name': '速干短裤',
          'description': '凉爽舒适',
          'icon': CupertinoIcons.rectangle_3_offgrid,
          'color': CupertinoColors.systemBlue,
          'importance': 'essential',
        },
      ],
      '防护装备': [
        {
          'name': '遮阳帽',
          'description': '防晒必备',
          'icon': CupertinoIcons.circle,
          'color': CupertinoColors.systemOrange,
          'importance': 'essential',
        },
        {
          'name': '防晒霜',
          'description': 'SPF50+，防水防汗',
          'icon': CupertinoIcons.drop_triangle,
          'color': CupertinoColors.systemPink,
          'importance': 'essential',
        },
        {
          'name': '太阳镜',
          'description': '保护眼睛',
          'icon': CupertinoIcons.eyeglasses,
          'color': CupertinoColors.systemIndigo,
          'importance': 'recommended',
        },
      ],
      '补给装备': [
        {
          'name': '大容量水袋',
          'description': '3L以上，充足补水',
          'icon': CupertinoIcons.drop_fill,
          'color': CupertinoColors.systemTeal,
          'importance': 'essential',
        },
        {
          'name': '电解质补充剂',
          'description': '防止脱水和电解质失衡',
          'icon': CupertinoIcons.plus_circle,
          'color': CupertinoColors.systemPurple,
          'importance': 'recommended',
        },
      ],
    };
  }

  /// 秋季装备
  Map<String, List<Map<String, dynamic>>> _getAutumnEquipment() {
    return {
      '保暖装备': [
        {
          'name': '三层穿衣系统',
          'description': '内层排汗+中层保暖+外层防护',
          'icon': CupertinoIcons.layers_alt,
          'color': CupertinoColors.systemOrange,
          'importance': 'essential',
        },
        {
          'name': '保暖帽',
          'description': '防止头部散热',
          'icon': CupertinoIcons.circle,
          'color': CupertinoColors.systemRed,
          'importance': 'recommended',
        },
        {
          'name': '手套',
          'description': '防风保暖',
          'icon': CupertinoIcons.hand_raised,
          'color': CupertinoColors.systemBrown,
          'importance': 'recommended',
        },
      ],
      '安全装备': [
        {
          'name': '头灯+备用电池',
          'description': '日照时间短，必备照明',
          'icon': CupertinoIcons.lightbulb,
          'color': CupertinoColors.systemYellow,
          'importance': 'essential',
        },
        {
          'name': '保温毯',
          'description': '紧急保暖',
          'icon': CupertinoIcons.rectangle_fill_badge_checkmark,
          'color': CupertinoColors.systemGreen,
          'importance': 'recommended',
        },
      ],
    };
  }

  /// 冬季装备
  Map<String, List<Map<String, dynamic>>> _getWinterEquipment() {
    return {
      '保暖装备': [
        {
          'name': '羽绒服',
          'description': '高保暖性，轻量化',
          'icon': CupertinoIcons.cloud_snow,
          'color': CupertinoColors.systemRed,
          'importance': 'essential',
        },
        {
          'name': '保暖内衣',
          'description': '美丽奴羊毛或合成材料',
          'icon': CupertinoIcons.t_bubble,
          'color': CupertinoColors.systemOrange,
          'importance': 'essential',
        },
        {
          'name': '防风面罩',
          'description': '保护面部',
          'icon': CupertinoIcons.person_crop_circle,
          'color': CupertinoColors.systemBlue,
          'importance': 'recommended',
        },
      ],
      '安全装备': [
        {
          'name': '冰爪',
          'description': '防滑必备',
          'icon': CupertinoIcons.gear,
          'color': CupertinoColors.systemGrey,
          'importance': 'essential',
        },
        {
          'name': '雪镜',
          'description': '防雪盲',
          'icon': CupertinoIcons.eyeglasses,
          'color': CupertinoColors.systemIndigo,
          'importance': 'essential',
        },
        {
          'name': '保温水壶',
          'description': '防止水结冰',
          'icon': CupertinoIcons.thermometer,
          'color': CupertinoColors.systemTeal,
          'importance': 'essential',
        },
      ],
    };
  }

  /// 通用装备
  Map<String, List<Map<String, dynamic>>> _getGeneralEquipment() {
    return {
      '基础装备': [
        {
          'name': '背包',
          'description': '根据行程选择合适容量',
          'icon': CupertinoIcons.bag,
          'color': CupertinoColors.systemBrown,
          'importance': 'essential',
        },
        {
          'name': '徒步鞋',
          'description': '舒适合脚，防滑耐磨',
          'icon': CupertinoIcons.sportscourt,
          'color': CupertinoColors.systemGreen,
          'importance': 'essential',
        },
      ],
    };
  }
}