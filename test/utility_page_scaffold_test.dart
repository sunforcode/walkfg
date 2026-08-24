import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/typography.dart';
import 'package:walk/ui/page/common/utility_page_scaffold.dart';

void main() {
  testWidgets('provides the fixed utility page structure', (tester) async {
    const bodyKey = Key('utility-body');
    const leadingKey = Key('utility-leading');
    const trailingKey = Key('utility-trailing');

    await tester.pumpWidget(
      const CupertinoApp(
        home: UtilityPageScaffold(
          title: '装备清单',
          leading: SizedBox(key: leadingKey),
          trailing: SizedBox(key: trailingKey),
          body: SizedBox(key: bodyKey),
        ),
      ),
    );

    final scaffold = tester.widget<CupertinoPageScaffold>(
      find.byType(CupertinoPageScaffold),
    );
    final title = tester.widget<Text>(find.text('装备清单'));

    expect(scaffold.backgroundColor, AppColors.bgBase);
    expect(title.style, AppTypography.navTitle);
    expect(
      find.ancestor(of: find.byKey(bodyKey), matching: find.byType(SafeArea)),
      findsOneWidget,
    );
    expect(find.byKey(leadingKey), findsOneWidget);
    expect(find.byKey(trailingKey), findsOneWidget);
    expect(find.byKey(bodyKey), findsOneWidget);
  });
}
