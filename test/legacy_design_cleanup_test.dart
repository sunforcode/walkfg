import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('confirmed unused color and typography compatibility tokens are removed',
      () {
    final colors = File('lib/theme/tokens/colors.dart').readAsStringSync();
    final typography =
        File('lib/theme/tokens/typography.dart').readAsStringSync();

    for (final name in [
      'textLight',
      'textLightSecondary',
      'textLightWeak',
      'textLightTag',
      'textTertiary',
      'textBody',
      'textSubtitle',
      'textLabel',
      'textHint',
      'textPlaceholder',
      'textDim',
      'textFaint',
      'gradientRoute =',
      'gradientAiFab =',
    ]) {
      expect(colors, isNot(contains(' $name')));
    }

    for (final name in [
      'fontFamilyMono',
      'displayBrand',
      'displayLarge',
      'displayMedium',
      'displaySmall',
      'headlineLarge',
      'headlineMedium',
      'headlineSmall',
      'titleLarge',
      'titleMedium',
      'titleSmall',
      'bodyMedium',
      'bodySmall',
      'labelLarge',
      'labelMedium',
      'labelSmall',
      'dataNumber',
      'dataNumberLarge',
      'statValue',
      'statUnit',
      'statLabel',
      'metricLabel',
      'overline',
      'buttonLarge',
    ]) {
      expect(typography, isNot(contains(' $name')));
    }
  });

  test('confirmed unused duplicate route widgets are removed', () {
    for (final path in [
      'lib/ui/page/route/widgets/route_card.dart',
      'lib/ui/page/route/widgets/route_list_card.dart',
      'lib/ui/page/route/widgets/route_map_view.dart',
      'lib/ui/page/route/widgets/route_filter_section.dart',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }
  });
}
