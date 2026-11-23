import 'dart:io';

import 'package:easycalc/about.dart';
import 'package:easycalc/logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appVersion matches pubspec', () {
    final v = RegExp(
      r'^version:\s*([\d.]+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())![1];
    expect(appVersion, v);
    // The Flatpak store entry reads its version from the metainfo.
    final meta = File(
      'linux/packaging/io.github.evandro777.EasyCalc.metainfo.xml',
    ).readAsStringSync();
    expect(meta, contains('<release version="$v"'));
  });

  test('evaluate', () {
    expect(evaluate('2+3×4'), 14);
    expect(evaluate('(2+3)×4'), 20);
    expect(evaluate('-2+5'), 3);
    expect(evaluate('50%'), 0.5);
    expect(evaluate('1,5+1'), 2.5);
    expect(evaluate('1÷0'), isNull);
    expect(evaluate('2+'), isNull);
    expect(evaluate('(2'), isNull);
  });

  test('parseNum', () {
    expect(parseNum('1,5'), 1.5);
    expect(parseNum('1.5'), 1.5);
    expect(parseNum('1.299,90'), 1299.9);
    expect(parseNum('1,299.90'), 1299.9);
    expect(parseNum(''), isNull);
    expect(parseNum('abc'), isNull);
  });

  test('unitPrices', () {
    final r = unitPrices([(10, 2), (6, 1), (null, 3), (5, 0), (12, 2)]);
    expect(r.best, {0});
    expect(unitPrices([(4, 2), (2, 1)]).best, {0, 1});
    expect(unitPrices([(null, null)]).best, isEmpty);
    // Float noise: 0.7/7 is 0.09999999999999999, still a tie with 0.1/1.
    expect(unitPrices([(0.7, 7), (0.1, 1)]).best, {0, 1});
    expect(unitPrices([(-5, 2), (3, 1)]).best, {1});
  });

  test('evaluate: percent of the left side after + or -', () {
    expect(evaluate('200+10%'), closeTo(220, 1e-9));
    expect(evaluate('200−10%'), closeTo(180, 1e-9));
    expect(evaluate('200×10%'), closeTo(20, 1e-9));
    expect(evaluate('50%'), 0.5);
  });

  test('evaluate: limits and exponents', () {
    expect(evaluate('(' * 200000), isNull); // would overflow the stack
    expect(evaluate('(1e-7)×10'), closeTo(1e-6, 1e-15));
  });

  test('percent', () {
    expect(solvePercentOf(15, 200, null), [15, 200, 30]);
    expect(solvePercentOf(null, 200, 30), [15, 200, 30]);
    expect(solvePercentOf(15, null, 30), [15, 200, 30]);
    expect(solvePercentOf(null, 0, 30), isNull);
    expect(solveChange(200, 15, null)![2], closeTo(230, 1e-9));
    expect(solveChange(200, null, 230)![1], closeTo(15, 1e-9));
    expect(solveChange(null, 15, 230)![0], closeTo(200, 1e-9));
    expect(solveChange(0, null, 5), isNull);
    expect(solveChange(null, -100, 5), isNull);
  });
}
