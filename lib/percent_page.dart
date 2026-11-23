import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'amber.dart';
import 'app_menu.dart';
import 'l10n/app_localizations.dart';
import 'logic.dart';

String fmt(BuildContext context, double v, {int digits = 8}) {
  final s = NumberFormat(
    '0.${'#' * digits}',
    Localizations.localeOf(context).toString(),
  ).format(v);
  return s == '-0' ? '0' : s; // a tiny negative like -2.8e-17 rounds to "-0"
}

class PercentPage extends StatelessWidget {
  const PercentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Align(alignment: Alignment.centerRight, child: AppMenu()),
        SolverCard(
          title: l.percentOfTitle,
          labels: [l.percent, l.ofValue, l.result],
          solve: solvePercentOf,
          connectors: [l.ofWord, '='],
        ),
        const SizedBox(height: 16),
        SolverCard(
          title: l.changeTitle,
          labels: [l.from, l.changePercent, l.to],
          solve: solveChange,
          signed: true,
          connectors: const [null, '='],
        ),
      ],
    );
  }
}

/// Three linked fields: fill any two and the third is computed.
/// [signed] adds an Increase/Decrease toggle for field 1 (the field then holds the magnitude).
class SolverCard extends StatefulWidget {
  const SolverCard({
    super.key,
    required this.title,
    required this.labels,
    required this.solve,
    required this.connectors,
    this.signed = false,
  });

  final String title;
  final List<String> labels;
  final List<double>? Function(double?, double?, double?) solve;
  final List<String?>
  connectors; // between fields 0|1 and 1|2 (null → the toggle goes there)
  final bool signed;

  @override
  State<SolverCard> createState() => _SolverCardState();
}

class _SolverCardState extends State<SolverCard> {
  final _c = List.generate(3, (_) => TextEditingController());
  final _order = <int>[]; // edit order, most recent last
  int? _auto; // field currently holding a computed value
  bool _neg = false; // signed cards: Decrease selected

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    super.dispose();
  }

  double? _value(int k) {
    final v = parseNum(_c[k].text);
    return (widget.signed && k == 1 && v != null && _neg) ? -v : v;
  }

  void _changed(int i) {
    _order
      ..remove(i)
      ..add(i);
    if (_auto == i) _auto = null;
    final v = [for (var k = 0; k < 3; k++) _value(k)];
    final inputs = [
      for (var k = 0; k < 3; k++)
        if (k != _auto && v[k] != null) k,
    ];
    int? target;
    if (inputs.length < 2) {
      if (_auto != null) {
        _c[_auto!].clear(); // an input was cleared: drop stale result
      }
      target = null;
    } else if (_auto != null) {
      target = _auto;
    } else if (inputs.length == 2) {
      target = [0, 1, 2].firstWhere((k) => !inputs.contains(k));
    } else {
      target = _order.firstWhere((k) => k != i, orElse: () => (i + 1) % 3);
    }
    if (target != null) {
      final args = [for (var k = 0; k < 3; k++) k == target ? null : v[k]];
      final r = widget.solve(args[0], args[1], args[2]);
      if (r == null) {
        _c[target].text = '—';
      } else if (widget.signed && target == 1) {
        _neg = r[1] < 0;
        _c[1].text = fmt(context, r[1].abs());
      } else {
        _c[target].text = fmt(context, r[target]);
      }
    }
    setState(() => _auto = target);
  }

  void _clear() {
    for (final c in _c) {
      c.clear();
    }
    setState(() {
      _auto = null;
      _neg = false;
      _order.clear();
    });
  }

  Widget _field(int i) {
    final l = AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final computed = _auto == i;
    return SizedBox(
      width: 132,
      child: TextField(
        controller: _c[i],
        onChanged: (_) => _changed(i),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: !(widget.signed && i == 1),
        ),
        decoration: InputDecoration(
          labelText: widget.labels[i],
          filled: computed,
          fillColor: s.tertiaryContainer.withValues(alpha: 0.6),
          prefixIcon: computed
              ? Tooltip(
                  message: l.calculated,
                  child: Icon(Icons.drag_handle, color: amberInk(s)),
                )
              : null,
        ),
      ),
    );
  }

  Widget _word(String t) =>
      Text(t, style: Theme.of(context).textTheme.titleMedium);

  // A connector word and its field wrap together, so "= result" never splits.
  Widget _pair(String word, int field) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [_word(word), const SizedBox(width: 12), _field(field)],
  );

  Widget _toggle() {
    final l = AppLocalizations.of(context);
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: false, label: Text(l.increase)),
        ButtonSegment(value: true, label: Text(l.decrease)),
      ],
      selected: {_neg},
      // Read-only while the percent is the computed field: it would just snap back.
      onSelectionChanged: _auto == 1
          ? null
          : (v) {
              _neg = v.first;
              _changed(1);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l.clear,
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: _clear,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _field(0),
                if (widget.connectors[0] != null)
                  _pair(widget.connectors[0]!, 1)
                else ...[
                  _toggle(),
                  _field(1),
                ],
                _pair(widget.connectors[1]!, 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
