import 'package:easycalc/amber.dart';
import 'package:easycalc/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance() + 0.05, y = b.computeLuminance() + 0.05;
  return x > y ? x / y : y / x;
}

void main() {
  for (final b in Brightness.values) {
    test('amber text is readable on cards (${b.name})', () {
      final s = EasyCalcApp.theme(b).colorScheme;
      expect(
        contrast(amberInk(s), s.surfaceContainerLow),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(s.onTertiary, s.tertiary),
        greaterThanOrEqualTo(4.5),
      ); // the = key
    });
  }
}
