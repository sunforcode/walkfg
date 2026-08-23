/// Semantic blur radii for translucent controls and overlays.
class AppBlur {
  AppBlur._();

  /// Compact glass controls such as navigation actions.
  static const double control = 10.0;

  /// Larger glass panels layered over immersive imagery.
  static const double overlay = 20.0;
}
