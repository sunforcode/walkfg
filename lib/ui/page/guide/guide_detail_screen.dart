import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';
import 'package:walk/ui/page/guide/widgets/guide_cover_widget.dart';
import 'package:walk/ui/page/guide/widgets/guide_overview_widget.dart';
import 'package:walk/ui/page/guide/widgets/guide_content_widget.dart';
import 'package:walk/ui/page/guide/widgets/guide_trip_plan_widget.dart';
import 'package:walk/ui/page/guide/widgets/guide_author_widget.dart';
import 'package:walk/ui/page/guide/widgets/guide_related_widget.dart';
import 'package:walk/ui/page/guide/widgets/guide_action_bar_widget.dart';
import 'package:walk/utils/toast_utils.dart';

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
      _guideFuture = apiService.getGuideWithDetails(widget.guideId);
    }
  }

  /// 处理点赞
  void _handleLike(GuideModel guide) {
    setState(() {
      _isLiked = !_isLiked;
    });
    final apiService = ServiceLocator.instance.getGuideService();
    apiService.likeGuide(guide.id);
  }

  /// 处理收藏
  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ToastUtils.showToast(context, _isBookmarked ? '已收藏' : '已取消收藏');
  }

  /// 处理分享
  void _handleShare(GuideModel guide) {
    // 分享功能
    ToastUtils.showToast(context, '分享功能开发中');
  }

  /// 处理评论
  void _handleComment(GuideModel guide) {
    ToastUtils.showToast(context, '评论功能开发中');
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
      ),
      child: SafeArea(
        child: FutureBuilder<GuideModel>(
          future: _guideFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _loadGuideDetail();
                  });
                },
              );
            }

            final guide = snapshot.data!;
            _isLiked = guide.isLiked;
            _isBookmarked = guide.isBookmarked;

            return Stack(
              children: [
                // 主要内容
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // 封面图片
                    SliverToBoxAdapter(
                      child: GuideCoverWidget(guide: guide),
                    ),

                    // 攻略概览
                    SliverToBoxAdapter(
                      child: GuideOverviewWidget(guide: guide),
                    ),

                    // 攻略内容
                    SliverToBoxAdapter(
                      child: GuideContentWidget(guide: guide),
                    ),

                    // 行程规划卡片
                    SliverToBoxAdapter(
                      child: GuideTripPlanWidget(guide: guide),
                    ),

                    // 作者推荐部分
                    SliverToBoxAdapter(
                      child: GuideAuthorWidget(guide: guide),
                    ),

                    // 相关攻略
                    SliverToBoxAdapter(
                      child: GuideRelatedWidget(guide: guide),
                    ),

                    // 底部间距
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100), // 为底部操作栏留出空间
                    ),
                  ],
                ),

                // 底部操作栏
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GuideActionBarWidget(
                    guide: guide,
                    isLiked: _isLiked,
                    isBookmarked: _isBookmarked,
                    onLike: () => _handleLike(guide),
                    onBookmark: _handleBookmark,
                    onShare: () => _handleShare(guide),
                    onComment: () => _handleComment(guide),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
