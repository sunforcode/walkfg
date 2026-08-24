import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const utilityScaffoldPages = [
    'lib/ui/page/weather/weather_screen.dart',
    'lib/ui/page/profile/profile_screen.dart',
    'lib/ui/page/search/route_search_page.dart',
    'lib/ui/page/calendar/calendar_screen.dart',
    'lib/ui/page/profile/login_screen.dart',
    'lib/ui/page/profile/auth/register_screen.dart',
    'lib/ui/page/profile/auth/forgot_password_screen.dart',
  ];

  test('ordinary utility pages compose UtilityPageScaffold', () {
    final violations = <String>[];

    for (final path in utilityScaffoldPages) {
      final source = File(path).readAsStringSync();
      if (!source.contains('UtilityPageScaffold(')) {
        violations.add(path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Utility pages must use the shared dark scaffold:\n'
          '${violations.join('\n')}',
    );
  });

  test('utility page navigation and headings use semantic typography', () {
    final headingPages = [
      'lib/ui/page/weather/weather_screen.dart',
      'lib/ui/page/search/route_search_page.dart',
      'lib/ui/page/calendar/calendar_screen.dart',
      'lib/ui/page/profile/login_screen.dart',
      'lib/ui/page/profile/auth/register_screen.dart',
      'lib/ui/page/profile/auth/forgot_password_screen.dart',
    ];
    final violations = <String>[];

    for (final path in utilityScaffoldPages) {
      final source = File(path).readAsStringSync();
      if (!source.contains('UtilityPageScaffold(')) {
        violations.add('$path: missing shared navTitle');
      }
    }
    for (final path in headingPages) {
      final source = File(path).readAsStringSync();
      if (!source.contains('AppTypography.pageTitle') &&
          !source.contains('AppTypography.sectionTitle')) {
        violations.add('$path: missing pageTitle/sectionTitle');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data-driven utility pages reuse shared async states', () {
    final profile =
        File('lib/ui/page/profile/profile_screen.dart').readAsStringSync();
    final search =
        File('lib/ui/page/search/route_search_page.dart').readAsStringSync();

    expect(profile, contains('LoadingIndicator('));
    expect(profile, contains('ErrorMessageWidget('));
    expect(search, contains('LoadingIndicator('));
    expect(search, contains('ErrorMessageWidget('));
    expect(search, contains('EmptyContentWidget('));
  });

  test('route search cards use dark semantic design tokens', () {
    final search =
        File('lib/ui/page/search/route_search_page.dart').readAsStringSync();

    expect(search, contains('AppColors.surfaceCard'));
    expect(search, contains('AppColors.border'));
    expect(search, contains('AppRadius.'));
    expect(search, contains('AppSpacing.'));
    expect(search, contains('AppTypography.'));
    expect(search, contains('AppShadows.'));
    expect(search, isNot(contains('CupertinoColors.white')));
    expect(search, isNot(contains('TextStyle(')));
    expect(search, isNot(contains('BorderRadius.circular(')));
    expect(search, isNot(contains('BoxShadow(')));
  });
}
