import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'radius.dart';

/// Semantic elevation and shadow tokens for the dark interface.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];
  static const List<BoxShadow> floatingControl = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> panel = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  static const List<BoxShadow> bottomNavigation = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  static const double floatingControlElevation = 4.0;
  static const double panelElevation = 16.0;
  static const double overlayElevation = 24.0;

  static final List<BoxShadow> accentGlow = [
    BoxShadow(
      color: AppColors.interactiveAccent.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static final List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static final List<BoxShadow> errorGlow = [
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: AppRadius.borderSmall,
    boxShadow: panel,
  );
  static final BoxDecoration cardFlatDecoration = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: AppRadius.borderSmall,
    border: Border.all(color: AppColors.border),
  );
  static final BoxDecoration popupDecoration = BoxDecoration(
    color: AppColors.bgPanel,
    borderRadius: AppRadius.borderControl,
    boxShadow: overlay,
  );
  static final BoxDecoration bottomSheetDecoration = BoxDecoration(
    color: AppColors.bgPanel,
    borderRadius: AppRadius.topPanel,
    boxShadow: overlay,
  );
}
