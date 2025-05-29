import 'package:flutter/cupertino.dart';

/// 路线图片推荐组件
class RouteGalleryWidget extends StatelessWidget {
  /// 图片URL列表
  final List<String> imageUrls;

  /// 点击图片回调
  final Function(int index)? onImageTap;

  const RouteGalleryWidget({
    super.key,
    required this.imageUrls,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                CupertinoIcons.photo,
                size: 18,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                '路线图片',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              if (imageUrls.length > 3)
                Text(
                  '共${imageUrls.length}张',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 图片网格
          _buildImageGrid(),
        ],
      ),
    );
  }

  /// 构建图片网格
  Widget _buildImageGrid() {
    // 最多显示6张图片
    final displayImages = imageUrls.take(6).toList();
    
    return Container(
      height: 120,
      child: Row(
        children: [
          // 主图（左侧大图）
          Expanded(
            flex: 2,
            child: _buildMainImage(displayImages.first, 0),
          ),
          
          const SizedBox(width: 8),
          
          // 右侧小图网格
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // 上排两张小图
                if (displayImages.length > 1)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSmallImage(displayImages[1], 1),
                        ),
                        if (displayImages.length > 2) ...[
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildSmallImage(displayImages[2], 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                
                if (displayImages.length > 3) ...[
                  const SizedBox(height: 4),
                  // 下排两张小图
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSmallImage(displayImages[3], 3),
                        ),
                        if (displayImages.length > 4) ...[
                          const SizedBox(width: 4),
                          Expanded(
                            child: displayImages.length > 5
                                ? _buildMoreImage(displayImages[4], 4)
                                : _buildSmallImage(displayImages[4], 4),
                          ),
                        ],
                      ],
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

  /// 构建主图
  Widget _buildMainImage(String imageUrl, int index) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onImageTap?.call(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CupertinoColors.systemGrey6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPlaceholder();
            },
          ),
        ),
      ),
    );
  }

  /// 构建小图
  Widget _buildSmallImage(String imageUrl, int index) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onImageTap?.call(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: CupertinoColors.systemGrey6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPlaceholder(isSmall: true);
            },
          ),
        ),
      ),
    );
  }

  /// 构建更多图片按钮
  Widget _buildMoreImage(String imageUrl, int index) {
    final remainingCount = imageUrls.length - 5;
    
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onImageTap?.call(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: CupertinoColors.systemGrey6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              // 背景图片
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder(isSmall: true);
                },
              ),
              
              // 遮罩和文字
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.photo_on_rectangle,
                        color: CupertinoColors.white,
                        size: 16,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+$remainingCount',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建错误占位符
  Widget _buildErrorPlaceholder({bool isSmall = false}) {
    return Container(
      color: CupertinoColors.systemGrey6,
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          color: CupertinoColors.systemGrey,
          size: isSmall ? 16 : 24,
        ),
      ),
    );
  }
}