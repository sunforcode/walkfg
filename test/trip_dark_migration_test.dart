import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Trip UI no longer uses route-detail sheet tokens', () {
    final files = Directory('lib/ui/page/trip')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final violations = <String>[];
    for (final file in files) {
      final source = file.readAsStringSync();
      if (source.contains('AppColors.sheet')) {
        violations.add('${file.path}: AppColors.sheet');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Trip must not reuse Route Detail light-sheet tokens:\n'
          '${violations.join('\n')}',
    );
  });

  test('Trip list uses shared dark primitives instead of private light styles',
      () {
    final source =
        File('lib/ui/page/trip/trip_list_screen.dart').readAsStringSync();
    final required = <String>[
      'NetworkImageWithFallback(',
      'AppColors.bgBase',
      'AppColors.surfaceCard',
      'AppColors.border',
      'AppTypography.',
      'AppSpacing.',
      'AppRadius.',
    ];
    final forbidden = <String>[
      'Image.network(',
      'CupertinoColors.systemBackground',
      'CupertinoColors.systemGrey5',
      'CupertinoColors.systemGrey6',
      'TextStyle(',
      'BorderRadius.circular(',
      'BoxShadow(',
    ];

    expect(
      required.where((token) => !source.contains(token)),
      isEmpty,
      reason: 'Trip list must compose shared dark UI primitives.',
    );
    expect(
      forbidden.where(source.contains),
      isEmpty,
      reason: 'Trip list must not retain private light-card styling.',
    );
  });
}
