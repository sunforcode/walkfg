import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/tokens/tokens.dart';
import 'package:walk/ui/page/common/empty_content_widget.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/ui/page/common/section_header.dart';
import 'package:walk/ui/page/guide/cards/guide_card.dart';
import 'package:walk/ui/page/guide/guide_detail_screen.dart';
import 'package:walk/utils/toast_utils.dart';

/// 徒步攻略部分组件
class HikingGuidesSection extends StatelessWidget {
  /// 徒步攻略列表Future
  final Future<List<GuideModel>> hikingGuidesFuture;

  /// 构造函数
  const HikingGuidesSection({
    super.key,
    required this.hikingGuidesFuture,
  });

  @override
  Widget build(BuildContext context) {
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
          future: hikingGuidesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(height: 200);
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: () {}, // 提供一个空函数而不是null
              );
            }

            final hikingGuides = snapshot.data;
            if (hikingGuides == null || hikingGuides.isEmpty) {
              return const EmptyContentWidget(
                icon: CupertinoIcons.doc_text,
                title: '暂无徒步攻略',
                subtitle: '敬请期待更多精彩内容',
              );
            }

            return _buildHikingGuides(context, hikingGuides);
          },
        ),
      ],
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
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: hikingGuides.length,
      itemBuilder: (context, index) {
        final guide = hikingGuides[index];
        // 为每个卡片分配一个蓝色系颜色
        final cardColor = AppColors.getBlueColor(index);

        // 创建带有本地图片的攻略模型
        return GestureDetector(
          onTap: () => _navigateToGuideDetail(context, guide),
          child: GuideCard(
            guide: guide,
            accentColor: cardColor,
            onLikeChanged: (isLiked) => _handleGuideLike(context, guide.id, isLiked),
          ),
        );
      },
    );
  }

  /// 处理攻略点赞
  void _handleGuideLike(BuildContext context, String guideId, bool isLiked) {
    // 这里可以添加点赞逻辑，例如调用API
    final message = isLiked ? '已添加到收藏' : '已取消收藏';
    ToastUtils.showToast(context, message);
  }

  /// 导航到所有攻略页面
  void _navigateToAllGuides(BuildContext context) {
    // TODO: 实现导航到攻略列表页面
    ToastUtils.showToast(context, '攻略列表页面尚未实现');
    // Navigator.of(context, rootNavigator: true).push(
    //   CupertinoPageRoute(
    //     builder: (context) => const GuideListScreen(),
    //   ),
    // );
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
}
