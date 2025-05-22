import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';

/// 路线装备标签页
class RouteGearTab extends StatefulWidget {
  /// 路线数据
  final RouteModel route;
  
  /// 装备推荐数据Future
  final Future<Map<String, dynamic>> gearRecommendationsFuture;
  
  /// 用户装备数据Future
  final Future<Map<String, dynamic>> userGearFuture;

  /// 构造函数
  const RouteGearTab({
    super.key,
    required this.route,
    required this.gearRecommendationsFuture,
    required this.userGearFuture,
  });

  @override
  State<RouteGearTab> createState() => _RouteGearTabState();
}

class _RouteGearTabState extends State<RouteGearTab> {
  /// 当前选中的季节
  String _selectedSeason = '春季';
  
  /// 季节列表
  final List<String> _seasons = ['春季', '夏季', '秋季', '冬季'];
  
  /// 是否显示个人模式
  bool _isPersonalMode = true;
  
  /// 是否展开推荐装备
  bool _isRecommendedExpanded = false;
  
  /// 是否展开可选装备
  bool _isOptionalExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 季节选择器
        _buildSeasonSelector(),
        
        // 模式切换
        _buildModeToggle(),
        
        // 装备列表
        Expanded(
          child: _buildGearList(),
        ),
      ],
    );
  }

  /// 构建季节选择器
  Widget _buildSeasonSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _seasons.length,
        itemBuilder: (context, index) {
          final season = _seasons[index];
          final isSelected = season == _selectedSeason;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(20),
              minSize: 30,
              onPressed: () {
                setState(() {
                  _selectedSeason = season;
                });
              },
              child: Text(
                season,
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

  /// 构建模式切换
  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _isPersonalMode = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isPersonalMode ? CupertinoColors.activeBlue : CupertinoColors.white,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                border: Border.all(
                  color: _isPersonalMode ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
                ),
              ),
              child: Text(
                '个人模式',
                style: TextStyle(
                  fontSize: 14,
                  color: _isPersonalMode ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _isPersonalMode = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !_isPersonalMode ? CupertinoColors.activeBlue : CupertinoColors.white,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                border: Border.all(
                  color: !_isPersonalMode ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
                ),
              ),
              child: Text(
                '团队模式',
                style: TextStyle(
                  fontSize: 14,
                  color: !_isPersonalMode ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建装备列表
  Widget _buildGearList() {
    return FutureBuilder<List<Object>>(
      future: Future.wait([
        widget.gearRecommendationsFuture,
        widget.userGearFuture,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('暂无装备推荐数据'),
          );
        }
        
        final gearRecommendations = snapshot.data![0] as Map<String, dynamic>;
        final userGear = snapshot.data![1] as Map<String, dynamic>;
        
        // 获取当前季节的装备
        final seasonKey = _getSeasonKey(_selectedSeason);
        final seasonalGear = gearRecommendations['seasonalGear'][seasonKey] as List<dynamic>? ?? [];
        
        // 获取必备装备
        final essentialGear = gearRecommendations['essentialGear'] as List<dynamic>? ?? [];
        
        // 获取推荐装备
        final recommendedGear = gearRecommendations['optionalGear'] as List<dynamic>? ?? [];
        
        // 获取特殊装备
        final specializedGear = gearRecommendations['specializedGear'] as List<dynamic>? ?? [];
        
        // 合并必备装备和当前季节装备
        final List<dynamic> combinedEssentialGear = [...essentialGear, ...seasonalGear];
        
        // 用户装备
        final userGears = userGear['gears'] as List<dynamic>? ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 必备装备
              Text(
                '必备装备 (${combinedEssentialGear.length}项)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...combinedEssentialGear.map((gear) => _buildGearItem(gear, userGears, true)).toList(),
              
              const SizedBox(height: 16),
              
              // 推荐装备
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isRecommendedExpanded = !_isRecommendedExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      '推荐装备 (${recommendedGear.length}项)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isRecommendedExpanded 
                          ? CupertinoIcons.chevron_down
                          : CupertinoIcons.chevron_right,
                      size: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              if (_isRecommendedExpanded) ...[
                const SizedBox(height: 8),
                ...recommendedGear.map((gear) => _buildGearItem(gear, userGears, false)).toList(),
              ],
              
              const SizedBox(height: 16),
              
              // 可选装备
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isOptionalExpanded = !_isOptionalExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      '可选装备 (${specializedGear.length}项)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isOptionalExpanded 
                          ? CupertinoIcons.chevron_down
                          : CupertinoIcons.chevron_right,
                      size: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              if (_isOptionalExpanded) ...[
                const SizedBox(height: 8),
                ...specializedGear.map((gear) => _buildGearItem(gear, userGears, false)).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 构建装备项
  Widget _buildGearItem(Map<String, dynamic> gear, List<dynamic> userGears, bool isEssential) {
    // 查找用户是否有匹配的装备
    final matchingGear = _findMatchingUserGear(gear, userGears);
    final hasMatchingGear = matchingGear != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isEssential)
                const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: CupertinoColors.systemOrange,
                  size: 16,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  gear['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (hasMatchingGear) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '您的装备: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${matchingGear['brand']} ${matchingGear['model']}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  '状态: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Text(
                  matchingGear['condition'],
                  style: TextStyle(
                    fontSize: 14,
                    color: _getConditionColor(matchingGear['condition']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.check_mark_circled,
                  size: 16,
                  color: _getConditionColor(matchingGear['condition']),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Text(
                  '您的装备: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Text(
                  '无匹配装备',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '建议: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(16),
                  minSize: 0,
                  child: const Text(
                    '购买或租赁',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    // 显示购买或租赁选项
                    _showPurchaseOptions(gear);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 显示购买或租赁选项
  void _showPurchaseOptions(Map<String, dynamic> gear) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('${gear['name']} 获取选项'),
        message: const Text('您可以选择以下方式获取此装备'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 导航到购买页面
            },
            child: const Text('购买新品'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // 导航到租赁页面
            },
            child: const Text('租赁装备'),
          ),
          if (gear['sharable'] == true)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // 导航到共享页面
              },
              child: const Text('查找共享'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 获取季节键名
  String _getSeasonKey(String season) {
    switch (season) {
      case '春季':
        return 'spring';
      case '夏季':
        return 'summer';
      case '秋季':
        return 'autumn';
      case '冬季':
        return 'winter';
      default:
        return 'spring';
    }
  }

  /// 查找匹配的用户装备
  Map<String, dynamic>? _findMatchingUserGear(Map<String, dynamic> gear, List<dynamic> userGears) {
    for (final userGear in userGears) {
      if (userGear['category'] == gear['category'] && userGear['name'] == gear['name']) {
        return userGear;
      }
    }
    return null;
  }

  /// 获取装备状态对应的颜色
  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'excellent':
      case '优秀':
        return CupertinoColors.systemGreen;
      case 'good':
      case '良好':
        return CupertinoColors.activeBlue;
      case 'fair':
      case '一般':
        return CupertinoColors.systemOrange;
      case 'poor':
      case '较差':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}