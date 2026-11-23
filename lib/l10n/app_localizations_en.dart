// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EasyCalc';

  @override
  String get tabCalc => 'Calculator';

  @override
  String get tabUnitPrice => 'Unit price';

  @override
  String get tabPercent => 'Percentage';

  @override
  String get error => 'Error';

  @override
  String get about => 'About';

  @override
  String get menu => 'Menu';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get close => 'Close';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String author(String name) {
    return 'Author: $name';
  }

  @override
  String license(String name) {
    return 'License: $name';
  }

  @override
  String get appDescription =>
      'Calculator, unit price comparison and percentages.';

  @override
  String get history => 'History';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get noHistory => 'No calculations yet';

  @override
  String get backspace => 'Delete';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get addItem => 'Add item';

  @override
  String get clearAll => 'Clear all';

  @override
  String get removeRow => 'Remove item';

  @override
  String get bestPrice => 'Best price';

  @override
  String vsBest(String pct, String letter) {
    return '+$pct% vs $letter';
  }

  @override
  String get clear => 'Clear';

  @override
  String get calculated => 'Calculated';

  @override
  String get ofWord => 'of';

  @override
  String get percentOfTitle => 'Percentage of a value';

  @override
  String get percent => 'Percent (%)';

  @override
  String get ofValue => 'Of value';

  @override
  String get result => 'Result';

  @override
  String get changeTitle => 'Increase / decrease';

  @override
  String get from => 'From';

  @override
  String get changePercent => 'Change (%)';

  @override
  String get to => 'To';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';
}
