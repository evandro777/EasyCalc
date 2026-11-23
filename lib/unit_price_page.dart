import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'amber.dart';
import 'app_menu.dart';
import 'l10n/app_localizations.dart';
import 'logic.dart';
import 'percent_page.dart' show fmt;

class UnitPricePage extends StatefulWidget {
  const UnitPricePage({super.key});

  @override
  State<UnitPricePage> createState() => _UnitPricePageState();
}

class _UnitPricePageState extends State<UnitPricePage> {
  final _rows = [
    for (var i = 0; i < 2; i++)
      (TextEditingController(), TextEditingController()),
  ];
  int? _autofocusRow; // a freshly added row grabs focus

  @override
  void dispose() {
    for (final (p, q) in _rows) {
      p.dispose();
      q.dispose();
    }
    super.dispose();
  }

  String _letter(int i) => String.fromCharCode(65 + i % 26);

  void _clearAll() => setState(() {
    while (_rows.length > 2) {
      final (p, q) = _rows.removeLast();
      p.dispose();
      q.dispose();
    }
    for (final (p, q) in _rows) {
      p.clear();
      q.clear();
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final res = unitPrices([
      for (final (p, q) in _rows) (parseNum(p.text), parseNum(q.text)),
    ]);
    final bestIdx = res.best.isEmpty
        ? null
        : res.best.reduce((a, b) => a < b ? a : b);
    final bestUnit = bestIdx == null ? null : res.units[bestIdx];
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
    ).currencySymbol;
    const kb = TextInputType.numberWithOptions(decimal: true);
    const tabular = [FontFeature.tabularFigures()];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            // Wrap: on a narrow screen or with a big font the buttons drop to a second line.
            Expanded(
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() {
                      _rows.add((
                        TextEditingController(),
                        TextEditingController(),
                      ));
                      _autofocusRow = _rows.length - 1;
                    }),
                    icon: const Icon(Icons.add),
                    label: Text(l.addItem),
                  ),
                  TextButton(onPressed: _clearAll, child: Text(l.clearAll)),
                ],
              ),
            ),
            const AppMenu(),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _rows.length; i++)
          Card(
            key: ObjectKey(_rows[i].$1),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: res.best.contains(i)
                  ? BorderSide(color: amberInk(s), width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: s.secondaryContainer,
                        foregroundColor: s.onSecondaryContainer,
                        child: Text(
                          _letter(i),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _rows[i].$1,
                          autofocus: i == _autofocusRow,
                          keyboardType: kb,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: l.price,
                            prefixText: '$currency ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _rows[i].$2,
                          keyboardType: kb,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(labelText: l.quantity),
                        ),
                      ),
                      if (_rows.length > 2)
                        IconButton(
                          tooltip: l.removeRow,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            final (p, q) = _rows.removeAt(i);
                            p.dispose();
                            q.dispose();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (res.best.contains(i)) ...[
                        Icon(Icons.star_rounded, size: 18, color: amberInk(s)),
                        const SizedBox(width: 4),
                        Text(
                          l.bestPrice,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: amberInk(s),
                          ),
                        ),
                      ] else if (res.units[i] != null &&
                          bestUnit != null &&
                          bestUnit > 0)
                        Text(
                          l.vsBest(
                            fmt(
                              context,
                              (res.units[i]! / bestUnit - 1) * 100,
                              digits: 1,
                            ),
                            _letter(bestIdx!),
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        l.unitPrice,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: s.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        res.units[i] == null
                            ? '—'
                            : fmt(context, res.units[i]!, digits: 4),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
