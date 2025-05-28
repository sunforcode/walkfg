import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // 添加导入以解决ImageFilter未定义的问题
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
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
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadGuideDetail();

    // 监听滚动事件，控制导航栏标题显示
    _scrollController.addListener(() {
      if (_scrollController.offset > 180 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 180 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载攻略详情
  void _loadGuideDetail() {
    if (widget.guide != null) {
      _guideFuture = Future.value(widget.guide!);
      _isLiked = widget.guide!.isLiked;
      _isBookmarked = widget.guide!.isBookmarked;
    } else {
      final apiService = ServiceLocator.instance.getGuideService();
      // 使用新的方法加载包含关联数据的完整攻略
      _guideFuture = apiService.getGuideWithDetails(widget.guideId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _showTitle
            ? FutureBuilder<GuideModel>(
                future: _guideFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return const Text('徒步攻略');
                },
              )
            : const Text('徒步攻略'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.ellipsis_vertical),
          onPressed: () => _showMoreOptions(context),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<GuideModel>(
          future: _guideFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final guide = snapshot.data!;
            _isLiked = guide.isLiked;
            return _buildGuideDetail(context, guide);
          },
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Column(
      children: [
        // 骨架屏 - 封面图
        Container(
          height: 220,
          width: double.infinity,
          color: CupertinoColors.systemGrey6,
        ),

        // 骨架屏 - 内容
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题骨架
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 16),

                // 作者信息骨架
                Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 内容骨架
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 16,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String errorMessage) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CupertinoColors.systemGrey),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
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

  /// 构建攻略详情内容
  Widget _buildGuideDetail(BuildContext context, GuideModel guide) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
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

            // 行程规划卡片
            SliverToBoxAdapter(
              child: _buildPlanTripCard(guide),
            ),

            // 作者推荐部分
            SliverToBoxAdapter(
              child: _buildAuthorRecommendations(guide),
            ),

            // 相关攻略
            SliverToBoxAdapter(
              child: _buildRelatedGuides(guide),
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // 为底部操作栏留出空间
            ),
          ],
        ),

        // 底部操作按钮 - 固定在底部
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildActionBar(guide),
        ),
      ],
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage(GuideModel guide) {
    final accentColor = AppColors.primary;

    return Container(
      height: 250,
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
              height: 100,
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

          // 返回按钮 - 半透明背景
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // 图片底部信息
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // 难度指示
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.chart_bar_alt_fill,
                        color: CupertinoColors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        guide.getDifficultyName(),
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 时长指示
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.time,
                        color: CupertinoColors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        guide.getReadingTimeText(),
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              GestureDetector(
                onTap: () => _showAuthorProfile(guide.author),
                child: Row(
                  children: [
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
                  ],
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

          const SizedBox(height: 16),

          // 快速操作按钮
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionButton(
                  '保存为PDF',
                  CupertinoIcons.doc_text,
                  AppColorPalette.blueColors[3],
                  () => _saveToPDF(guide),
                ),
                _buildQuickActionButton(
                  '离线保存',
                  CupertinoIcons.cloud_download,
                  AppColorPalette.blueColors[2],
                  () => _saveOffline(guide),
                ),
                _buildQuickActionButton(
                  '相关路线',
                  CupertinoIcons.map,
                  AppColorPalette.blueColors[1],
                  () => _showRelatedRoutes(guide),
                ),
                _buildQuickActionButton(
                  '装备清单',
                  CupertinoIcons.bag,
                  AppColorPalette.blueColors[0],
                  () => _showEquipmentList(guide),
                ),
              ],
            ),
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
    // 使用Markdown渲染内容，支持更丰富的格式
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 内容
          MarkdownBody(
            data: guide.content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: CupertinoColors.label,
              ),
              h1: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
              h2: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
              h3: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
              blockquote: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.none,
              ),
              blockquoteDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border(
                  left: BorderSide(
                    color: AppColors.primary,
                    width: 4,
                  ),
                ),
              ),
              blockquotePadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 24),

          // 标签列表
          if (guide.tags.isNotEmpty) ...[
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

          // 分隔线
          const Divider(),
        ],
      ),
    );
  }

  /// 构建行程规划卡片
  Widget _buildPlanTripCard(GuideModel guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行程规划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey4.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 行程概览
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 图标
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.map,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '推荐行程',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              guide.getTripDescription(),
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 按钮
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '查看',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                        onPressed: () => _showFullTripPlan(guide),
                      ),
                    ],
                  ),
                ),
                // 分隔线
                const Divider(height: 1),

                // 行程亮点
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '行程亮点',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 使用 GuideModel 的 highlights 字段，如果为空则显示默认内容
                      if (guide.highlights.isNotEmpty)
                        ...guide.highlights.map(
                            (highlight) => _buildHighlightItem(highlight, ''))
                      else ...[
                        _buildHighlightItem('精选路线', '经验丰富的向导精心规划的最佳路线'),
                        _buildHighlightItem('风景优美', '沿途风景如画，适合拍照留念'),
                        _buildHighlightItem('难度适中', '适合大多数徒步爱好者，无需专业装备'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 查看完整行程按钮
          Center(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(20),
              child: Text(
                '查看完整行程规划',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              onPressed: () => _showFullTripPlan(guide),
            ),
          ),
          const SizedBox(height: 16),
          // 分隔线
          const Divider(),
        ],
      ),
    );
  }

  /// 构建行程亮点项
  Widget _buildHighlightItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示完整行程规划
  void _showFullTripPlan(GuideModel guide) {
    _showToast('完整行程规划功能开发中');
  }

  /// 构建作者推荐部分
  Widget _buildAuthorRecommendations(GuideModel guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '作者推荐',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 作者推荐卡片
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey4.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 作者信息
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 作者头像
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: guide.authorAvatarUrl != null
                            ? NetworkImage(guide.authorAvatarUrl!)
                            : null,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: guide.authorAvatarUrl == null
                            ? Icon(CupertinoIcons.person,
                                size: 20, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // 作者信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guide.author,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              guide.getAuthorExperienceText(),
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 关注按钮
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '关注',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        onPressed: () => _followAuthor(),
                      ),
                    ],
                  ),
                ),

                // 分隔线
                const Divider(height: 1),

                // 推荐装备
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '推荐装备',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 装备列表
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildEquipmentItem(
                                '徒步鞋', 'assets/images/hiking_shoes.png'),
                            _buildEquipmentItem(
                                '登山杖', 'assets/images/trekking_poles.png'),
                            _buildEquipmentItem(
                                '背包', 'assets/images/backpack.png'),
                            _buildEquipmentItem(
                                '水壶', 'assets/images/water_bottle.png'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 分隔线
                const Divider(height: 1),

                // 作者提示
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '作者提示',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.lightbulb_fill,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                guide.personalTips.isNotEmpty
                                    ? guide.personalTips.join(' ')
                                    : '这条路线在雨季可能会有部分路段泥泞，建议携带防水鞋套和雨衣。夏季蚊虫较多，请做好防蚊准备。',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.systemGrey.darkColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 分隔线
          const Divider(),
        ],
      ),
    );
  }

  /// 构建装备项
  Widget _buildEquipmentItem(String name, String imagePath) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // 图片
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.cube_box,
              size: 32,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          // 名称
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建相关攻略
  Widget _buildRelatedGuides(GuideModel guide) {
    // 获取实际的相关攻略数据
    final relatedGuides = guide.relatedGuides ?? [];

    // 如果没有相关攻略，显示占位内容
    if (relatedGuides.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '相关攻略',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      size: 32,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无相关攻略',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '相关攻略',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedGuides.length, // 使用实际数据长度
              itemBuilder: (context, index) {
                final relatedGuide = relatedGuides[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey4.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => _navigateToGuide(relatedGuide),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 图片
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            child: relatedGuide.coverUrl != null
                                ? NetworkImageWithFallback(
                                    url: relatedGuide.coverUrl!,
                                    fit: BoxFit.cover,
                                    fallbackColor:
                                        AppColors.primary.withOpacity(0.1),
                                    fallbackIcon: CupertinoIcons.photo,
                                  )
                                : Container(
                                    color: AppColors.primary.withOpacity(0.1),
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      size: 32,
                                      color: AppColors.primary.withOpacity(0.5),
                                    ),
                                  ),
                          ),
                        ),

                        // 内容
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                relatedGuide.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                relatedGuide.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.eye,
                                    size: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatNumber(relatedGuide.views),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    relatedGuide.getDifficultyName(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 导航到相关攻略
  void _navigateToGuide(GuideModel guide) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => GuideDetailScreen(
          guideId: guide.id,
          guide: guide,
        ),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildActionBar(GuideModel guide) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withOpacity(0.8),
            border: const Border(
              top: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // 评论输入框
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCommentInput(guide),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '写下你的评论...',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 点赞按钮
                _buildActionButton(
                  _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  _isLiked
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey,
                  () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                    // 调用点赞API
                    final apiService =
                        ServiceLocator.instance.getGuideService();
                    apiService.likeGuide(guide.id);
                  },
                ),

                const SizedBox(width: 12),

                // 收藏按钮
                _buildActionButton(
                  _isBookmarked
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  _isBookmarked
                      ? AppColors.primary
                      : CupertinoColors.systemGrey,
                  () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                    // 调用收藏API
                    // 这里添加收藏功能的API调用
                  },
                ),

                const SizedBox(width: 12),

                // 分享按钮
                _buildActionButton(
                  CupertinoIcons.share,
                  CupertinoColors.systemGrey,
                  () => _shareGuide(guide),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部操作按钮
  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        minSize: 0,
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String tag) {
    return GestureDetector(
      onTap: () => _searchByTag(tag),
      child: Container(
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
      ),
    );
  }

  /// 显示更多选项
  void _showMoreOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('更多选项'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _reportGuide();
            },
            child: const Text('举报内容'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _followAuthor();
            },
            child: const Text('关注作者'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _addToCollection();
            },
            child: const Text('添加到收藏夹'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _translateContent();
            },
            child: const Text('翻译内容'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
      ),
    );
  }

  /// 显示评论输入框
  void _showCommentInput(GuideModel guide) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '发表评论',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const CupertinoTextField(
                placeholder: '分享你的想法...',
                maxLines: 3,
                padding: EdgeInsets.all(12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text('发布'),
                    onPressed: () {
                      Navigator.pop(context);
                      // 这里添加发布评论的逻辑
                      _showToast('评论已发布');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享攻略
  void _shareGuide(GuideModel guide) {
    Share.share(
      '推荐一篇徒步攻略：${guide.title}\n\n来自Walk徒步旅行助手',
      subject: guide.title,
    );
  }

  /// 保存为PDF
  void _saveToPDF(GuideModel guide) {
    _showToast('PDF保存功能开发中');
  }

  /// 离线保存
  void _saveOffline(GuideModel guide) {
    _showToast('攻略已保存到离线列表');
  }

  /// 显示相关路线
  void _showRelatedRoutes(GuideModel guide) {
    _showToast('相关路线功能开发中');
  }

  /// 显示装备清单
  void _showEquipmentList(GuideModel guide) {
    _showToast('装备清单功能开发中');
  }

  /// 查看作者资料
  void _showAuthorProfile(String author) {
    _showToast('正在查看${author}的资料');
  }

  /// 按标签搜索
  void _searchByTag(String tag) {
    _showToast('正在搜索标签：$tag');
  }

  /// 举报内容
  void _reportGuide() {
    _showToast('举报功能开发中');
  }

  /// 关注作者
  void _followAuthor() {
    _showToast('已关注作者');
  }

  /// 添加到收藏夹
  void _addToCollection() {
    _showToast('已添加到收藏夹');
  }

  /// 翻译内容
  void _translateContent() {
    _showToast('翻译功能开发中');
  }

  /// 显示提示信息
  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
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
