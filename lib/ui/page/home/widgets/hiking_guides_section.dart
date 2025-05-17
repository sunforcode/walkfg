import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/guide_model.dart';
import '../../../../service/service_locator.dart';
import '../../route/cupertino_route_list_screen.dart';
import '../../guide/cupertino_guide_detail_screen.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/empty_content_widget.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/cards/guide_card.dart';

/// 徒步攻略部分组件
class HikingGuidesSection extends StatefulWidget {
  /// 构造函数
  const HikingGuidesSection({super.key});

  @override
  State<HikingGuidesSection> createState() => _HikingGuidesSectionState();
}

class _HikingGuidesSectionState extends State<HikingGuidesSection> with AutomaticKeepAliveClientMixin {
  /// 徒步攻略列表Future
  late Future<List<GuideModel>> _hikingGuidesFuture;

  /// 真实图片URL列表
  final List<String> _realImageUrls = [
    'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1527004013197-933c4bb611b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1476611338391-6c395b6f7886?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1445307806294-bff7f67ff225?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _hikingGuidesFuture = _loadData();
  }

  /// 加载数据
  Future<List<GuideModel>> _loadData() async {
    final apiService = ServiceLocator.instance.getApiService();
    // 获取徒步攻略，限制4条
    return apiService.getHikingGuides(limit: 4);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 徒步攻略标题
        SectionHeader(
          title: '徒步攻略',
          actionText: '查看全部',
          onAction: () => _navigateToAllGuides(context),
        ),

        const SizedBox(height: 16),

        // 徒步攻略瀑布流
        FutureBuilder<List<GuideModel>>(
          future: _hikingGuidesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(height: 200);
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _hikingGuidesFuture = _loadData();
                  });
                },
                color: AppColors.primary,
              );
            }

            final hikingGuides = snapshot.data;
            if (hikingGuides == null || hikingGuides.isEmpty) {
              return const EmptyContentWidget(
                icon: Icons.article,
                title: '暂无徒步攻略',
                subtitle: '敬请期待更多精彩内容',
                color: AppColors.secondary,
              );
            }

            return _buildHikingGuides(context, hikingGuides);
          },
        ),
      ],
    );
  }

  /// 导航到所有攻略页面
  void _navigateToAllGuides(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteListScreen(),
      ),
    );
  }

  /// 导航到攻略详情页面
  void _navigateToGuideDetail(BuildContext context, GuideModel guide) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => GuideDetailScreen(
          guideId: guide.id,
          guide: guide,
        ),
      ),
    );
  }

  /// 构建徒步攻略瀑布流
  Widget _buildHikingGuides(BuildContext context, List<GuideModel> hikingGuides) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, // 调整卡片比例，适应更大的图片区域
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: hikingGuides.length,
      itemBuilder: (context, index) {
        final guide = hikingGuides[index];
        // 为每个卡片分配一个蓝色系颜色
        final cardColor = AppColors.getBlueColor(index);
        // 为每个卡片分配一个真实图片
        final imageUrl = _realImageUrls[index % _realImageUrls.length];

        // 创建带有真实图片的攻略模型
        final guideWithImage = guide.coverUrl != null ? guide : GuideModel(
          id: guide.id,
          title: guide.title,
          content: guide.content,
          author: guide.author,
          authorId: guide.authorId,
          authorAvatarUrl: guide.authorAvatarUrl,
          likes: guide.likes,
          views: guide.views,
          publishDate: guide.publishDate,
          updateDate: guide.updateDate,
          iconCode: guide.iconCode,
          coverUrl: imageUrl,
          tags: guide.tags,
          isLiked: guide.isLiked,
        );

        return GuideCard(
          guide: guideWithImage,
          accentColor: cardColor,
          onLikeChanged: (isLiked) {
            setState(() {
              // 更新点赞状态
              final updatedGuides = _hikingGuidesFuture.then((guides) {
                final index = guides.indexWhere((g) => g.id == guide.id);
                if (index != -1) {
                  final updatedGuide = guide.copyWith(isLiked: isLiked);
                  guides[index] = updatedGuide;
                }
                return guides;
              });
              _hikingGuidesFuture = updatedGuides;
            });
          },
        );
      },
    );
  }
}