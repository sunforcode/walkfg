/// Walk v1 路由常量
///
/// 14 页路由定义，对应 PRD §4 页面清单。
/// 命名规范：/模块/动作，主页面用名词，操作用动词。
class AppRoutes {
  AppRoutes._();

  // ─── 首页 ───
  /// P1/P2 首页（空状态 / 有行程由 HomeScreen 内部判断）
  static const String home = '/';

  // ─── 路线 ───
  /// P3 路线发现
  static const String routeDiscovery = '/route/discovery';

  /// P4 路线详情 — 传参 routeId
  static const String routeDetail = '/route/detail';

  // ─── 行程 ───
  /// P5 创建行程 — 传参 routeId
  static const String tripCreate = '/trip/create';

  /// P6 行程详情 — 传参 tripId
  static const String tripDetail = '/trip/detail';

  /// P7 行程编辑 — 传参 tripId
  static const String tripEdit = '/trip/edit';

  // ─── 装备 ───
  /// P8 装备清单列表
  static const String gearList = '/gear/list';

  /// P9 装备清单详情 — 传参 listId
  static const String gearDetail = '/gear/detail';

  /// P10 新建装备清单
  static const String gearCreate = '/gear/create';

  // ─── 天气 ───
  /// P11 天气
  static const String weather = '/weather';

  // ─── 日历 ───
  /// P12 日历面板
  static const String calendar = '/calendar';

  // ─── 个人中心 ───
  /// P13 个人中心
  static const String profile = '/profile';

  // ─── 调试 ───
  static const String debug = '/debug';

  // ─── 全部路由名列表（用于注册） ───
  static const Set<String> all = {
    home,
    routeDiscovery,
    routeDetail,
    tripCreate,
    tripDetail,
    tripEdit,
    gearList,
    gearDetail,
    gearCreate,
    weather,
    calendar,
    profile,
    debug,
  };
}
