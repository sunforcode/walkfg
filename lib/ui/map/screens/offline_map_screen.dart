import 'dart:math';
import 'package:flutter/material.dart';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'package:walk/ui/map/providers/flutter_map/flutter_map_provider.dart';
import 'package:walk/ui/map/providers/flutter_map/cached_tile_provider.dart';

/// 离线地图管理页面
class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapProvider _mapProvider = FlutterMapProvider();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  // 下载区域参数
  final _minZoomController = TextEditingController(text: '10');
  final _maxZoomController = TextEditingController(text: '15');
  final _northController = TextEditingController();
  final _southController = TextEditingController();
  final _eastController = TextEditingController();
  final _westController = TextEditingController();

  @override
  void dispose() {
    _minZoomController.dispose();
    _maxZoomController.dispose();
    _northController.dispose();
    _southController.dispose();
    _eastController.dispose();
    _westController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('离线地图管理'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              '下载离线地图',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 区域设置
            const Text(
              '区域边界',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 北纬
            TextField(
              controller: _northController,
              decoration: const InputDecoration(
                labelText: '北纬',
                hintText: '例如: 40.0',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),

            // 南纬
            TextField(
              controller: _southController,
              decoration: const InputDecoration(
                labelText: '南纬',
                hintText: '例如: 39.0',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),

            // 东经
            TextField(
              controller: _eastController,
              decoration: const InputDecoration(
                labelText: '东经',
                hintText: '例如: 117.0',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),

            // 西经
            TextField(
              controller: _westController,
              decoration: const InputDecoration(
                labelText: '西经',
                hintText: '例如: 116.0',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // 缩放级别设置
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minZoomController,
                    decoration: const InputDecoration(
                      labelText: '最小缩放级别',
                      hintText: '10-18',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxZoomController,
                    decoration: const InputDecoration(
                      labelText: '最大缩放级别',
                      hintText: '10-18',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 下载按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDownloading ? null : _downloadOfflineMap,
                child: const Text('开始下载'),
              ),
            ),
            const SizedBox(height: 16),

            // 下载进度
            if (_isDownloading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('下载进度:'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 8),
                  Text('${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                ],
              ),

            const SizedBox(height: 32),

            // 清除缓存按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearCache,
                child: const Text('清除所有离线地图缓存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 下载离线地图
  Future<void> _downloadOfflineMap() async {
    // 验证输入
    if (_northController.text.isEmpty ||
        _southController.text.isEmpty ||
        _eastController.text.isEmpty ||
        _westController.text.isEmpty) {
      _showErrorDialog('请输入完整的区域边界');
      return;
    }

    try {
      final north = double.parse(_northController.text);
      final south = double.parse(_southController.text);
      final east = double.parse(_eastController.text);
      final west = double.parse(_westController.text);
      final minZoom = int.parse(_minZoomController.text);
      final maxZoom = int.parse(_maxZoomController.text);

      if (north <= south) {
        _showErrorDialog('北纬必须大于南纬');
        return;
      }

      if (east <= west) {
        _showErrorDialog('东经必须大于西经');
        return;
      }

      if (minZoom < 1 ||
          minZoom > 18 ||
          maxZoom < 1 ||
          maxZoom > 18 ||
          minZoom > maxZoom) {
        _showErrorDialog('缩放级别必须在1-18之间，且最小缩放级别不能大于最大缩放级别');
        return;
      }

      // 计算瓦片数量
      final tileCount =
          _estimateTileCount(north, south, east, west, minZoom, maxZoom);

      // 确认下载
      final confirmed = await _showConfirmDialog(
        '预计需要下载 $tileCount 个瓦片，确定继续吗？',
      );

      if (!confirmed) return;

      // 开始下载
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      final bounds = MapBoundsVO(
        north: north,
        south: south,
        east: east,
        west: west,
      );

      await _mapProvider.downloadOfflineMap(
        bounds,
        minZoom,
        maxZoom,
        (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('离线地图下载完成')),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      _showErrorDialog('下载失败: $e');
    }
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    final confirmed = await _showConfirmDialog(
      '确定要清除所有离线地图缓存吗？',
    );

    if (!confirmed) return;

    try {
      // 获取CachedTileProvider实例
      final provider = _mapProvider as FlutterMapProvider;
      final tileProvider = CachedTileProvider();
      await tileProvider.clearCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('缓存已清除')),
        );
      }
    } catch (e) {
      _showErrorDialog('清除缓存失败: $e');
    }
  }

  /// 显示错误对话框
  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示确认对话框
  Future<bool> _showConfirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 估算瓦片数量
  int _estimateTileCount(
    double north,
    double south,
    double east,
    double west,
    int minZoom,
    int maxZoom,
  ) {
    int count = 0;

    for (int z = minZoom; z <= maxZoom; z++) {
      final tilesPerDegree = pow(2, z) / 360.0;

      final xTiles = ((east - west) * tilesPerDegree).ceil();
      final yTiles = ((north - south) * tilesPerDegree).ceil();

      count += xTiles * yTiles;
    }

    return count;
  }
}
