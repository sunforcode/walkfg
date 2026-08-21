import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tokens/tokens.dart';

/// Walk v1 主题配置
///
/// v1 固定暗色主题，基于 PRD §8.1 Design Token 体系。
/// - UI 框架: Cupertino (iOS 风格)
/// - 配色: 深蓝黑底 (#0a0a1a) + 品牌蓝渐变
/// - 界面: 列表式 + 数据卡片
class AppTheme {
  AppTheme._();

  // ============ Cupertino 主题 ============

  /// 暗色 Cupertino 主题
  static CupertinoThemeData get cupertinoDark => CupertinoThemeData(
        primaryColor: AppColors.interactiveAccent,
        primaryContrastingColor: AppColors.bgBase,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgBase,
        barBackgroundColor: AppColors.bgPanel,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.interactiveAccent,
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          actionTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.interactiveAccent,
            fontSize: 15,
          ),
          navTitleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
          tabLabelTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textHint,
            fontSize: 10,
          ),
        ),
      );

  // ============ Material 主题 (兼容使用) ============

  /// 暗色 Material 主题
  static ThemeData get materialDark => ThemeData(
        fontFamily: AppTypography.fontFamily,
        useMaterial3: true,
        brightness: Brightness.dark,

        // 颜色方案
        colorScheme: ColorScheme.dark(
          primary: AppColors.interactiveAccent,
          onPrimary: AppColors.bgBase,
          secondary: AppColors.accentSky,
          error: AppColors.error,
          onError: AppColors.bgBase,
          surface: AppColors.bgPanel,
          onSurface: AppColors.textPrimary,
        ),

        // 脚手架背景
        scaffoldBackgroundColor: AppColors.bgBase,

        // AppBar 主题
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.bgPanel,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: AppTypography.navTitle,
          iconTheme: const IconThemeData(
            color: AppColors.textBody,
            size: 24,
          ),
        ),

        // 卡片主题
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderXl,
            side: const BorderSide(color: AppColors.surfaceCardBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandStart,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderXl,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.interactiveAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderXl,
            ),
            side: const BorderSide(color: AppColors.interactiveAccent, width: 1),
            textStyle: AppTypography.button.copyWith(color: AppColors.interactiveAccent),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.interactiveAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: AppTypography.button.copyWith(color: AppColors.interactiveAccent),
          ),
        ),

        // 输入框主题
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceInput,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.surfaceCardBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.surfaceCardBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.interactiveAccentFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.semanticErrorBorder, width: 1),
          ),
          hintStyle: AppTypography.body
              .copyWith(color: AppColors.textPlaceholder),
          labelStyle: AppTypography.body,
        ),

        // Chip 主题
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceCard,
          selectedColor: AppColors.interactiveAccentBg,
          labelStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderSm,
            side: const BorderSide(color: AppColors.surfaceCardBorder, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),

        // 分割线主题
        dividerTheme: const DividerThemeData(
          color: AppColors.surfaceDivider,
          space: 1,
          thickness: 1,
        ),

        // 列表主题
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          titleTextStyle: AppTypography.bodyLg,
          subtitleTextStyle: AppTypography.bodySm,
          iconColor: AppColors.textBody,
        ),

        // Dialog 主题
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.bgPanel,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.border2xl,
          ),
          titleTextStyle: AppTypography.headline,
          contentTextStyle: AppTypography.body,
        ),

        // BottomSheet 主题
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.bgPanel,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xxl),
              topRight: Radius.circular(AppRadius.xxl),
            ),
          ),
        ),

        // Snackbar 主题
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceToast,
          contentTextStyle:
              AppTypography.body.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // FloatingActionButton 主题
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.brandStart,
          foregroundColor: AppColors.textPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderXl,
          ),
        ),

        // Icon 主题
        iconTheme: const IconThemeData(
          color: AppColors.textBody,
          size: 24,
        ),

        // 文字主题
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLg,
          displayMedium: AppTypography.displayMd,
          displaySmall: AppTypography.displaySm,
          headlineLarge: AppTypography.headline,
          headlineMedium: AppTypography.titleLg,
          headlineSmall: AppTypography.title,
          titleLarge: AppTypography.title,
          titleMedium: AppTypography.body,
          titleSmall: AppTypography.bodySm,
          bodyLarge: AppTypography.bodyLg,
          bodyMedium: AppTypography.body,
          bodySmall: AppTypography.bodySm,
          labelLarge: AppTypography.label,
          labelMedium: AppTypography.label,
          labelSmall: AppTypography.micro,
        ),
      );

  // ============ 兼容旧 API ============
  // 保留 cupertinoLight / materialLight 作为 dark 的别名，
  // 让现有调用处不报错，后续逐步清理。

  static CupertinoThemeData get cupertinoLight => cupertinoDark;
  static ThemeData get materialLight => materialDark;
}