import 'package:flutter/cupertino.dart';

/// 攻略详情页面常量定义
///
/// 包含页面中使用的所有常量、文本和配置信息
class GuideDetailConstants {
  // 私有构造函数，防止实例化
  GuideDetailConstants._();

  // ==================== 页面配置 ====================

  /// 页面标题
  static const String pageTitle = '徒步攻略';

  /// 滚动阈值 - 控制导航栏标题显示
  static const double scrollThreshold = 180.0;

  // ==================== 动画配置 ====================

  /// 滚动动画持续时间
  static const Duration scrollAnimationDuration = Duration(milliseconds: 500);

  /// 滚动动画曲线
  static const Curve scrollAnimationCurve = Curves.easeInOut;

  // ==================== 布局尺寸 ====================

  /// 底部操作栏高度
  static const double bottomActionBarHeight = 80.0;

  /// 底部间距 - 为底部操作栏留出空间
  static const double bottomSpacing = 100.0;

  /// 水平内边距
  static const double horizontalPadding = 16.0;

  /// 垂直内边距
  static const double verticalPadding = 16.0;

  // ==================== 文本内容 ====================

  /// 加载错误重试文本
  static const String retryText = '重试';

  /// 点赞成功提示
  static const String likeSuccessMessage = '已点赞';

  /// 取消点赞提示
  static const String unlikeSuccessMessage = '已取消点赞';

  /// 收藏成功提示
  static const String bookmarkSuccessMessage = '已收藏';

  /// 取消收藏提示
  static const String unbookmarkSuccessMessage = '已取消收藏';

  /// 分享功能开发中提示
  static const String shareInDevelopmentMessage = '分享功能开发中';

  /// 评论功能开发中提示
  static const String commentInDevelopmentMessage = '评论功能开发中';

  // ==================== 错误处理 ====================

  /// 网络错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';

  /// 数据加载失败消息
  static const String dataLoadErrorMessage = '数据加载失败，请稍后重试';

  /// 通用错误消息
  static const String genericErrorMessage = '操作失败，请稍后重试';
}
