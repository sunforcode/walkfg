import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 路线照片组件 (PRD §3.3.12)
///
/// 段标题"📸 路线照片"；不对称网格：左列 2fr（主图，高 140px）、右列 1fr（两张侧图等分高度）；
/// 圆角 12px overflow:hidden；无真实图片时显示渐变占位+📷 图标
class RouteGalleryWidget extends StatelessWidget {
  /// 图片URL列表
  final List<String> imageUrls;

  /// 点击图片回调
  final void Function(int index)? onImageTap;

  const RouteGalleryWidget({
    super.key,
    required this.imageUrls,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    // PRD §3.3.12：取前 3 张渲染到 3 格
    final displayUrls = imageUrls.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(totalCount: imageUrls.length),
        const SizedBox(height: 12),
        _AsymmetricGrid(
          displayUrls: displayUrls,
          onImageTap: onImageTap,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："📸 路线照片"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int totalCount;
  const _SectionHeader({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '📸 路线照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$totalCount张',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.badgeBlueText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  不对称网格：左 2fr (主图 140px) + 右 1fr (两张侧图等分)
// ---------------------------------------------------------------------------

class _AsymmetricGrid extends StatelessWidget {
  final List<String> displayUrls;
  final void Function(int index)? onImageTap;

  const _AsymmetricGrid({
    required this.displayUrls,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        children: [
          // 左列：主图 (2fr)
          Expanded(
            flex: 2,
            child: _ImageCell(
              imageUrl: displayUrls[0],
              index: 0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              onImageTap: onImageTap,
            ),
          ),

          const SizedBox(width: 4),

          // 右列：两张侧图等分 (1fr)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // 侧图 1
                Expanded(
                  child: _ImageCell(
                    imageUrl: displayUrls.length > 1 ? displayUrls[1] : '',
                    index: 1,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                    ),
                    onImageTap: onImageTap,
                  ),
                ),

                const SizedBox(height: 4),

                // 侧图 2
                Expanded(
                  child: _ImageCell(
                    imageUrl: displayUrls.length > 2 ? displayUrls[2] : '',
                    index: 2,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                    onImageTap: onImageTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  图片格子：加载失败 / 空URL 时显示渐变占位 + 📷 图标
// ---------------------------------------------------------------------------

class _ImageCell extends StatelessWidget {
  final String imageUrl;
  final int index;
  final BorderRadius borderRadius;
  final void Function(int index)? onImageTap;

  const _ImageCell({
    required this.imageUrl,
    required this.index,
    required this.borderRadius,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onImageTap?.call(index),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: imageUrl.isEmpty
            ? _GradientPlaceholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CupertinoActivityIndicator(radius: 10),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _GradientPlaceholder();
                },
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  渐变占位 + 📷 图标 (PRD §3.3.12)
// ---------------------------------------------------------------------------

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sheetTagBg,
            AppColors.sheetDivider,
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '📷',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
