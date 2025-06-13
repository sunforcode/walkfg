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
import 'package:walk/ui/page/guide/widgets/guide_detail_constants.dart';
import 'package:walk/utils/toast_utils.dart';

/// iOS风格的徒步攻略详情页面
///
/// 提供攻略详细信息展示、点赞收藏、分享评论等功能
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
  /// 攻略数据Future
  late Future<GuideModel> _guideFuture;

  /// 是否已点赞
  bool _isLiked = false;

  /// 是否已收藏
  bool _isBookmarked = false;

  /// 滚动控制器
  late ScrollController _scrollController;

  /// 是否显示导航栏标题
  bool _showTitle = false;

  /// 是否已初始化状态
  bool _isStateInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeScrollController();
    _loadGuideDetail();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化滚动控制器
  void _initializeScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  /// 监听滚动事件，控制导航栏标题显示
  void _onScroll() {
    final shouldShowTitle =
        _scrollController.offset > GuideDetailConstants.scrollThreshold;

    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  /// 加载攻略详情
  void _loadGuideDetail() {
    try {
      if (widget.guide != null) {
        _guideFuture = Future.value(widget.guide!);
        _initializeGuideState(widget.guide!);
      } else {
        final apiService = ServiceLocator.instance.getGuideService();
        _guideFuture = apiService.getGuideWithDetails(widget.guideId);
      }
    } catch (e) {
      _handleLoadError(e);
    }
  }

  /// 初始化攻略状态
  void _initializeGuideState(GuideModel guide) {
    if (_isStateInitialized) return;

    setState(() {
      _isLiked = guide.isLiked;
      _isBookmarked = guide.isBookmarked;
      _isStateInitialized = true;
    });
  }

  /// 处理加载错误
  void _handleLoadError(dynamic error) {
    // TODO: 添加错误日志记录
    debugPrint('攻略加载失败: $error');
  }

  /// 处理点赞操作
  void _handleLike(GuideModel guide) {
    setState(() {
      _isLiked = !_isLiked;
    });

    try {
      final apiService = ServiceLocator.instance.getGuideService();
      apiService.likeGuide(guide.id);

      final message = _isLiked
          ? GuideDetailConstants.likeSuccessMessage
          : GuideDetailConstants.unlikeSuccessMessage;
      ToastUtils.showToast(context, message);
    } catch (e) {
      // 回滚状态
      setState(() {
        _isLiked = !_isLiked;
      });
      ToastUtils.showToast(context, GuideDetailConstants.genericErrorMessage);
    }
  }

  /// 处理收藏操作
  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      // TODO: 实现收藏API调用
      final message = _isBookmarked
          ? GuideDetailConstants.bookmarkSuccessMessage
          : GuideDetailConstants.unbookmarkSuccessMessage;
      ToastUtils.showToast(context, message);
    } catch (e) {
      // 回滚状态
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      ToastUtils.showToast(context, GuideDetailConstants.genericErrorMessage);
    }
  }

  /// 处理分享操作
  void _handleShare(GuideModel guide) {
    // TODO: 实现分享功能
    ToastUtils.showToast(
        context, GuideDetailConstants.shareInDevelopmentMessage);
  }

  /// 处理评论操作
  void _handleComment(GuideModel guide) {
    // TODO: 实现评论功能
    ToastUtils.showToast(
        context, GuideDetailConstants.commentInDevelopmentMessage);
  }

  /// 重新加载数据
  void _retryLoad() {
    setState(() {
      _loadGuideDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
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
                onRetry: _retryLoad,
              );
            }

            final guide = snapshot.data!;

            // 使用 WidgetsBinding.instance.addPostFrameCallback 来避免在 build 期间调用 setState
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeGuideState(guide);
            });

            return Stack(
              children: [
                // 主要内容
                _buildMainContent(guide),

                // 底部操作栏
                _buildBottomActionBar(guide),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建导航栏
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
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
                return const Text(GuideDetailConstants.pageTitle);
              },
            )
          : const Text(GuideDetailConstants.pageTitle),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(GuideModel guide) {
    return CustomScrollView(
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
          child: SizedBox(height: GuideDetailConstants.bottomSpacing),
        ),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomActionBar(GuideModel guide) {
    return Positioned(
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
    );
  }
}
