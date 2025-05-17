import 'package:flutter/cupertino.dart';

/// iOS风格的装备列表页面
class EquipmentListScreen extends StatefulWidget {
  /// 构造函数
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  bool _isLoading = true;
  String? _error;
  final List<Map<String, dynamic>> _equipmentLists = [];

  @override
  void initState() {
    super.initState();
    _loadEquipmentLists();
  }

  /// 加载装备清单列表
  Future<void> _loadEquipmentLists() async {
    // 模拟加载数据
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        // 添加一些模拟数据
        _equipmentLists.addAll([
          {
            'id': '1',
            'name': '春季徒步基础装备',
            'description': '适合春季短途徒步的基础装备清单',
            'itemCount': 15,
            'createdAt': DateTime.now().subtract(const Duration(days: 30)),
            'isDefault': true,
            'category': '短途徒步',
          },
          {
            'id': '2',
            'name': '高山露营装备',
            'description': '高海拔露营必备装备清单',
            'itemCount': 25,
            'createdAt': DateTime.now().subtract(const Duration(days: 60)),
            'isDefault': false,
            'category': '露营',
          },
          {
            'id': '3',
            'name': '雨季徒步装备',
            'description': '雨季徒步防水装备清单',
            'itemCount': 18,
            'createdAt': DateTime.now().subtract(const Duration(days: 15)),
            'isDefault': false,
            'category': '雨季徒步',
          },
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('装备清单'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search),
              onPressed: () {
                // 搜索功能
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('提示'),
                    content: const Text('搜索功能尚未实现'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('确定'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.slider_horizontal_3),
              onPressed: () {
                // 筛选功能
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('提示'),
                    content: const Text('筛选功能尚未实现'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('确定'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 50,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('重试'),
              onPressed: _loadEquipmentLists,
            ),
          ],
        ),
      );
    }

    if (_equipmentLists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.bag,
              size: 50,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无装备清单',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            const Text('点击右下角的按钮创建装备清单'),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('创建装备清单'),
              onPressed: () {
                // 创建装备清单
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('提示'),
                    content: const Text('创建装备清单功能尚未实现'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('确定'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _equipmentLists.length,
      itemBuilder: (context, index) {
        final equipmentList = _equipmentLists[index];
        return _buildEquipmentListCard(equipmentList);
      },
    );
  }

  Widget _buildEquipmentListCard(Map<String, dynamic> equipmentList) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // 查看装备清单详情
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('提示'),
              content: Text('查看装备清单：${equipmentList['name']}'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('确定'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和类别
              Row(
                children: [
                  Expanded(
                    child: Text(
                      equipmentList['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      equipmentList['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 描述
              Text(
                equipmentList['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 底部信息
              Row(
                children: [
                  // 物品数量
                  _buildInfoChip(
                    CupertinoIcons.list_bullet,
                    '${equipmentList['itemCount']}个物品',
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 创建时间
                  _buildInfoChip(
                    CupertinoIcons.time,
                    _getTimeAgo(equipmentList['createdAt']),
                  ),
                  
                  const Spacer(),
                  
                  // 默认标记
                  if (equipmentList['isDefault'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_circle,
                            size: 12,
                            color: CupertinoColors.systemGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '默认',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}