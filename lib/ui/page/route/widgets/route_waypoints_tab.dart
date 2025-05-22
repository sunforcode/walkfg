import 'package:flutter/cupertino.dart';
import '../../../../model/model/route/route_model.dart';

/// 路线关键点标签页
class RouteWaypointsTab extends StatefulWidget {
  /// 路线数据
  final RouteModel route;
  
  /// 关键点数据Future
  final Future<Map<String, dynamic>> waypointsFuture;

  /// 构造函数
  const RouteWaypointsTab({
    super.key,
    required this.route,
    required this.waypointsFuture,
  });

  @override
  State<RouteWaypointsTab> createState() => _RouteWaypointsTabState();
}

class _RouteWaypointsTabState extends State<RouteWaypointsTab> {
  /// 当前选中的关键点类型
  String _selectedType = '全部';
  
  /// 关键点类型列表
  final List<String> _waypointTypes = ['全部', '营地', '补给', '景点', '危险'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 类型筛选器
        _buildTypeFilter(),
        
        // 关键点列表
        Expanded(
          child: _buildWaypointsList(),
        ),
      ],
    );
  }

  /// 构建类型筛选器
  Widget _buildTypeFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _waypointTypes.length,
        itemBuilder: (context, index) {
          final type = _waypointTypes[index];
          final isSelected = type == _selectedType;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(20),
              minSize: 30,
              onPressed: () {
                setState(() {
                  _selectedType = type;
                });
              },
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建关键点列表
  Widget _buildWaypointsList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.waypointsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('暂无关键点数据'),
          );
        }
        
        final waypoints = snapshot.data!['waypoints'] as List<dynamic>;
        
        // 根据选中的类型筛选关键点
        final filteredWaypoints = _selectedType == '全部'
            ? waypoints
            : waypoints.where((w) => _matchesType(w['type'], _selectedType)).toList();
        
        if (filteredWaypoints.isEmpty) {
          return Center(
            child: Text('暂无${_selectedType}类型的关键点'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredWaypoints.length,
          itemBuilder: (context, index) {
            final waypoint = filteredWaypoints[index];
            return _buildWaypointCard(waypoint);
          },
        );
      },
    );
  }

  /// 构建关键点卡片
  Widget _buildWaypointCard(Map<String, dynamic> waypoint) {
    final IconData icon = _getWaypointIcon(waypoint['type']);
    final Color color = _getWaypointColor(waypoint['type']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
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
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    waypoint['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 基本信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoItem('海拔', '${waypoint['coordinates']['altitude']}m'),
                    const SizedBox(width: 16),
                    _buildInfoItem('距起点', '${waypoint['distanceFromStart'] ?? 0}km'),
                  ],
                ),
                if (waypoint['facilities'] != null && (waypoint['facilities'] as List).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoItem('设施', _buildFacilitiesList(waypoint['facilities'] as List)),
                ],
                if (waypoint['description'] != null && waypoint['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    waypoint['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
                
                // 操作按钮
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('查看详情'),
                      onPressed: () {
                        _showWaypointDetail(waypoint);
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('在地图上显示'),
                      onPressed: () {
                        // 在地图上显示关键点
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, dynamic content) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          content is Widget ? content : Text(
            content.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设施列表
  Widget _buildFacilitiesList(List facilities) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: facilities.map((facility) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            facility.toString(),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 显示关键点详情
  void _showWaypointDetail(Map<String, dynamic> waypoint) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getWaypointColor(waypoint['type']).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getWaypointIcon(waypoint['type']),
                        color: _getWaypointColor(waypoint['type']),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        waypoint['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getWaypointColor(waypoint['type']),
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.xmark_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // 详情内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('类型', _getWaypointTypeName(waypoint['type'])),
                          const SizedBox(height: 8),
                          _buildDetailRow('海拔', '${waypoint['coordinates']['altitude']}m'),
                          const SizedBox(height: 8),
                          _buildDetailRow('经度', '${waypoint['coordinates']['longitude']}'),
                          const SizedBox(height: 8),
                          _buildDetailRow('纬度', '${waypoint['coordinates']['latitude']}'),
                          const SizedBox(height: 8),
                          _buildDetailRow('距起点', '${waypoint['distanceFromStart'] ?? 0}km'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 描述
                    if (waypoint['description'] != null && waypoint['description'].toString().isNotEmpty) ...[
                      const Text(
                        '描述',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        waypoint['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 设施
                    if (waypoint['facilities'] != null && (waypoint['facilities'] as List).isNotEmpty) ...[
                      const Text(
                        '设施',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFacilitiesList(waypoint['facilities'] as List),
                      const SizedBox(height: 16),
                    ],
                    
                    // 提示
                    if (waypoint['tips'] != null && waypoint['tips'].toString().isNotEmpty) ...[
                      const Text(
                        '提示',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: CupertinoColors.systemYellow.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.info_circle,
                              color: CupertinoColors.systemYellow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                waypoint['tips'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 最佳游览时间
                    if (waypoint['bestTimeToVisit'] != null && waypoint['bestTimeToVisit'].toString().isNotEmpty) ...[
                      _buildDetailRow('最佳游览时间', waypoint['bestTimeToVisit']),
                      const SizedBox(height: 8),
                    ],
                    
                    // 预计停留时间
                    if (waypoint['estimatedStayTime'] != null) ...[
                      _buildDetailRow('预计停留时间', '${waypoint['estimatedStayTime']}分钟'),
                      const SizedBox(height: 16),
                    ],
                    
                    // 图片
                    if (waypoint['images'] != null && (waypoint['images'] as List).isNotEmpty) ...[
                      const Text(
                        '图片',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (waypoint['images'] as List).length,
                          itemBuilder: (context, index) {
                            final imageUrl = (waypoint['images'] as List)[index];
                            return Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                    child: const Text('在地图上显示'),
                    onPressed: () {
                      Navigator.pop(context);
                      // 在地图上显示关键点
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 判断关键点类型是否匹配
  bool _matchesType(String waypointType, String filterType) {
    switch (filterType.toLowerCase()) {
      case '营地':
        return waypointType.toLowerCase() == 'campsite';
      case '补给':
        return waypointType.toLowerCase() == 'water' || waypointType.toLowerCase() == 'shop';
      case '景点':
        return waypointType.toLowerCase() == 'viewpoint';
      case '危险':
        return waypointType.toLowerCase() == 'danger';
      default:
        return true;
    }
  }

  /// 获取关键点图标
  IconData _getWaypointIcon(String type) {
    switch (type.toLowerCase()) {
      case 'campsite':
        return CupertinoIcons.ant_fill;
      case 'water':
        return CupertinoIcons.drop_fill;
      case 'viewpoint':
        return CupertinoIcons.photo_fill;
      case 'danger':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'start':
        return CupertinoIcons.flag_fill;
      case 'end':
        return CupertinoIcons.flag_slash_fill;
      case 'rest':
        return CupertinoIcons.bed_double_fill;
      case 'shop':
        return CupertinoIcons.cart_fill;
      default:
        return CupertinoIcons.location_fill;
    }
  }

  /// 获取关键点颜色
  Color _getWaypointColor(String type) {
    switch (type.toLowerCase()) {
      case 'campsite':
        return CupertinoColors.systemGreen;
      case 'water':
        return CupertinoColors.systemBlue;
      case 'viewpoint':
        return CupertinoColors.systemIndigo;
      case 'danger':
        return CupertinoColors.systemRed;
      case 'start':
        return CupertinoColors.systemTeal;
      case 'end':
        return CupertinoColors.systemPurple;
      case 'rest':
        return CupertinoColors.systemOrange;
      case 'shop':
        return CupertinoColors.activeBlue;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  /// 获取关键点类型名称
  String _getWaypointTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'campsite':
        return '营地';
      case 'water':
        return '水源';
      case 'viewpoint':
        return '景点';
      case 'danger':
        return '危险点';
      case 'start':
        return '起点';
      case 'end':
        return '终点';
      case 'rest':
        return '休息点';
      case 'shop':
        return '补给点';
      default:
        return '其他';
    }
  }
}