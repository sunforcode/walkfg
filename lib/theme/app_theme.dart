import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tokens/tokens.dart';

/// Walk 沉浸式暗色主题配置。
///
/// Cupertino 与 Material 控件共享同一组语义 Design Token。
class AppTheme {
  AppTheme._();

  // ============ Cupertino 主题 ============

  /// 应用唯一支持的 Cupertino 主题入口。
  static CupertinoThemeData get cupertino => CupertinoThemeData(
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
            fontSize: AppTypography.body.fontSize,
          ),
          actionTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.interactiveAccent,
            fontSize: AppTypography.body.fontSize,
          ),
          navTitleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textPrimary,
            fontSize: AppTypography.navTitle.fontSize,
            fontWeight: AppTypography.navTitle.fontWeight,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textPrimary,
            fontSize: AppTypography.pageTitle.fontSize,
            fontWeight: AppTypography.pageTitle.fontWeight,
          ),
          tabLabelTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textWeak,
            fontSize: 10,
          ),
        ),
      );

  // ============ Material 主题 (兼容使用) ============

  /// 应用唯一支持的 Material 主题入口。
  static ThemeData get material => ThemeData(
        fontFamily: AppTypography.fontFamily,
        useMaterial3: true,
        brightness: Brightness.dark,

        // 颜色方案
        colorScheme: ColorScheme.dark(
          primary: AppColors.interactiveAccent,
          onPrimary: AppColors.bgBase,
          secondary: AppColors.interactiveAccent,
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
            color: AppColors.textWeak,
            size: 24,
          ),
        ),

        // 卡片主题
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderPanel,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandStart,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.componentPadding,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderControl,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.interactiveAccent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.componentPadding,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderControl,
            ),
            side:
                const BorderSide(color: AppColors.interactiveAccent, width: 1),
            textStyle: AppTypography.button
                .copyWith(color: AppColors.interactiveAccent),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.interactiveAccent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.componentPadding,
              vertical: AppSpacing.md,
            ),
            textStyle: AppTypography.button
                .copyWith(color: AppColors.interactiveAccent),
          ),
        ),

        // 输入框主题
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceInput,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.componentPadding,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderControl,
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderControl,
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderControl,
            borderSide: const BorderSide(
                color: AppColors.interactiveAccentFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderControl,
            borderSide: const BorderSide(
                color: AppColors.semanticErrorBorder, width: 1),
          ),
          hintStyle: AppTypography.body.copyWith(color: AppColors.textWeak),
          labelStyle: AppTypography.body,
        ),

        // Chip 主题
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceCard,
          selectedColor: AppColors.interactiveAccentBg,
          labelStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderSmall,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),

        // 分割线主题
        dividerTheme: const DividerThemeData(
          color: AppColors.surfaceDivider,
          space: 1,
          thickness: 1,
        ),

        // 列表主题
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.componentPadding,
          ),
          titleTextStyle: AppTypography.bodyLg,
          subtitleTextStyle: AppTypography.bodySm,
          iconColor: AppColors.textWeak,
        ),

        // Dialog 主题
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.bgPanel,
          elevation: AppShadows.overlayElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderOverlay,
          ),
          titleTextStyle: AppTypography.headline,
          contentTextStyle: AppTypography.body,
        ),

        // BottomSheet 主题
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.bgPanel,
          elevation: AppShadows.panelElevation,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.overlay),
              topRight: Radius.circular(AppRadius.overlay),
            ),
          ),
        ),

        // Snackbar 主题
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceToast,
          contentTextStyle:
              AppTypography.body.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderControl,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // FloatingActionButton 主题
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.brandStart,
          foregroundColor: AppColors.textPrimary,
          elevation: AppShadows.floatingControlElevation,
          shape: const CircleBorder(),
        ),

        // Icon 主题
        iconTheme: const IconThemeData(
          color: AppColors.textWeak,
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

  /// 旧暗色主题入口，仅用于源码迁移。
  @Deprecated('Use AppTheme.cupertino')
  static CupertinoThemeData get cupertinoDark => cupertino;

  /// 旧暗色主题入口，仅用于源码迁移。
  @Deprecated('Use AppTheme.material')
  static ThemeData get materialDark => material;

  /// 在以 [CupertinoApp] 为根的应用中承载 Material 主题与消息设施。
  static Widget buildMaterialTheme(BuildContext context, Widget? child) {
    return Theme(
      data: material,
      child: ScaffoldMessenger(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
