import 'package:flutter/material.dart';

/// Walk v1 Design Token — 颜色
///
/// 本文件是 Walk v1 唯一的颜色参数定义源（PRD §8.1.1 + §8.1.2）。
/// 三层结构：Global Token（原始值）→ Alias Token（语义化）→ 组件级快捷方式。
/// 逐页规格只引用 token 名，不再写硬编码值。
class AppColors {
  AppColors._();

  // ============================================================
  //  Global Token — 原始色值 (PRD §8.1.1)
  // ============================================================

  // ---- 背景色 ----
  static const Color bgBase = Color(0xFF0a0a1a);
  static const Color bgMap = Color(0xFF0d1b2a);
  static const Color bgGradientEnd = Color(0xFF1b2838);
  static const Color bgRouteStart = Color(0xFF0d1f18);
  static const Color bgRouteMid = Color(0xFF07130f);
  static const Color bgRouteEnd = Color(0xFF040c08);
  static const Color bgPanel = Color(0xFF1a1a2e);
  static const Color bgDrawer = Color(0xFF111122);
  static const Color bgLight = Color(0xFFffffff);

  // ---- 强调色 ----
  static const Color accentBlue = Color(0xFF64C8FF);
  static const Color accentSky = Color(0xFF88BBFF);

  // ---- 品牌渐变色 ----
  static const Color brandStart = Color(0xFF3b82f6);
  static const Color brandEnd = Color(0xFF6366f1);
  static const Color aiStart = Color(0xFF8b5cf6);
  static const Color aiEnd = Color(0xFF3b82f6);

  // ---- 状态色 ----
  static const Color statusPlanning = Color(0xFFfbbf24);
  static const Color statusConfirmed = Color(0xFF60a5fa);
  static const Color statusProgress = Color(0xFF4ade80);
  static const Color statusCompleted = Color(0xFFc084fc);
  static const Color statusCancelled = Color(0xFFf87171);

  // ---- 语义色 ----
  static const Color error = Color(0xFFFF6464);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = interactiveAccent;

  // ============================================================
  //  Alias Token — 语义化 (PRD §8.1.2)
  // ============================================================

