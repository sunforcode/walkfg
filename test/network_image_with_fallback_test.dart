import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';

void main() {
  testWidgets('uses a controlled placeholder builder while loading',
      (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: NetworkImageWithFallback(
          url: 'https://invalid.example/image.jpg',
          placeholderBuilder: (_) => const SizedBox(
            key: Key('static-placeholder'),
          ),
          errorBuilder: (_) => const SizedBox(key: Key('static-error')),
        ),
      ),
    );

    await tester.pump();

    expect(find.byKey(const Key('static-placeholder')), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('clips the controlled empty URL fallback with borderRadius',
      (tester) async {
    const borderRadius = 12.0;

    await tester.pumpWidget(
      CupertinoApp(
        home: NetworkImageWithFallback(
          url: '',
          borderRadius: borderRadius,
          errorBuilder: (_) => const SizedBox(key: Key('static-error')),
        ),
      ),
    );
    await tester.pump();

    final fallback = find.byKey(const Key('static-error'));
    final clip = find.ancestor(of: fallback, matching: find.byType(ClipRRect));

    expect(fallback, findsOneWidget);
    expect(clip, findsOneWidget);
    expect(
      tester.widget<ClipRRect>(clip).borderRadius,
      BorderRadius.circular(borderRadius),
    );
  });

  testWidgets('keeps the default loading placeholder', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: NetworkImageWithFallback(
          url: 'https://invalid.example/image.jpg',
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('clips the default empty URL fallback with borderRadius',
      (tester) async {
    const borderRadius = 16.0;

    await tester.pumpWidget(
      const CupertinoApp(
        home: NetworkImageWithFallback(
          url: '',
          borderRadius: borderRadius,
        ),
      ),
    );
    await tester.pump();

    final fallback = find.byIcon(CupertinoIcons.photo);
    final clip = find.ancestor(of: fallback, matching: find.byType(ClipRRect));

    expect(fallback, findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(clip, findsOneWidget);
    expect(
      tester.widget<ClipRRect>(clip).borderRadius,
      BorderRadius.circular(borderRadius),
    );
  });
}
