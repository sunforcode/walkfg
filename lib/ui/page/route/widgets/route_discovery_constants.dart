/// 路线发现页面常量定义
///
/// 包含页面中使用的所有常量、文本和配置信息
class RouteDiscoveryConstants {
  // 私有构造函数，防止实例化
  RouteDiscoveryConstants._();

  // ==================== 页面配置 ====================

  /// 页面标题
  static const String pageTitle = '探索路线';

  /// 默认过滤器
  static const String defaultFilter = '全部';

  /// 过滤器列表
  static const List<String> filters = [
    '全部',
    '徒步',
    '骑行',
    '露营',
    '攀岩',
    '城市',
    '山地',
    '海滨',
  ];

  // ==================== 动画配置 ====================

  /// 动画持续时间
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// 地图收起时的高度
  static const double mapCollapsedHeight = 200.0;

  /// 地图展开时的高度
  static const double mapExpandedHeight = 400.0;

  // ==================== 布局尺寸 ====================

  /// 水平内边距
  static const double horizontalPadding = 16.0;

  /// 分区顶部内边距
  static const double sectionTopPadding = 16.0;

  /// 分区底部内边距
  static const double sectionBottomPadding = 12.0;

  /// 水平列表高度
  static const double horizontalListHeight = 280.0;

  /// 加载视图高度
  static const double loadingHeight = 200.0;

  /// 底部间距
  static const double bottomSpacing = 30.0;

  /// 按钮高度
  static const double buttonHeight = 44.0;

  /// 按钮圆角半径
  static const double buttonBorderRadius = 10.0;

  // ==================== 字体大小 ====================

  /// 分区标题字体大小
  static const double sectionTitleFontSize = 20.0;

  /// 分区副标题字体大小
  static const double sectionSubtitleFontSize = 14.0;

  /// 查看全部文字大小
  static const double viewAllFontSize = 14.0;

  /// 查看全部图标大小
  static const double viewAllIconSize = 14.0;

  // ==================== 文本内容 ====================

  /// 热门路线标题
  static const String popularRoutesTitle = '热门路线';

  /// 热门路线副标题
  static const String popularRoutesSubtitle = '大家都在走的路线';

  /// 当季路线标题
  static const String seasonalRoutesTitle = '当季精选';

  /// 当季路线副标题
  static const String seasonalRoutesSubtitle = '适合当前季节的最佳路线';

  /// 全部路线标题
  static const String allRoutesTitle = '全部路线';

  /// 全部路线副标题
  static const String allRoutesSubtitle = '发现更多精彩路线';

  /// 查看全部文本
  static const String viewAllText = '查看全部';

  /// 查看更多文本
  static const String viewMoreText = '查看更多路线';

  /// 加载错误消息
  static const String loadErrorMessage = '加载失败，请稍后再试';

  /// 空路线标题
  static const String emptyRoutesTitle = '暂无路线';

  /// 空路线副标题
  static const String emptyRoutesSubtitle = '敬请期待更多精彩路线';

  // ==================== 数据配置 ====================

  /// 最大显示路线数量
  static const int maxDisplayRoutes = 6;
}
