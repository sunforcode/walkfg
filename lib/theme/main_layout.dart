import 'package:flutter/cupertino.dart';

import '../ui/page/home/home_screen.dart';

/// Main v1 shell.
///
/// Walk v1 intentionally keeps only the current route surface. Route selection
/// is opened from the home empty/replace-route action.
class MainLayout extends StatelessWidget {
  /// Preserved for callers that still pass an initial tab index.
  final int initialIndex;

  /// Constructor.
  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
