import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/ui/page/guide/widgets/guide_action_bar_widget.dart';

void main() {
  final guideDirectory = Directory('lib/ui/page/guide');
  final guideFiles = guideDirectory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('Guide UI uses shared dark tokens instead of private light styles', () {
    final violations = <String>[];
    for (final file in guideFiles) {
      final source = file.readAsStringSync();
      for (final token in [
        'CupertinoColors.systemBackground',
        'CupertinoColors.systemGrey6',
        'CupertinoColors.label',
        'CupertinoColors.secondaryLabel',
        'CupertinoColors.separator',
        'Image.network(',
        'NetworkImage(',
      ]) {
        if (source.contains(token)) {
          violations.add('${file.path}: $token');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Guide surfaces, copy, and remote images must use shared '
          'semantic primitives:\n${violations.join('\n')}',
    );
  });

  test('Guide action bar uses shared glass and control tokens', () {
    final source = File(
      'lib/ui/page/guide/widgets/guide_action_bar_widget.dart',
    ).readAsStringSync();

    for (final contract in [
      'AppBlur.control',
      'AppColors.surfaceGlass',
      'AppColors.border',
      'AppRadius.borderFull',
      'AppSpacing.pageHorizontal',
      'AppTypography.label',
    ]) {
      expect(source, contains(contract), reason: 'Missing $contract');
    }

    expect(source, isNot(contains('_ActionBarConstants.blurSigma')));
    expect(source, isNot(contains('_ActionBarConstants.backgroundOpacity')));
    expect(
      source,
      isNot(contains('_ActionBarConstants.buttonBackgroundOpacity')),
    );
  });

  test('Guide remote imagery uses NetworkImageWithFallback', () {
    final imageOwners = [
      'lib/ui/page/guide/cards/guide_card.dart',
      'lib/ui/page/guide/widgets/guide_author_widget.dart',
      'lib/ui/page/guide/widgets/guide_content_widget.dart',
      'lib/ui/page/guide/widgets/guide_cover_widget.dart',
      'lib/ui/page/guide/widgets/guide_overview_widget.dart',
      'lib/ui/page/guide/widgets/guide_related_widget.dart',
    ];

    for (final path in imageOwners) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        contains('NetworkImageWithFallback'),
        reason: '$path must delegate remote image states to the shared widget',
      );
    }
  });

  testWidgets('Guide action bar preserves all four callbacks', (tester) async {
    var comments = 0;
    var likes = 0;
    var bookmarks = 0;
    var shares = 0;
    final now = DateTime(2026);
    final guide = GuideModel(
      id: 'guide-1',
      title: 'Guide',
      content: 'Content',
      author: 'Author',
      authorId: 'author-1',
      likes: 1,
      views: 2,
      publishDate: now,
      updateDate: now,
      iconCode: 'mountain',
      tags: const [],
      location: 'Trail',
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GuideActionBarWidget(
              guide: guide,
              isLiked: false,
              isBookmarked: false,
              onComment: () => comments++,
              onLike: () => likes++,
              onBookmark: () => bookmarks++,
              onShare: () => shares++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('写下你的评论...'));
    await tester.tap(find.byIcon(CupertinoIcons.heart));
    await tester.tap(find.byIcon(CupertinoIcons.bookmark));
    await tester.tap(find.byIcon(CupertinoIcons.share));

    expect((comments, likes, bookmarks, shares), (1, 1, 1, 1));
  });
}
