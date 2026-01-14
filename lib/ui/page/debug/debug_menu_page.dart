import 'package:flutter/cupertino.dart';
import '../../map/examples/opensource_map_test_page.dart';

/// 调试菜单页面
class DebugMenuPage extends StatelessWidget {
  const DebugMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('调试菜单'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 地图测试区域
            _buildSection(
              context,
              '地图测试',
              [
                _buildDebugItem(
                  context,
                  icon: CupertinoIcons.map_fill,
                  title: '开源3D地图测试',
                  subtitle: '测试基于MapLibre GL的开源3D地图功能',
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const OpenSourceMapTestPage(),
                      ),
                    );
                  },
                ),
                _buildDebugItem(
                  context,
                  icon: CupertinoIcons.cube_box,
                  title: '3D地图组件测试',
                  subtitle: '测试3D地图组件的各种配置和功能',
                  onTap: () {
                    _showToast(context, '3D地图组件测试功能开发中...');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 数据源信息
            _buildSection(
              context,
              '数据源信息',
              [
                _buildInfoItem('标准地图', 'OpenStreetMap (开源)'),
                _buildInfoItem('卫星图像', 'Esri World Imagery (免费)'),
                _buildInfoItem('地形数据', 'Wikimedia Labs (开源)'),
                _buildInfoItem('3D引擎', 'MapLibre GL (开源)'),
              ],
            ),

            const SizedBox(height: 24),

            // 功能状态
            _buildSection(
              context,
              '功能状态',
              [
                _buildStatusItem('3D地图渲染', true),
                _buildStatusItem('轨迹显示', true),
                _buildStatusItem('地形效果', true),
                _buildStatusItem('3D建筑', false, note: '需要数据支持'),
                _buildStatusItem('交互控制', true),
              ],
            ),

            const SizedBox(height: 24),

            // 快速操作
            _buildSection(
              context,
              '快速操作',
              [
                _buildActionButton(
                  context,
                  '测试地图加载',
                  CupertinoIcons.arrow_clockwise,
                  () {
                    _showToast(context, '正在测试地图加载...');
                  },
                ),
                _buildActionButton(
                  context,
                  '清除地图缓存',
                  CupertinoIcons.trash,
                  () {
                    _showConfirmDialog(
                      context,
                      '清除缓存',
                      '确定要清除地图缓存吗？',
                      () {
                        _showToast(context, '地图缓存已清除');
                      },
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  '重置地图设置',
                  CupertinoIcons.refresh,
                  () {
                    _showConfirmDialog(
                      context,
                      '重置设置',
                      '确定要重置所有地图设置吗？',
                      () {
                        _showToast(context, '地图设置已重置');
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建区域
  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建调试项目
  Widget _buildDebugItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息项目
  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.label,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态项目
  Widget _buildStatusItem(String label, bool isEnabled, {String? note}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.xmark_circle,
            color: isEnabled
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示提示
  void _showToast(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 显示确认对话框
  void _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('确定'),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
