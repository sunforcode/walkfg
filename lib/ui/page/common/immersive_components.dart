import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../theme/tokens/blur.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/radius.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/typography.dart';

/// The two image treatments proven by the Home and Route Discovery screens.
enum ImmersiveHeroVariant { fullBleed, editorial }

/// Composes an immersive image, the shared hero scrim, and page-owned overlay.
class ImmersiveHero extends StatelessWidget {
  final Widget image;
  final Widget overlay;
  final ImmersiveHeroVariant variant;

  const ImmersiveHero({
    super.key,
    required this.image,
    required this.overlay,
    this.variant = ImmersiveHeroVariant.fullBleed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: switch (variant) {
        ImmersiveHeroVariant.fullBleed => AppRadius.borderNone,
        ImmersiveHeroVariant.editorial => AppRadius.borderOverlay,
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.heroScrim),
          ),
          overlay,
        ],
      ),
    );
  }
}

/// The shared copy hierarchy used over immersive imagery.
class HeroTitleOverlay extends StatelessWidget {
  final Widget? eyebrow;
  final String title;
  final Widget? supportingText;
  final Widget? metrics;

  const HeroTitleOverlay({
    super.key,
    this.eyebrow,
    required this.title,
    this.supportingText,
    this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = MediaQuery.sizeOf(context).width < 360
        ? AppTypography.heroTitle.copyWith(fontSize: 40)
        : AppTypography.heroTitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow case final eyebrow?) ...[
          eyebrow,
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        if (supportingText case final supportingText?) ...[
          const SizedBox(height: AppSpacing.sm),
          supportingText,
        ],
        if (metrics case final metrics?) ...[
          const SizedBox(height: AppSpacing.lg),
          metrics,
        ],
      ],
    );
  }
}

/// Already-formatted metric copy supplied by a business screen.
class MetricData {
  final String value;
  final String unit;

  const MetricData({required this.value, required this.unit});
}

/// Displays immersive metrics with the fixed design-system wrapping behavior.
class MetricGroup extends StatelessWidget {
  final List<MetricData> metrics;

  const MetricGroup({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.sm,
      children: [for (final metric in metrics) _Metric(metric: metric)],
    );
  }
}

class _Metric extends StatelessWidget {
  final MetricData metric;

  const _Metric({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metric.value, style: AppTypography.metricValue),
        Text(metric.unit, style: AppTypography.metricUnit),
      ],
    );
  }
}

/// The shared compact glass action used by immersive page navigation controls.
class GlassIconAction extends StatelessWidget {
  final String semanticLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  const GlassIconAction({
    super.key,
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 44,
        child: ClipRRect(
          borderRadius: AppRadius.borderFull,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.control,
              sigmaY: AppBlur.control,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(44),
              onPressed: onPressed,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: AppColors.border),
                ),
                child: SizedBox.expand(
                  child: Icon(icon, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
