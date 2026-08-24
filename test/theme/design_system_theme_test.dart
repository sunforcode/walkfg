import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/app.dart';
import 'package:walk/theme/app_theme.dart';
import 'package:walk/theme/main_layout.dart';
import 'package:walk/theme/tokens/tokens.dart';

void main() {
  group('immersive dark design tokens', () {
    test('colors match the semantic dark palette', () {
      expect(AppColors.bgBase, const Color(0xFF0A0A1A));
      expect(AppColors.bgPanel, const Color(0xFF1A1A2E));
      expect(AppColors.surfaceCard, const Color(0x0FFFFFFF));
      expect(AppColors.surfaceGlass, const Color(0x1FFFFFFF));
      expect(AppColors.border, const Color(0x1AFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.textSecondary, const Color(0xB3FFFFFF));
      expect(AppColors.textWeak, const Color(0x80FFFFFF));
      expect(AppColors.interactiveAccent, const Color(0xFF64C8FF));
      expect(AppColors.success, const Color(0xFF4CAF50));
      expect(AppColors.warning, const Color(0xFFFFB74D));
      expect(AppColors.error, const Color(0xFFFF6464));
      expect(AppColors.info, AppColors.interactiveAccent);
      expect(AppColors.heroScrim.colors, const [
        Color(0x0A03080C),
        Color(0xE603080C),
      ]);
      expect(AppColors.heroScrim.begin, Alignment.topCenter);
      expect(AppColors.heroScrim.end, Alignment.bottomCenter);
    });

    test('spacing and radius expose one semantic scale', () {
      expect(
        const [
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
          AppSpacing.hero,
        ],
        const [4, 8, 12, 16, 24, 32, 48, 80],
      );
      expect(AppSpacing.pageHorizontal, 16);
      expect(AppSpacing.heroHorizontal, 20);
      expect(AppSpacing.componentPadding, 16);
      expect(AppSpacing.listItemGap, 12);
      expect(AppSpacing.sectionGap, 24);

      expect(
        const [
          AppRadius.none,
          AppRadius.small,
          AppRadius.control,
          AppRadius.panel,
          AppRadius.overlay,
          AppRadius.full,
        ],
        const [0, 8, 12, 16, 24, 9999],
      );
      expect(AppRadius.borderSmall, BorderRadius.circular(8));
      expect(AppRadius.borderControl, BorderRadius.circular(12));
      expect(AppRadius.borderPanel, BorderRadius.circular(16));
      expect(AppRadius.borderOverlay, BorderRadius.circular(24));
    });

    test('legacy conflicts and fixed safe-area tokens are removed', () {
      final spacing = File('lib/theme/tokens/spacing.dart').readAsStringSync();
      final radius = File('lib/theme/tokens/radius.dart').readAsStringSync();
      final shadows = File('lib/theme/tokens/shadows.dart').readAsStringSync();
      final motion = File('lib/theme/tokens/motion.dart').readAsStringSync();
      final colors = File('lib/theme/tokens/colors.dart').readAsStringSync();

      for (final legacyName in [
        'spaceMd',
        'spaceLg',
        'safeTop',
        'safeBottom',
        'bottomSafeArea',
        'cardPadding',
        'sectionSpacing',
      ]) {
        expect(spacing, isNot(contains(' $legacyName')));
      }
      for (final legacyName in [
        'borderMd',
        'borderLg',
        'borderXl',
        'border2xl'
      ]) {
        expect(radius, isNot(contains(' $legacyName')));
      }
      for (final legacyName in [
        'cardElevation1',
        'cardElevation2',
        'cardElevation3'
      ]) {
        expect(shadows, isNot(contains(' $legacyName')));
      }
      for (final legacyName in ['instant', 'normal', 'slow', 'moderate']) {
        expect(motion, isNot(contains(' $legacyName')));
      }
      for (final legacyName in [
        'primary =',
        'background =',
        'surface =',
        'card =',
        'divider =',
        'textOnDark =',
        'primaryGradient =',
      ]) {
        expect(colors, isNot(contains(legacyName)));
      }
    });

    test('typography exposes immersive hierarchy and metric styles', () {
      expect(AppTypography.heroTitle.fontSize, 48);
      expect(AppTypography.heroTitle.fontWeight, FontWeight.w700);
      expect(AppTypography.heroTitle.height, 1);
      expect(AppTypography.heroSubtitle.fontSize, 16);
      expect(AppTypography.displayTitle.fontSize, 32);
      expect(AppTypography.pageTitle.fontSize, 28);
      expect(AppTypography.sectionTitle.fontSize, 20);
      expect(AppTypography.cardTitle.fontSize, 18);
      expect(AppTypography.bodyLarge.fontSize, 16);
      expect(AppTypography.label.fontWeight, FontWeight.w500);
      expect(AppTypography.metricValue.fontSize, 18);
      expect(
        AppTypography.metricValue.fontFeatures,
        const [FontFeature.tabularFigures()],
      );
      expect(AppTypography.metricUnit.fontSize, 12);
    });

    test('effects expose semantic shadow blur and motion tokens', () {
      expect(AppShadows.floatingControl, isNotEmpty);
      expect(AppShadows.panel, isNotEmpty);
      expect(AppShadows.overlay, isNotEmpty);
      expect(AppBlur.control, 10);
      expect(AppBlur.overlay, 20);
      expect(AppMotion.press, const Duration(milliseconds: 100));
      expect(AppMotion.feedback, const Duration(milliseconds: 200));
      expect(AppMotion.transition, const Duration(milliseconds: 300));
      expect(AppMotion.drawer, const Duration(milliseconds: 350));
    });
  });

  test('deprecated dark theme names forward to semantic entries', () {
    expect(AppTheme.cupertinoDark, AppTheme.cupertino);
    expect(AppTheme.materialDark, AppTheme.material);
  });

  testWidgets('real app root provides inherited dark themes and messenger',
      (tester) async {
    await tester.pumpWidget(const App());

    final context = tester.element(find.byType(MainLayout));
    final cupertino = CupertinoTheme.of(context);
    final material = Theme.of(context);
    expect(cupertino.brightness, Brightness.dark);
    expect(cupertino.scaffoldBackgroundColor, AppColors.bgBase);
    expect(material.brightness, Brightness.dark);
    expect(material.scaffoldBackgroundColor, AppColors.bgBase);
    expect(material.colorScheme.primary, AppColors.interactiveAccent);
    expect(material.colorScheme.onSurface, AppColors.textPrimary);
    expect(ScaffoldMessenger.maybeOf(context), isNotNull);
  });

  test('theme components use semantic design values', () {
    final theme = AppTheme.material;
    expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    expect(
      (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
      AppRadius.borderPanel,
    );
    expect(
      theme.elevatedButtonTheme.style?.padding?.resolve(<WidgetState>{}),
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.componentPadding,
        vertical: AppSpacing.md,
      ),
    );
    expect(theme.dialogTheme.elevation, AppShadows.overlayElevation);
    expect(theme.bottomSheetTheme.elevation, AppShadows.panelElevation);
  });
}
