import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// flutter_markdown exposes MarkdownElementBuilder using markdown elements.
// ignore: depend_on_referenced_packages
import 'package:markdown/markdown.dart' as md;
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';

import 'guide_detail_constants.dart';

/// 攻略内容组件
///
/// 显示攻略的正文内容和相关标签，支持Markdown格式化文本显示
class GuideContentWidget extends StatelessWidget {
  /// 攻略数据
  final GuideModel guide;

  /// 构造函数
  const GuideContentWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(GuideDetailConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          _buildHeader(),

          const SizedBox(height: _ContentConstants.headerSpacing),

          // Markdown格式化的攻略正文
          _buildMarkdownContent(),

          const SizedBox(height: _ContentConstants.contentSpacing),

          // 标签列表
          if (guide.tags.isNotEmpty) _buildTagsSection(),
        ],
      ),
    );
  }

  /// 构建头部标题
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.doc_text,
          size: _ContentConstants.headerIconSize,
          color: CupertinoColors.systemBlue,
        ),
        const SizedBox(width: _ContentConstants.headerIconSpacing),
        Text(
          _ContentConstants.headerTitle,
          style: const TextStyle(
            fontSize: _ContentConstants.headerFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 构建Markdown内容
  Widget _buildMarkdownContent() {
    return MarkdownBody(
      data: guide.content,
      styleSheet: _buildMarkdownStyleSheet(),
      onTapLink: (text, href, title) {
        // TODO: 处理链接点击
      },
      imageBuilder: (uri, title, alt) {
        // 自定义图片构建器
        return _buildMarkdownImage(uri, title, alt);
      },
      builders: {
        // 自定义高亮提示构建器
        'highlight': _HighlightBuilder(),
        'warning': _WarningBuilder(),
        'tip': _TipBuilder(),
      },
    );
  }

  /// 构建Markdown样式表
  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      // 标题样式
      h1: const TextStyle(
        fontSize: _ContentConstants.heading1FontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h2: const TextStyle(
        fontSize: _ContentConstants.heading2FontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h3: const TextStyle(
        fontSize: _ContentConstants.heading3FontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h4: const TextStyle(
        fontSize: _ContentConstants.heading4FontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h5: const TextStyle(
        fontSize: _ContentConstants.heading5FontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h6: const TextStyle(
        fontSize: _ContentConstants.heading6FontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      ),

      // 段落样式
      p: const TextStyle(
        fontSize: _ContentConstants.contentFontSize,
        height: _ContentConstants.contentLineHeight,
        color: AppColors.textSecondary,
      ),

      // 列表样式
      listBullet: const TextStyle(
        fontSize: _ContentConstants.contentFontSize,
        color: CupertinoColors.systemBlue,
        fontWeight: FontWeight.bold,
      ),

      // 引用样式
      blockquote: const TextStyle(
        fontSize: _ContentConstants.contentFontSize,
        height: _ContentConstants.contentLineHeight,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius:
            BorderRadius.circular(_ContentConstants.quoteBorderRadius),
        border: const Border(
          left: BorderSide(
            color: CupertinoColors.systemBlue,
            width: _ContentConstants.quoteBorderWidth,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.all(_ContentConstants.quotePadding),

      // 代码样式
      code: TextStyle(
        fontSize: _ContentConstants.codeFontSize,
        fontFamily: 'Courier',
        color: CupertinoColors.systemRed,
        backgroundColor: AppColors.surfaceCard,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius:
            BorderRadius.circular(_ContentConstants.codeBlockBorderRadius),
      ),
      codeblockPadding:
          const EdgeInsets.all(_ContentConstants.codeBlockPadding),

      // 链接样式
      a: const TextStyle(
        color: CupertinoColors.systemBlue,
        decoration: TextDecoration.underline,
      ),

      // 强调样式
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
      ),

      // 表格样式
      tableHead: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      tableBody: const TextStyle(
        fontSize: _ContentConstants.contentFontSize,
        color: AppColors.textSecondary,
      ),
      tableBorder: TableBorder.all(
        color: AppColors.border,
        width: 0.5,
      ),

      // 水平分割线
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  /// 构建Markdown图片
  Widget _buildMarkdownImage(Uri uri, String? title, String? alt) {
    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: _ContentConstants.imageMargin),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(_ContentConstants.imageBorderRadius),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(_ContentConstants.imageBorderRadius),
        child: NetworkImageWithFallback(
          url: uri.toString(),
          fit: BoxFit.cover,
          fallbackColor: AppColors.interactiveAccent,
          errorBuilder: (_) => Container(
            height: 200,
            color: AppColors.surfaceCard,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.photo,
                  size: 48,
                  color: AppColors.textWeak,
                ),
                const SizedBox(height: 8),
                Text(
                  alt ?? '图片加载失败',
                  style: const TextStyle(
                    color: AppColors.textWeak,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          placeholderBuilder: (_) => const SizedBox(
            height: 200,
            child: ColoredBox(
              color: AppColors.surfaceCard,
              child: Center(child: CupertinoActivityIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建标签区域
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTagsTitle(),
        const SizedBox(height: _ContentConstants.tagsSpacing),
        _buildTagsList(),
      ],
    );
  }

  /// 构建标签标题
  Widget _buildTagsTitle() {
    return const Text(
      _ContentConstants.tagsTitle,
      style: TextStyle(
        fontSize: _ContentConstants.tagsTitleFontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// 构建标签列表
  Widget _buildTagsList() {
    return Wrap(
      spacing: _ContentConstants.tagSpacing,
      runSpacing: _ContentConstants.tagRunSpacing,
      children: guide.tags.map((tag) => _buildTag(tag)).toList(),
    );
  }

  /// 构建单个标签
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _ContentConstants.tagPaddingHorizontal,
        vertical: _ContentConstants.tagPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue
            .withValues(alpha: _ContentConstants.tagBackgroundOpacity),
        borderRadius: BorderRadius.circular(_ContentConstants.tagBorderRadius),
        border: Border.all(
          color: CupertinoColors.activeBlue
              .withValues(alpha: _ContentConstants.tagBorderOpacity),
          width: _ContentConstants.tagBorderWidth,
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: CupertinoColors.activeBlue,
          fontSize: _ContentConstants.tagFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 高亮提示构建器
class _HighlightBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.lightbulb,
            color: CupertinoColors.systemBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              element.textContent,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 警告提示构建器
class _WarningBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemYellow,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              element.textContent,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 提示构建器
class _TipBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle,
            color: CupertinoColors.systemGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              element.textContent,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 内容组件私有常量
class _ContentConstants {
  _ContentConstants._();

  // ==================== 布局尺寸 ====================

  /// 头部间距
  static const double headerSpacing = 16.0;

  /// 头部图标大小
  static const double headerIconSize = 20.0;

  /// 头部图标间距
  static const double headerIconSpacing = 8.0;

  /// 内容间距
  static const double contentSpacing = 24.0;

  /// 标签间距
  static const double tagsSpacing = 12.0;

  /// 标签水平间距
  static const double tagSpacing = 8.0;

  /// 标签垂直间距
  static const double tagRunSpacing = 8.0;

  /// 标签内边距 - 水平
  static const double tagPaddingHorizontal = 10.0;

  /// 标签内边距 - 垂直
  static const double tagPaddingVertical = 4.0;

  /// 标签圆角半径
  static const double tagBorderRadius = 12.0;

  /// 标签边框宽度
  static const double tagBorderWidth = 0.5;

  /// 引用内边距
  static const double quotePadding = 12.0;

  /// 引用圆角半径
  static const double quoteBorderRadius = 8.0;

  /// 引用边框宽度
  static const double quoteBorderWidth = 3.0;

  /// 代码块内边距
  static const double codeBlockPadding = 12.0;

  /// 代码块圆角半径
  static const double codeBlockBorderRadius = 8.0;

  /// 图片边距
  static const double imageMargin = 8.0;

  /// 图片圆角半径
  static const double imageBorderRadius = 8.0;

  // ==================== 字体大小 ====================

  /// 头部标题字体大小
  static const double headerFontSize = 18.0;

  /// 一级标题字体大小
  static const double heading1FontSize = 20.0;

  /// 二级标题字体大小
  static const double heading2FontSize = 18.0;

  /// 三级标题字体大小
  static const double heading3FontSize = 16.0;

  /// 四级标题字体大小
  static const double heading4FontSize = 15.0;

  /// 五级标题字体大小
  static const double heading5FontSize = 14.0;

  /// 六级标题字体大小
  static const double heading6FontSize = 13.0;

  /// 内容字体大小
  static const double contentFontSize = 14.0;

  /// 内容行高
  static const double contentLineHeight = 1.5;

  /// 代码字体大小
  static const double codeFontSize = 13.0;

  /// 标签标题字体大小
  static const double tagsTitleFontSize = 16.0;

  /// 标签字体大小
  static const double tagFontSize = 12.0;

  // ==================== 透明度 ====================

  /// 标签背景透明度
  static const double tagBackgroundOpacity = 0.1;

  /// 标签边框透明度
  static const double tagBorderOpacity = 0.3;

  // ==================== 文本内容 ====================

  /// 头部标题
  static const String headerTitle = '攻略内容';

  /// 标签标题
  static const String tagsTitle = '相关标签';
}
