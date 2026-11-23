import 'package:easycalc/calculator_page.dart';
import 'package:easycalc/l10n/app_localizations.dart';
import 'package:easycalc/percent_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget page) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: page),
);

void main() {
  group('Percentage cards', () {
    Finder field(int i) => find.byType(TextField).at(i);
    String text(WidgetTester t, int i) =>
        t.widget<TextField>(field(i)).controller!.text;

    testWidgets('fill two fields, the third is computed; clearing drops it', (
      t,
    ) async {
      await t.pumpWidget(app(const PercentPage()));
      await t.enterText(field(0), '15');
      await t.enterText(field(1), '200');
      expect(text(t, 2), '30');
      await t.enterText(field(0), '');
      expect(text(t, 2), '');
    });

    testWidgets('undefined result shows a dash', (t) async {
      await t.pumpWidget(app(const PercentPage()));
      await t.enterText(field(1), '200');
      await t.enterText(field(2), '30');
      expect(text(t, 0), '15');
      await t.enterText(field(1), '0');
      expect(text(t, 0), '—');
    });

    testWidgets(
      'change card: a decrease sets the toggle and shows the magnitude',
      (t) async {
        await t.pumpWidget(app(const PercentPage()));
        await t.enterText(field(3), '200');
        await t.enterText(field(5), '170');
        expect(text(t, 4), '15');
        await t.pump(); // the toggle rebuilds one frame after the text
        final toggle = t.widget<SegmentedButton<bool>>(
          find.byType(SegmentedButton<bool>),
        );
        expect(toggle.selected, {true});
        expect(toggle.onSelectionChanged, isNull); // read-only while computed
      },
    );
  });

  group('Calculator editing', () {
    Future<void> press(WidgetTester t, String label) async {
      await t.tap(find.widgetWithText(FilledButton, label));
      await t.pump();
    }

    TextEditingController ctl(WidgetTester t) =>
        t.widget<TextField>(find.byType(TextField)).controller!;

    testWidgets('insert at the cursor, backspace, replace a selection', (
      t,
    ) async {
      await t.pumpWidget(app(const CalculatorPage()));
      await press(t, '1');
      await press(t, '2');
      ctl(t).selection = const TextSelection.collapsed(offset: 1);
      await press(t, '5');
      expect(ctl(t).text, '152');
      await t.tap(find.byIcon(Icons.backspace_outlined));
      await t.pump();
      expect(ctl(t).text, '12');
      ctl(t).selection = const TextSelection(baseOffset: 0, extentOffset: 2);
      await press(t, '9');
      expect(ctl(t).text, '9');
    });

    testWidgets('a tiny negative result shows 0, not -0', (t) async {
      await t.pumpWidget(app(const CalculatorPage()));
      for (final k in [
        '0',
        '.',
        '3',
        '−',
        '0',
        '.',
        '1',
        '−',
        '0',
        '.',
        '2',
        '=',
      ]) {
        await press(t, k);
      }
      expect(ctl(t).text, '0');
    });

    testWidgets('chained results keep full precision', (t) async {
      await t.pumpWidget(app(const CalculatorPage()));
      for (final k in ['1', '÷', '3', '=', '×', '3', '=']) {
        await press(t, k);
      }
      expect(ctl(t).text, '1');
    });
  });
}
