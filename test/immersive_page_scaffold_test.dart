import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/spacing.dart';
import 'package:walk/ui/page/common/immersive_components.dart';
import 'package:walk/ui/page/common/immersive_page_scaffold.dart';

void main() {
  testWidgets('lays out full-screen body and safe-area glass actions',
      (tester) async {
    const bodyKey = Key('immersive-body');
    const leadingKey = Key('immersive-leading');
    const trailingKey = Key('immersive-trailing');
    const viewPadding = EdgeInsets.only(top: 47);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          viewPadding: viewPadding,
        ),
        child: CupertinoApp(
          home: ImmersivePageScaffold(
            body: const SizedBox.expand(key: bodyKey),
            leadingAction: GlassIconAction(
              key: leadingKey,
              semanticLabel: '返回',
              icon: CupertinoIcons.back,
              onPressed: () {},
            ),
            trailingAction: GlassIconAction(
              key: trailingKey,
              semanticLabel: '菜单',
              icon: CupertinoIcons.bars,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final scaffold = tester.widget<CupertinoPageScaffold>(
      find.byType(CupertinoPageScaffold),
    );
    final scaffoldRect = tester.getRect(find.byType(CupertinoPageScaffold));
    final leadingRect = tester.getRect(find.byKey(leadingKey));
    final trailingRect = tester.getRect(find.byKey(trailingKey));

    expect(scaffold.backgroundColor, AppColors.bgBase);
    expect(tester.getRect(find.byKey(bodyKey)), scaffoldRect);
    expect(leadingRect.size, const Size.square(44));
    expect(trailingRect.size, const Size.square(44));
    expect(leadingRect.top, viewPadding.top + AppSpacing.sm);
    expect(leadingRect.left, AppSpacing.heroHorizontal);
    expect(trailingRect.top, viewPadding.top + AppSpacing.sm);
    expect(
      scaffoldRect.right - trailingRect.right,
      AppSpacing.heroHorizontal,
    );
  });

  testWidgets('allows the body without either top action', (tester) async {
    const bodyKey = Key('body-only');

    await tester.pumpWidget(
      const CupertinoApp(
        home: ImmersivePageScaffold(
          body: ColoredBox(key: bodyKey, color: AppColors.bgPanel),
        ),
      ),
    );

    expect(find.byKey(bodyKey), findsOneWidget);
    expect(find.byType(GlassIconAction), findsNothing);
  });
}
