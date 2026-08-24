import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/theme/app_theme.dart';
import 'package:walk/theme/tokens/blur.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/radius.dart';
import 'package:walk/theme/tokens/spacing.dart';
import 'package:walk/theme/tokens/typography.dart';
import 'package:walk/ui/page/common/immersive_components.dart';

void main() {
  Widget app(Widget child, {double width = 390}) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 844)),
      child: CupertinoApp(
        theme: AppTheme.cupertino,
        builder: AppTheme.buildMaterialTheme,
        home: CupertinoPageScaffold(child: Center(child: child)),
      ),
    );
  }

  group('ImmersiveHero', () {
    testWidgets('keeps image, hero scrim, and overlay in fixed layer order',
        (tester) async {
      await tester.pumpWidget(
        app(
          const SizedBox(
            width: 300,
            height: 400,
            child: ImmersiveHero(
              image: ColoredBox(
                key: Key('image'),
                color: CupertinoColors.systemBlue,
              ),
              overlay: SizedBox(key: Key('overlay')),
            ),
          ),
        ),
      );

      final stack = tester.widget<Stack>(
        find.descendant(
          of: find.byType(ImmersiveHero),
          matching: find.byType(Stack),
        ),
      );
      expect(stack.children[0].key, const Key('image'));
      final scrim = stack.children[1] as DecoratedBox;
      expect((scrim.decoration as BoxDecoration).gradient, AppColors.heroScrim);
      expect(stack.children[2].key, const Key('overlay'));
    });

    testWidgets('fullBleed has no radius and editorial uses overlay radius',
        (tester) async {
      await tester.pumpWidget(
        app(
          const Column(
            children: [
              SizedBox(
                width: 200,
                height: 100,
                child: ImmersiveHero(
                  key: Key('full'),
                  image: SizedBox(),
                  overlay: SizedBox(),
                ),
              ),
              SizedBox(
                width: 200,
                height: 100,
                child: ImmersiveHero(
                  key: Key('editorial'),
                  variant: ImmersiveHeroVariant.editorial,
                  image: SizedBox(),
                  overlay: SizedBox(),
                ),
              ),
            ],
          ),
        ),
      );

      final fullClip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byKey(const Key('full')),
          matching: find.byType(ClipRRect),
        ),
      );
      final editorialClip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byKey(const Key('editorial')),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(fullClip.borderRadius, BorderRadius.zero);
      expect(editorialClip.borderRadius, AppRadius.borderOverlay);
    });
  });

  group('HeroTitleOverlay', () {
    testWidgets('uses hero title at 360 and limits it to two lines',
        (tester) async {
      await tester.pumpWidget(
        app(
          const HeroTitleOverlay(
            eyebrow: Text('秦岭'),
            title: '一条很长很长的路线标题',
            supportingText: Text('辅助信息'),
            metrics: SizedBox(key: Key('metrics')),
          ),
          width: 360,
        ),
      );

      final title = tester.widget<Text>(find.text('一条很长很长的路线标题'));
      expect(title.maxLines, 2);
      expect(title.style, AppTypography.heroTitle);
    });

    testWidgets('uses a fixed 40sp title below 360', (tester) async {
      await tester.pumpWidget(
        app(const HeroTitleOverlay(title: '窄屏标题'), width: 359),
      );

      expect(tester.widget<Text>(find.text('窄屏标题')).style?.fontSize, 40);
    });
  });

  testWidgets('MetricGroup wraps with fixed spacing and semantic type styles',
      (tester) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 120,
          child: MetricGroup(
            metrics: [
              MetricData(value: '42.6', unit: '公里'),
              MetricData(value: '1860m', unit: '爬升'),
              MetricData(value: '困难', unit: '难度'),
            ],
          ),
        ),
      ),
    );

    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, AppSpacing.xl);
    expect(wrap.runSpacing, AppSpacing.sm);
    expect(tester.widget<Text>(find.text('42.6')).style,
        AppTypography.metricValue);
    expect(
        tester.widget<Text>(find.text('公里')).style, AppTypography.metricUnit);
    expect(tester.getTopLeft(find.text('困难')).dy,
        greaterThan(tester.getTopLeft(find.text('42.6')).dy));
  });

  testWidgets('GlassIconAction is blurred, 44 square, semantic, and tappable',
      (tester) async {
    var taps = 0;
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      app(
        GlassIconAction(
          semanticLabel: '打开菜单',
          icon: CupertinoIcons.bars,
          onPressed: () => taps += 1,
        ),
      ),
    );

    expect(tester.getSize(find.byType(GlassIconAction)), const Size(44, 44));
    expect(find.bySemanticsLabel('打开菜单'), findsOneWidget);

    final blur = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
    expect(blur.filter.toString(), contains('${AppBlur.control}'));
    final surface = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == AppColors.surfaceGlass,
    );
    final box =
        tester.widget<DecoratedBox>(surface).decoration as BoxDecoration;
    expect(box.borderRadius, AppRadius.borderFull);
    expect(box.border?.top.color, AppColors.border);

    await tester.tap(find.byType(GlassIconAction));
    expect(taps, 1);
    semantics.dispose();
  });

  testWidgets('GlassIconAction exposes disabled semantics without onPressed',
      (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      app(
        const GlassIconAction(
          semanticLabel: '不可用操作',
          icon: CupertinoIcons.bars,
          onPressed: null,
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(GlassIconAction));
    expect(node.flagsCollection.isEnabled.toString(), 'Tristate.isFalse');
    semantics.dispose();
  });
}
