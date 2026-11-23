import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about.dart';
import 'l10n/app_localizations.dart';

/// null = follow the system language.
final localeNotifier = ValueNotifier<Locale?>(null);
const _prefKey = 'locale';

Future<void> loadLocale() async {
  try {
    final code = (await SharedPreferences.getInstance()).getString(_prefKey);
    if (code != null) localeNotifier.value = Locale(code);
  } catch (_) {
    // shortcut: a broken prefs store just means the system language is used.
  }
}

Future<void> _setLocale(String? code) async {
  localeNotifier.value = code == null ? null : Locale(code);
  try {
    final p = await SharedPreferences.getInstance();
    code == null ? await p.remove(_prefKey) : await p.setString(_prefKey, code);
  } catch (_) {
    // Not saved: the choice still applies until the app closes.
  }
}

/// The burger menu every page shows in its top row: language and About.
class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = localeNotifier.value?.languageCode;
    return PopupMenuButton<String>(
      tooltip: l.menu,
      icon: const Icon(Icons.menu),
      onSelected: (v) {
        if (v == 'about') {
          showAbout(context);
        } else {
          _setLocale(v == 'system' ? null : v);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(enabled: false, child: Text(l.language)),
        CheckedPopupMenuItem(
          value: 'system',
          checked: current == null,
          child: Text(l.systemDefault),
        ),
        CheckedPopupMenuItem(
          value: 'en',
          checked: current == 'en',
          child: const Text('English'),
        ),
        CheckedPopupMenuItem(
          value: 'pt',
          checked: current == 'pt',
          child: const Text('Português'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 12),
              Text(l.about),
            ],
          ),
        ),
      ],
    );
  }
}
