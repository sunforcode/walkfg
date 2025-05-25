import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/guide/guide_model.dart';
import '../../../service/service_manager.dart';
import '../../../theme/theme/app_colors.dart';
import '../../../theme/theme/app_color_palette.dart';
import '../common/network_image_with_fallback.dart';

/// iOS风格的徒步攻略详情页面
class GuideDetailScreen extends StatefulWidget {
  /// 攻略ID
  final String guideId;

  /// 攻略数据（可选，如果提供则不需要加载）
  final GuideModel? guide;

  /// 构造函数
  const GuideDetailScreen({
    super.key,
    required this.guideId,
    this.guide,
  });

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  late Future<GuideModel> _guideFuture;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadGuideDetail();
  }

  /// 加载攻略详情
  void _loadGuideDetail() {
    if (widget.guide != null) {
      _guideFuture = Future.value(widget.guide!);
      _isLiked = widget.guide!.isLiked;
    } else {
      final apiService = ServiceLocator.instance.getGuideService();
      _guideFuture = apiService.getGuideById(widget.guideId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('徒步攻略'),
      ),
      child: SafeArea(
        child: FutureBuilder<GuideModel>(
          future: _guideFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (snapshot.hasError) {
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
                    const Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      child: const Text('重试'),
                      onPressed: () {
                        setState(() {
                          _loadGuideDetail();
                        });
                      },
                    ),
                  ],
                ),
              );
            }

            final guide = snapshot.data!;
            _isLiked = guide.isLiked;
            return _buildGuideDetail(context, guide);
          },
        ),
      ),
    );
  }

  /// 构建攻略详情内容
  Widget _buildGuideDetail(BuildContext context, GuideModel guide) {
    return CustomScrollView(
      slivers: [
        // 攻略封面图片
        SliverToBoxAdapter(
          child: _buildCoverImage(guide),
        ),

        // 攻略标题和作者信息
        SliverToBoxAdapter(
          child: _buildTitleAndAuthor(guide),
        ),

        // 攻略内容
        SliverToBoxAdapter(
          child: _buildContent(guide),
        ),

        // 底部操作按钮
        SliverToBoxAdapter(
          child: _buildActionButtons(guide),
        ),

        // 底部间距
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage(GuideModel guide) {
    final accentColor = AppColors.primary;

    return Container(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片
          Hero(
            tag: 'guide_image_${guide.id}',
            child: guide.coverUrl != null
                ? NetworkImageWithFallback(
                    url: guide.coverUrl!,
                    fit: BoxFit.cover,
                    fallbackColor: accentColor,
                    fallbackIcon: CupertinoIcons.photo,
                  )
                : Container(
                    color: accentColor.withOpacity(0.2),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),

          // 标签
          if (guide.tags.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  guide.tags.first,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // 渐变遮罩
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
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标题和作者信息
  Widget _buildTitleAndAuthor(GuideModel guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            guide.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 作者信息和统计
          Row(
            children: [
              // 作者头像和名称
              CircleAvatar(
                radius: 16,
                backgroundImage: guide.authorAvatarUrl != null
                    ? NetworkImage(guide.authorAvatarUrl!)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: guide.authorAvatarUrl == null
                    ? Icon(CupertinoIcons.person,
                        size: 16, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                guide.author,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // 阅读量
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.eye,
                    size: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatNumber(guide.views),
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // 发布日期
              Text(
                _getTimeAgo(guide.publishDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 分隔线
          const Divider(),
        ],
      ),
    );
  }

  /// 构建内容
  Widget _buildContent(GuideModel guide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 内容
          Text(
            guide.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // 标签列表
          if (guide.tags.length > 1) ...[
            const Text(
              '标签',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: guide.tags.map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(GuideModel guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            CupertinoIcons.share,
            '分享',
            AppColorPalette.blueColors[0],
            () {
              // 分享功能
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('提示'),
                  content: const Text('分享功能正在开发中'),
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
          _buildLikeButton(guide),
          _buildActionButton(
            CupertinoIcons.bookmark,
            '收藏',
            AppColorPalette.blueColors[4],
            () {
              // 收藏功能
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('提示'),
                  content: const Text('收藏功能正在开发中'),
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

  /// 构建点赞按钮
  Widget _buildLikeButton(GuideModel guide) {
    final color =
        _isLiked ? CupertinoColors.systemRed : AppColorPalette.blueColors[2];

    return CupertinoButton(
      onPressed: () {
        setState(() {
          _isLiked = !_isLiked;
        });
        // 调用点赞API
        final apiService = ServiceLocator.instance.getGuideService();
        apiService.likeGuide(guide.id);
      },
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatNumber(guide.likes + (_isLiked ? 1 : 0))}',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化数字（大于1000显示为k）
  String _formatNumber(int number) {
    if (number >= 1000) {
      final double result = number / 1000;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  /// 获取相对时间
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前';
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
