import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tokens/tokens.dart';

/// 应用主题配置
///
/// 设计风格：专业运动风格 (方案 B)
/// - UI 框架: Cupertino (iOS 风格)
/// - 配色: 天空蓝调
/// - 界面: 列表式 + 数据卡片
/// - 组件: 方正现代 (小圆角 8px)
class AppTheme {
  AppTheme._();

  // ============ Cupertino 主题 (主要使用) ============

  /// 浅色 Cupertino 主题
  static CupertinoThemeData get cupertinoLight => const CupertinoThemeData(
        primaryColor: AppColors.primary,
        primaryContrastingColor: AppColors.onPrimary,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primary,
          textStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          actionTextStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
          ),
          navTitleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
          tabLabelTextStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      );

  // ============ Material 主题 (兼容使用) ============

  /// 浅色 Material 主题
  static ThemeData get materialLight => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // 颜色方案
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondary: AppColors.onSecondary,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),

        // 脚手架背景
        scaffoldBackgroundColor: AppColors.background,

        // AppBar 主题
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: AppTypography.navTitle,
          iconTheme: const IconThemeData(
            color: AppColors.iconPrimary,
            size: 24,
          ),
        ),

        // 卡片主题
        cardTheme: CardTheme(
          elevation: 0,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
            side: const BorderSide(color: AppColors.primary, width: 1),
            textStyle: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),

        // 输入框主题
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          hintStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.textHint),
          labelStyle: AppTypography.bodyMedium,
        ),

        // Chip 主题
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primaryContainer,
          labelStyle: AppTypography.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderSm,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),

        // 分割线主题
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          space: 1,
          thickness: 1,
        ),

        // 列表主题
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          titleTextStyle: AppTypography.bodyLarge,
          subtitleTextStyle: AppTypography.bodySmall,
          iconColor: AppColors.iconPrimary,
        ),

        // 底部导航栏主题
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.iconSecondary,
          selectedLabelStyle: AppTypography.tab,
          unselectedLabelStyle: AppTypography.tab,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // Dialog 主题
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.surface,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
          ),
          titleTextStyle: AppTypography.headlineSmall,
          contentTextStyle: AppTypography.bodyMedium,
        ),

        // BottomSheet 主题
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        ),

        // Snackbar 主题
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle:
              AppTypography.bodyMedium.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // FloatingActionButton 主题
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
        ),

        // Icon 主题
        iconTheme: const IconThemeData(
          color: AppColors.iconPrimary,
          size: 24,
        ),

        // 文字主题
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headlineLarge,
          headlineMedium: AppTypography.headlineMedium,
          headlineSmall: AppTypography.headlineSmall,
          titleLarge: AppTypography.titleLarge,
          titleMedium: AppTypography.titleMedium,
          titleSmall: AppTypography.titleSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
      );

  // ============ 深色主题 (预留) ============

  /// 深色 Cupertino 主题 (待实现)
  static CupertinoThemeData get cupertinoDark => const CupertinoThemeData(
        brightness: Brightness.dark,
        // TODO: 实现深色主题
      );

  /// 深色 Material 主题 (待实现)
  static ThemeData get materialDark => ThemeData.dark(useMaterial3: true);
}
