import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_menu.dart';
import 'calculator_page.dart';
import 'l10n/app_localizations.dart';
import 'percent_page.dart';
import 'unit_price_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadLocale();
  runApp(const EasyCalcApp());
}

class EasyCalcApp extends StatelessWidget {
  const EasyCalcApp({super.key});

  // Amber is reserved for "the answer": the = key, the cursor, computed fields, the best row.
  static ThemeData theme(Brightness b) {
    final dark = b == Brightness.dark;
    final s =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: b,
        ).copyWith(
          tertiary: const Color(0xFFFFB300),
          onTertiary: const Color(0xFF3E2A00),
          tertiaryContainer: dark
              ? const Color(0xFF4D3900)
              : const Color(0xFFFFE9A8),
          onTertiaryContainer: dark
              ? const Color(0xFFFFE08A)
              : const Color(0xFF3E2A00),
        );
    return ThemeData(
      colorScheme: s,
      useMaterial3: true,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: dark ? s.tertiary : const Color(0xFFB26A00),
        selectionColor: s.primary.withValues(alpha: 0.35),
        selectionHandleColor: dark ? s.tertiary : const Color(0xFFB26A00),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        indicatorColor: s.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => MaterialApp(
        locale: locale,
        onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
        theme: theme(Brightness.light),
        darkTheme: theme(Brightness.dark),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: IndexedStack(
              index: _tab,
              children: const [
                CalculatorPage(),
                UnitPricePage(),
                PercentPage(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: const Icon(Icons.calculate),
            label: l.tabCalc,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sell_outlined),
            selectedIcon: const Icon(Icons.sell),
            label: l.tabUnitPrice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.percent_outlined),
            selectedIcon: const Icon(Icons.percent),
            label: l.tabPercent,
          ),
        ],
      ),
    );
  }
}
