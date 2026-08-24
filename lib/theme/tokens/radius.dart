import 'package:flutter/widgets.dart';

/// Semantic corner-radius tokens.
class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double small = 8.0;
  static const double control = 12.0;
  static const double panel = 16.0;
  static const double overlay = 24.0;
  static const double full = 9999.0;

  static const BorderRadius borderNone = BorderRadius.zero;
  static const BorderRadius borderSmall =
      BorderRadius.all(Radius.circular(small));
  static const BorderRadius borderControl =
      BorderRadius.all(Radius.circular(control));
  static const BorderRadius borderPanel =
      BorderRadius.all(Radius.circular(panel));
  static const BorderRadius borderOverlay =
      BorderRadius.all(Radius.circular(overlay));
  static const BorderRadius borderFull =
      BorderRadius.all(Radius.circular(full));

  static const BorderRadius topPanel = BorderRadius.only(
    topLeft: Radius.circular(panel),
    topRight: Radius.circular(panel),
  );
  static const BorderRadius topOverlay = BorderRadius.only(
    topLeft: Radius.circular(overlay),
    topRight: Radius.circular(overlay),
  );
  static const BorderRadius bottomControl = BorderRadius.only(
    bottomLeft: Radius.circular(control),
    bottomRight: Radius.circular(control),
  );
  static const BorderRadius leftControl = BorderRadius.only(
    topLeft: Radius.circular(control),
    bottomLeft: Radius.circular(control),
  );
  static const BorderRadius rightControl = BorderRadius.only(
    topRight: Radius.circular(control),
    bottomRight: Radius.circular(control),
  );

  static const Radius radiusSmall = Radius.circular(small);
  static const Radius radiusControl = Radius.circular(control);
  static const Radius radiusPanel = Radius.circular(panel);
  static const Radius radiusOverlay = Radius.circular(overlay);
  static const Radius radiusFull = Radius.circular(full);
}
