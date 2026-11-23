import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_menu.dart';
import 'l10n/app_localizations.dart';
import 'logic.dart';
import 'percent_page.dart' show fmt;

enum _Kind { digit, op, clear, equals }

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  final _history = <(String, String)>[]; // (expression, result), newest first
  bool _showError = false;
  String _last = '';
  // The last "=" result at full precision, so 1÷3 = then ×3 = gives 1, not 0.9999999999.
  String _exactText = '';
  double _exactVal = 0;

  double? _eval(String t) {
    if (_exactText.isNotEmpty && t.startsWith(_exactText)) {
      final rest = t.substring(_exactText.length);
      if (!RegExp(r'^[\d.,]').hasMatch(rest)) {
        return evaluate('($_exactVal)$rest');
      }
    }
    return evaluate(t);
  }

  static const _keys = [
    ['C', '(', ')', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['%', '0', '.', '='],
  ];
  static const _allowed = '0123456789+-*/()%.,×÷−';
  static const _tabular = [FontFeature.tabularFigures()];

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      setState(() {
        if (_c.text != _last) {
          _last = _c.text;
          _showError = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _sep() => fmt(context, 0.5)[1]; // locale decimal separator

  // Maps typed/pasted characters to the keypad's symbols, dropping the rest.
  String _norm(String s) => s
      .split('')
      .where(_allowed.contains)
      .map(
        (c) => switch (c) {
          '*' => '×',
          '/' => '÷',
          '-' => '−',
          '.' || ',' => _sep(),
          _ => c,
        },
      )
      .join();

  // Applies _norm to typing and pasting, keeping the cursor/selection in place.
  TextEditingValue _format(TextEditingValue old, TextEditingValue v) {
    int off(int o) =>
        _norm(v.text.substring(0, o.clamp(0, v.text.length))).length;
    final sel = v.selection;
    return TextEditingValue(
      text: _norm(v.text),
      selection: sel.isValid
          ? TextSelection(
              baseOffset: off(sel.baseOffset),
              extentOffset: off(sel.extentOffset),
            )
          : const TextSelection.collapsed(offset: -1),
    );
  }

  void _insert(String s) {
    final t = _c.text;
    final sel = _c.selection;
    final a = sel.isValid ? sel.start : t.length;
    final b = sel.isValid ? sel.end : t.length;
    _c.value = TextEditingValue(
      text: t.replaceRange(a, b, s),
      selection: TextSelection.collapsed(offset: a + s.length),
    );
  }

  void _backspace() {
    final t = _c.text;
    final sel = _c.selection;
    var a = sel.isValid ? sel.start : t.length;
    final b = sel.isValid ? sel.end : t.length;
    if (a == b) {
      if (a == 0) return;
      a--;
    }
    _c.value = TextEditingValue(
      text: t.replaceRange(a, b, ''),
      selection: TextSelection.collapsed(offset: a),
    );
  }

  void _tap(String k) {
    _focus.requestFocus();
    HapticFeedback.selectionClick(); // no-op on desktop
    switch (k) {
      case 'C':
        _c.clear();
      case '⌫':
        _backspace();
      case '=':
        _equals();
      default:
        _insert(k);
    }
  }

  void _equals() {
    _focus.requestFocus();
    final expr = _c.text;
    final v = _eval(expr);
    if (v == null) {
      setState(() => _showError = expr.isNotEmpty);
      return;
    }
    final result = fmt(context, v, digits: 10).replaceAll('-', '−');
    if (result != expr) {
      _history.insert(0, (expr, result));
      if (_history.length > 100) _history.removeLast();
    }
    _exactText = result;
    _exactVal = v;
    _c.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  void _showHistory() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => _history.isEmpty
            ? SizedBox(height: 160, child: Center(child: Text(l.noHistory)))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final (expr, result) in _history)
                          ListTile(
                            title: Text(
                              result,
                              style: Theme.of(ctx).textTheme.titleLarge
                                  ?.copyWith(fontFeatures: _tabular),
                            ),
                            subtitle: Text(expr),
                            onTap: () {
                              Navigator.pop(ctx);
                              _focus.requestFocus();
                              _insert(result);
                            },
                            onLongPress: () {
                              Navigator.pop(ctx);
                              _focus.requestFocus();
                              _insert(expr);
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setSheet(_history.clear),
                    child: Text(l.clearHistory),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _key(String k, String sep) {
    final s = Theme.of(context).colorScheme;
    final kind = switch (k) {
      'C' => _Kind.clear,
      '=' => _Kind.equals,
      '(' || ')' || '÷' || '×' || '−' || '+' || '%' => _Kind.op,
      _ => _Kind.digit,
    };
    final (bg, fg) = switch (kind) {
      _Kind.digit => (s.surfaceContainerHigh, s.onSurface),
      _Kind.op => (s.secondaryContainer, s.onSecondaryContainer),
      _Kind.clear => (s.surfaceContainerHigh, s.error),
      _Kind.equals => (s.tertiary, s.onTertiary),
    };
    final label = k == '.' ? sep : k;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox.expand(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(
                fontSize: 26,
                fontWeight: kind == _Kind.equals
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
            onPressed: () => _tap(label),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sep = _sep();
    final live = _eval(_c.text);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => _tap('C'),
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: LayoutBuilder(
          builder: (context, box) {
            final pad = (box.maxHeight * 0.58).clamp(280.0, 392.0);
            return Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: l.history,
                      icon: const Icon(Icons.history),
                      onPressed: _showHistory,
                    ),
                    const Spacer(),
                    const AppMenu(),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _c,
                                focusNode: _focus,
                                autofocus: true,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontFeatures: _tabular,
                                ),
                                // Android: the app keypad is the only input, but cursor and selection still work.
                                keyboardType:
                                    defaultTargetPlatform ==
                                        TargetPlatform.android
                                    ? TextInputType.none
                                    : TextInputType.text,
                                inputFormatters: [
                                  TextInputFormatter.withFunction(_format),
                                ],
                                onTapOutside: (_) {}, // keypad taps must not drop focus/selection
                                onEditingComplete:
                                    _equals, // Enter; also keeps focus
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                ),
                              ),
                            ),
                            ExcludeFocus(
                              child: Semantics(
                                label: l.backspace,
                                button: true,
                                excludeSemantics: true,
                                child: GestureDetector(
                                  onLongPress: () => _tap('C'),
                                  child: IconButton(
                                    icon: const Icon(Icons.backspace_outlined),
                                    onPressed: () => _tap('⌫'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                        child: Text(
                          _showError
                              ? l.error
                              : (live == null
                                    ? ''
                                    : '= ${fmt(context, live, digits: 10)}'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontFeatures: _tabular,
                            color: _showError
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ExcludeFocus(
                  child: SizedBox(
                    height: pad,
                    child: Column(
                      children: [
                        for (final row in _keys)
                          Expanded(
                            child: Row(
                              children: [for (final k in row) _key(k, sep)],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