  // ---- 核心语义层级 ----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textWeak = Color(0x80FFFFFF);
  static const Color surfaceCard = Color(0x0FFFFFFF);
  static const Color surfaceGlass = Color(0x1FFFFFFF);
  static const Color border = Color(0x1AFFFFFF);
  static const Color interactiveAccent = Color(0xFF64C8FF);
  static const LinearGradient heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x0A03080C), Color(0xE603080C)],
  );

  // ---- 背景层级 ----
  static const Color surfaceCardHover =
      Color(0x14FFFFFF); // rgba(255,255,255,.08)
  static const Color surfaceCardBorder =
      Color(0x0FFFFFFF); // rgba(255,255,255,.06)
  static const Color surfaceInput = Color(0x0AFFFFFF); // rgba(255,255,255,.04)
  static const Color surfaceInputFocus =
      Color(0x0A64C8FF); // rgba(100,200,255,.04)
  static const Color surfaceDivider =
      Color(0x0AFFFFFF); // rgba(255,255,255,.04)
  static const Color surfaceOverlay = Color(0x80000000); // rgba(0,0,0,.5)
  static const Color surfaceToast = Color(0xCC000000); // rgba(0,0,0,.8)

  // ---- 交互色 ----
  static const Color interactiveAccentSoft =
      Color(0x9964C8FF); // rgba(100,200,255,.6)
  static const Color interactiveAccentBg =
      Color(0x1F64C8FF); // rgba(100,200,255,.12)
  static const Color interactiveAccentFocus =
      Color(0x4D64C8FF); // rgba(100,200,255,.3)
  static const Color interactiveCta =
      Color(0x1FFFFFFF); // rgba(255,255,255,.12)
  static const Color interactiveCtaBorder =
      Color(0x33FFFFFF); // rgba(255,255,255,.2)

  // ---- 状态色 Alias ----
  static const Color statusPlanningBg =
      Color(0x26F59E0B); // rgba(245,158,11,.15)
  static const Color statusPlanningText = Color(0xFFfbbf24);
  static const Color statusConfirmedBg =
      Color(0x263B82F6); // rgba(59,130,246,.15)
  static const Color statusConfirmedText = Color(0xFF60a5fa);
  static const Color statusCompletedBg =
      Color(0x1F22C55E); // rgba(34,197,94,.12)
  static const Color statusCompletedText = Color(0xFF4ade80);
  static const Color statusCancelledBg =
      Color(0x1AEF4444); // rgba(239,68,68,.1)
  static const Color statusCancelledText = Color(0xFFf87171);
  static const Color statusPreparingBg =
      Color(0x1F3B82F6); // rgba(59,130,246,.12)
  static const Color statusPreparingText = Color(0xFF60a5fa);

  // ---- 语义色 Alias ----
  static const Color semanticErrorBg = Color(0x14EF4444); // rgba(239,68,68,.08)
  static const Color semanticErrorBorder =
      Color(0x66EF4444); // rgba(239,68,68,.4)
  static const Color semanticErrorText =
      Color(0x99EF4444); // rgba(239,68,68,.6)
  static const Color semanticWarningBg =
      Color(0x14F59E0B); // rgba(245,158,11,.08)
  static const Color semanticSuccessBg =
      Color(0x1A22C55E); // rgba(34,197,94,.1)

  // ---- 轨迹色 ----
  static const Color trailOuter = Color(0x2664C8FF); // rgba(100,200,255,.15)
  static const Color trailInner = Color(0xCC64C8FF); // rgba(100,200,255,.8)
  static const Color trailStart = Color(0xCC64C8FF); // rgba(100,200,255,.8)
  static const Color trailEnd = Color(0xE6EF4444); // rgba(239,68,68,.9)

  // ---- 功能图标底色 ----
  static const Color iconBgRoute = Color(0x1F64C8FF); // rgba(100,200,255,.12)
  static const Color iconBgTrip = Color(0x1F78B4FF); // rgba(120,180,255,.12)
  static const Color iconBgWeather = Color(0x1FFFC850); // rgba(255,200,80,.12)
  static const Color iconBgEquipment =
      Color(0x1F8CC864); // rgba(140,200,100,.12)
  static const Color iconBgCalendar =
      Color(0x1FFFA078); // rgba(255,160,120,.12)
  static const Color iconBgStatistics =
      Color(0x1FB482FF); // rgba(180,130,255,.12)
  static const Color iconBgNavigation =
      Color(0x1F64B4FF); // rgba(100,180,255,.12)
  static const Color iconBgNearby = Color(0x1FFF8C78); // rgba(255,140,120,.12)

  // ============================================================
  //  渐变 (PRD §8.1.2 渐变段)
  // ============================================================

  /// 主按钮渐变 CTA
  static const LinearGradient gradientCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandStart, brandEnd],
  );

  /// 首页空态渐变
  static const LinearGradient gradientHome = LinearGradient(
    begin: Alignment(-0.5, -1.0),
    end: Alignment(0.5, 1.0),
    stops: [0.0, 0.4, 1.0],
    colors: [bgBase, bgMap, bgGradientEnd],
  );

  /// 路线发现径向渐变（PRD P3 §3.1 — radial-gradient ellipse at 50% 30%）
  static const RadialGradient gradientRouteRadial = RadialGradient(
    center: Alignment(0.0, -0.4), // 50% horizontal, 30% vertical
    radius: 0.9,
    stops: [0.0, 0.5, 1.0],
    colors: [bgRouteStart, bgRouteMid, bgRouteEnd],
  );

  // ---- P3 路线发现 绿色系 (PRD §7.1) ----
  static const Color accentGreenBright =
      Color(0xB3B4FFB4); // rgba(180,255,180,.7) 区域标签
  static const Color accentGreenSoft =
      Color(0x80B4FFB4); // rgba(180,255,180,.5) 副标题
  static const Color accentGreenFaint =
      Color(0x26B4FFB4); // rgba(180,255,180,.15) 出发按钮背景
  static const Color accentGreenArrow =
      Color(0xCCB4FFB4); // rgba(180,255,180,.8) 出发箭头
  static const Color contourLine = Color(
      0x0FB4FFB4); // rgba(180,255,180,.06) 整体 opacity × rgba(180,255,180,.4)

  // ---- P3 卡片 (PRD §7.1) ----
  static const Color cardPressed =
      Color(0x1AFFFFFF); // rgba(255,255,255,.1) 卡片 hover/按下
  static const Color pillBg = Color(0x14FFFFFF); // rgba(255,255,255,.08) 指标药丸背景
  static const Color thumbStart =
      Color(0x1464C8FF); // rgba(100,200,255,.08) 缩略图渐变起
  static const Color thumbEnd =
      Color(0x0F8CC864); // rgba(140,200,100,.06) 缩略图渐变止

  // ---- 交互状态 ----
  static const Color pressed = Color(0x0AFFFFFF);
  static const Color hovered = Color(0x05FFFFFF);
  static const Color focused = interactiveAccent;
  static const Color dragging = Color(0x14FFFFFF);
  static const Color selected = Color(0x14FFFFFF);

  // ---- 天气渐变 (保留兼容) ----
  static const LinearGradient weatherSunnyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
  static const LinearGradient weatherCloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF64748B), Color(0xFF475569)],
  );
  static const LinearGradient weatherRainyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
  );
  static const LinearGradient weatherSnowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBAE6FD), Color(0xFF38BDF8)],
  );
  static const LinearGradient weatherFoggyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
  );
  static const LinearGradient weatherWindyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
  );
  static const LinearGradient weatherDefaultGradient = gradientCta;

  // ---- 调色板 (保留兼容) ----
  static const List<Color> blueColors = [
    Color(0xFF3b82f6),
    Color(0xFF0EA5E9),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF2563EB),
    Color(0xFF0284C7),
  ];

  static const List<Color> tripColors = [
    Color(0xFF16a34a),
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
    Color(0xFF86EFAC),
    Color(0xFF15803D),
    Color(0xFF34D399),
  ];

  // ============================================================
  //  P4 路线详情 — 底部抽屉亮色模式 Token (PRD §7.1)
  // ============================================================

  // ---- 抽屉背景 ----
  static const Color sheetBg = Color(0xFFFFFFFF); // #ffffff
  static const Color sheetTextPrimary = Color(0xFF1a1a1a); // #1a1a1a
  static const Color sheetTextSecondary = Color(0xFF888888); // #888888
  static const Color sheetTextWeak = Color(0xFFaaaaaa); // #aaaaaa
  static const Color sheetTextTag = Color(0xFF555555); // #555555

  // ---- 抽屉分割线 / 手柄 ----
  static const Color sheetDivider = Color(0x0F000000); // rgba(0,0,0,.06)
  static const Color sheetDragHandle = Color(0x26000000); // rgba(0,0,0,.15)

  // ---- 抽屉标签底色 ----
  static const Color sheetTagBg = Color(0x0D000000); // rgba(0,0,0,.05)

  // ---- 横滑卡片底色 ----
  static const Color sheetCardBg = Color(0x08000000); // rgba(0,0,0,.03)

  // ---- 徽标色 ----
  static const Color badgeEssentialBg =
      Color(0x1AEF4444); // rgba(239,68,68,.10)
  static const Color badgeEssentialText = Color(0xFFdc2626); // #dc2626
  static const Color badgeRecommendedBg =
      Color(0x1AF59E0B); // rgba(245,158,11,.10)
  static const Color badgeRecommendedText = Color(0xFFd97706); // #d97706
  static const Color badgeVerifiedBg = Color(0x1A22C55E); // rgba(34,197,94,.10)
  static const Color badgeVerifiedText = Color(0xFF16a34a); // #16a34a
  static const Color badgeBlueBg = Color(0x1A3B82F6); // rgba(59,130,246,.10)
  static const Color badgeBlueText = Color(0xFF2563eb); // #2563eb

  // ---- 图标按钮边框 ----
  static const Color iconBtnBorder = Color(0x14000000); // rgba(0,0,0,.08)

  // ---- 返回按钮 ----
  static const Color navBackBg = Color(0x66000000); // rgba(0,0,0,.40)
  static const double navBackBlur = 10.0; // backdrop-filter:blur(10px)

  // ============================================================
  //  工具方法
  // ============================================================

  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color getBlueColor(int index) {
    return blueColors[index % blueColors.length];
  }

  static Color getTripColor(int index) {
    return tripColors[index % tripColors.length];
  }

  static LinearGradient getWeatherGradient(String? condition) {
    if (condition == null || condition.isEmpty) {
      return weatherDefaultGradient;
    }
    final lower = condition.toLowerCase();
    if (lower.contains('晴') || lower.contains('sunny')) {
      return weatherSunnyGradient;
    } else if (lower.contains('多云') ||
        lower.contains('阴') ||
        lower.contains('cloudy')) {
      return weatherCloudyGradient;
    } else if (lower.contains('雨') || lower.contains('rain')) {
      return weatherRainyGradient;
    } else if (lower.contains('雪') || lower.contains('snow')) {
      return weatherSnowGradient;
    } else if (lower.contains('雾') || lower.contains('fog')) {
      return weatherFoggyGradient;
    } else if (lower.contains('风') || lower.contains('wind')) {
      return weatherWindyGradient;
    }
    return weatherDefaultGradient;
  }
}
