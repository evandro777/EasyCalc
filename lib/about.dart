import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'l10n/app_localizations.dart';

/// Keep in sync with `version:` in pubspec.yaml (test/logic_test.dart checks it).
const appVersion = '1.0.0';
const _url = 'github.com/evandro777/EasyCalc';

void showAbout(BuildContext context) {
  final l = AppLocalizations.of(context);
  final theme = Theme.of(context);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Image.asset('assets/icon.png', width: 64, height: 64),
            Text(l.appTitle, style: theme.textTheme.headlineSmall),
            Text(l.version(appVersion)),
            Text(l.appDescription, textAlign: TextAlign.center),
            Text(l.author('evandro777')),
            Text(l.license('GPL-3.0-or-later')),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://$_url')),
              child: Text(
                _url,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l.close)),
      ],
    ),
  );
}
