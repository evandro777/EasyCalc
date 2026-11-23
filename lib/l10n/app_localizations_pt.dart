// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'EasyCalc';

  @override
  String get tabCalc => 'Calculadora';

  @override
  String get tabUnitPrice => 'Preço unitário';

  @override
  String get tabPercent => 'Porcentagem';

  @override
  String get error => 'Erro';

  @override
  String get about => 'Sobre';

  @override
  String get menu => 'Menu';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get close => 'Fechar';

  @override
  String version(String v) {
    return 'Versão $v';
  }

  @override
  String author(String name) {
    return 'Autor: $name';
  }

  @override
  String license(String name) {
    return 'Licença: $name';
  }

  @override
  String get appDescription =>
      'Calculadora, comparação de preço unitário e porcentagens.';

  @override
  String get history => 'Histórico';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get noHistory => 'Nenhum cálculo ainda';

  @override
  String get backspace => 'Apagar';

  @override
  String get price => 'Preço';

  @override
  String get quantity => 'Qtd.';

  @override
  String get unitPrice => 'Preço unitário';

  @override
  String get addItem => 'Adicionar item';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get removeRow => 'Remover item';

  @override
  String get bestPrice => 'Melhor preço';

  @override
  String vsBest(String pct, String letter) {
    return '+$pct% vs $letter';
  }

  @override
  String get clear => 'Limpar';

  @override
  String get calculated => 'Calculado';

  @override
  String get ofWord => 'de';

  @override
  String get percentOfTitle => 'Porcentagem de um valor';

  @override
  String get percent => 'Taxa (%)';

  @override
  String get ofValue => 'De valor';

  @override
  String get result => 'Resultado';

  @override
  String get changeTitle => 'Aumento / desconto';

  @override
  String get from => 'De';

  @override
  String get changePercent => 'Variação (%)';

  @override
  String get to => 'Para';

  @override
  String get increase => 'Aumento';

  @override
  String get decrease => 'Desconto';
}
