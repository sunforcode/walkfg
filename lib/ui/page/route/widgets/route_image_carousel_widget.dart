import 'package:flutter/cupertino.dart';
import 'dart:async';

/// 路线头图循环播放组件
class RouteImageCarouselWidget extends StatefulWidget {
  /// 图片URL列表
  final List<String> imageUrls;

  /// 组件高度
  final double height;

  /// 自动播放间隔（秒）
  final int autoPlayInterval;

  /// 是否显示指示器
  final bool showIndicator;

  /// 是否显示计数器
  final bool showCounter;

  /// 构造函数
  const RouteImageCarouselWidget({
    super.key,
    required this.imageUrls,
    this.height = 250.0,
    this.autoPlayInterval = 3,
    this.showIndicator = true,
    this.showCounter = true,
  });

  @override
  State<RouteImageCarouselWidget> createState() => _RouteImageCarouselWidgetState();
}

class _RouteImageCarouselWidgetState extends State<RouteImageCarouselWidget> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 如果有多张图片，启动自动播放
    if (widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// 启动自动播放
  void _startAutoPlay() {
    _timer = Timer.periodic(
      Duration(seconds: widget.autoPlayInterval),
      (timer) {
        if (_currentIndex < widget.imageUrls.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
        
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  /// 停止自动播放
  void _stopAutoPlay() {
    _timer.cancel();
  }

  /// 重新启动自动播放
  void _restartAutoPlay() {
    _stopAutoPlay();
    if (widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  /// 处理页面变化
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// 处理手动滑动
  void _onPanStart(DragStartDetails details) {
    _stopAutoPlay();
  }

  /// 处理滑动结束
  void _onPanEnd(DragEndDetails details) {
    _restartAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: widget.height,
      child: Stack(
        children: [
          // 图片轮播
          GestureDetector(
            onPanStart: _onPanStart,
            onPanEnd: _onPanEnd,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return _buildImageItem(widget.imageUrls[index]);
              },
            ),
          ),

          // 渐变遮罩（底部）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withOpacity(0.0),
                    CupertinoColors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // 指示器
          if (widget.showIndicator && widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 16,
              child: _buildIndicator(),
            ),

          // 计数器
          if (widget.showCounter && widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildCounter(),
            ),

          // 左右切换按钮（仅在有多张图片时显示）
          if (widget.imageUrls.length > 1) ...[
            // 左侧按钮
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationButton(
                  icon: CupertinoIcons.chevron_left,
                  onPressed: _previousImage,
                ),
              ),
            ),

            // 右侧按钮
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationButton(
                  icon: CupertinoIcons.chevron_right,
                  onPressed: _nextImage,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建图片项
  Widget _buildImageItem(String imageUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CupertinoActivityIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState();
          },
        ),
      ),
    );
  }

  /// 构建指示器
  Widget _buildIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.imageUrls.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex
                ? CupertinoColors.white
                : CupertinoColors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  /// 构建计数器
  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentIndex + 1}/${widget.imageUrls.length}',
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建导航按钮
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _stopAutoPlay();
        onPressed();
        _restartAutoPlay();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: CupertinoColors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: CupertinoColors.white,
          size: 20,
        ),
      ),
    );
  }

  /// 上一张图片
  void _previousImage() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = widget.imageUrls.length - 1;
    }
    
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 下一张图片
  void _nextImage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 8),
            Text(
              '暂无图片',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Container(
      color: CupertinoColors.systemGrey6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 32,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 8),
            Text(
              '图片加载失败',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}