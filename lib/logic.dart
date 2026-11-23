/// Parses a user-typed number; accepts ',' or '.' as decimal separator.
double? parseNum(String s) {
  var t = s.trim();
  final comma = t.lastIndexOf(','), dot = t.lastIndexOf('.');
  if (comma >= 0 && dot >= 0) {
    // Both present: the last one is the decimal mark, the other groups thousands.
    t = comma > dot
        ? t.replaceAll('.', '').replaceAll(',', '.')
        : t.replaceAll(',', '');
  } else {
    t = t.replaceAll(',', '.');
  }
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  return (v == null || v.isNaN || v.isInfinite) ? null : v;
}

/// Evaluates "+ - × ÷ * / ( ) %" expressions (',' or '.' decimals). Null on error.
double? evaluate(String expr) {
  // Bounds the parser's recursion: ~200k nested "(" would overflow the stack.
  if (expr.length > 1000) return null;
  final p = _Parser(
    expr
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-'),
  );
  try {
    final v = p.parseAll();
    return (v.isNaN || v.isInfinite) ? null : v;
  } on FormatException {
    return null;
  }
}

class _Parser {
  _Parser(String s) : _s = s.replaceAll(RegExp(r'\s'), '');
  final String _s;
  int _i = 0;

  double parseAll() {
    final v = _expr();
    if (_i != _s.length) throw const FormatException('trailing');
    return v;
  }

  bool _eat(String c) {
    if (_i < _s.length && _s[_i] == c) {
      _i++;
      return true;
    }
    return false;
  }

  static final _onlyPercent = RegExp(r'^(\d+\.?\d*|\.\d+)%$');

  // The right side of + or -: a lone "N%" means N% of the left side (200+10% = 220).
  double _operand(double left) {
    final start = _i;
    final b = _term();
    return _onlyPercent.hasMatch(_s.substring(start, _i)) ? left * b : b;
  }

  double _expr() {
    var v = _term();
    while (true) {
      if (_eat('+')) {
        v += _operand(v);
      } else if (_eat('-')) {
        v -= _operand(v);
      } else {
        return v;
      }
    }
  }

  double _term() {
    var v = _unary();
    while (true) {
      if (_eat('*')) {
        v *= _unary();
      } else if (_eat('/')) {
        final d = _unary();
        if (d == 0) throw const FormatException('div0');
        v /= d;
      } else {
        return v;
      }
    }
  }

  double _unary() {
    if (_eat('-')) return -_unary();
    var v = _atom();
    while (_eat('%')) {
      v /= 100;
    }
    return v;
  }

  double _atom() {
    if (_eat('(')) {
      final v = _expr();
      if (!_eat(')')) throw const FormatException('paren');
      return v;
    }
    // The exponent lets the calculator feed back full-precision results like 1e-7.
    final m = RegExp(r'(?:\d+\.?\d*|\.\d+)(?:e[+-]?\d+)?')
        .matchAsPrefix(_s, _i);
    if (m == null) throw const FormatException('num');
    _i = m.end;
    return double.parse(m[0]!);
  }
}

/// Indexes of rows with the lowest unit price (ties included, within float
/// noise). Rows with missing or negative price, or missing qty or qty <= 0,
/// are ignored. Returns unit prices too.
({List<double?> units, Set<int> best}) unitPrices(
  List<(double?, double?)> rows,
) {
  final units = [
    for (final (p, q) in rows)
      (p == null || q == null || q <= 0 || p < 0) ? null : p / q,
  ];
  final valid = units.whereType<double>();
  if (valid.isEmpty) return (units: units, best: <int>{});
  final min = valid.reduce((a, b) => a < b ? a : b);
  return (
    units: units,
    best: {
      for (var i = 0; i < units.length; i++)
        if (units[i] != null && (units[i]! - min).abs() <= min * 1e-9) i,
    },
  );
}

/// Solves X% of Y = R given any two of [x, y, r] (the null one). Null if undefined.
/// Returns the full triple [x, y, r].
List<double>? solvePercentOf(double? x, double? y, double? r) {
  if (x == null && y != null && r != null) {
    return y == 0 ? null : [r / y * 100, y, r];
  }
  if (y == null && x != null && r != null) {
    return x == 0 ? null : [x, r / x * 100, r];
  }
  if (r == null && x != null && y != null) return [x, y, x / 100 * y];
  return null;
}

/// Solves B = A * (1 + p/100) given any two of [a, p, b] (the null one).
/// p is signed (negative = decrease). Returns [a, p, b] or null if undefined.
List<double>? solveChange(double? a, double? p, double? b) {
  if (b == null && a != null && p != null) return [a, p, a * (1 + p / 100)];
  if (p == null && a != null && b != null) {
    return a == 0 ? null : [a, (b / a - 1) * 100, b];
  }
  if (a == null && p != null && b != null) {
    return p == -100 ? null : [b / (1 + p / 100), p, b];
  }
  return null;
}
