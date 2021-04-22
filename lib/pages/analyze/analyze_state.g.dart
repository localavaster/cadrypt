// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyze_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AnalyzeState on _AnalyzeStateBase, Store {
  final _$selectedRunesAtom = Atom(name: '_AnalyzeStateBase.selectedRunes');

  @override
  ObservableList<RuneSelection> get selectedRunes {
    _$selectedRunesAtom.reportRead();
    return super.selectedRunes;
  }

  @override
  set selectedRunes(ObservableList<RuneSelection> value) {
    _$selectedRunesAtom.reportWrite(value, super.selectedRunes, () {
      super.selectedRunes = value;
    });
  }

  final _$highlighedRunesAtom = Atom(name: '_AnalyzeStateBase.highlighedRunes');

  @override
  ObservableList<RuneSelection> get highlighedRunes {
    _$highlighedRunesAtom.reportRead();
    return super.highlighedRunes;
  }

  @override
  set highlighedRunes(ObservableList<RuneSelection> value) {
    _$highlighedRunesAtom.reportWrite(value, super.highlighedRunes, () {
      super.highlighedRunes = value;
    });
  }

  final _$readingModeAtom = Atom(name: '_AnalyzeStateBase.readingMode');

  @override
  String get readingMode {
    _$readingModeAtom.reportRead();
    return super.readingMode;
  }

  @override
  set readingMode(String value) {
    _$readingModeAtom.reportWrite(value, super.readingMode, () {
      super.readingMode = value;
    });
  }

  final _$cipherModeAtom = Atom(name: '_AnalyzeStateBase.cipherMode');

  @override
  String get cipherMode {
    _$cipherModeAtom.reportRead();
    return super.cipherMode;
  }

  @override
  set cipherMode(String value) {
    _$cipherModeAtom.reportWrite(value, super.cipherMode, () {
      super.cipherMode = value;
    });
  }

  final _$highlightDropdownValueAtom =
      Atom(name: '_AnalyzeStateBase.highlightDropdownValue');

  @override
  String get highlightDropdownValue {
    _$highlightDropdownValueAtom.reportRead();
    return super.highlightDropdownValue;
  }

  @override
  set highlightDropdownValue(String value) {
    _$highlightDropdownValueAtom
        .reportWrite(value, super.highlightDropdownValue, () {
      super.highlightDropdownValue = value;
    });
  }

  final _$primeHighlightDropdownValueAtom =
      Atom(name: '_AnalyzeStateBase.primeHighlightDropdownValue');

  @override
  String get primeHighlightDropdownValue {
    _$primeHighlightDropdownValueAtom.reportRead();
    return super.primeHighlightDropdownValue;
  }

  @override
  set primeHighlightDropdownValue(String value) {
    _$primeHighlightDropdownValueAtom
        .reportWrite(value, super.primeHighlightDropdownValue, () {
      super.primeHighlightDropdownValue = value;
    });
  }

  final _$repeatedGramsSortedByAtom =
      Atom(name: '_AnalyzeStateBase.repeatedGramsSortedBy');

  @override
  String get repeatedGramsSortedBy {
    _$repeatedGramsSortedByAtom.reportRead();
    return super.repeatedGramsSortedBy;
  }

  @override
  set repeatedGramsSortedBy(String value) {
    _$repeatedGramsSortedByAtom.reportWrite(value, super.repeatedGramsSortedBy,
        () {
      super.repeatedGramsSortedBy = value;
    });
  }

  final _$similarGramsSortedByAtom =
      Atom(name: '_AnalyzeStateBase.similarGramsSortedBy');

  @override
  String get similarGramsSortedBy {
    _$similarGramsSortedByAtom.reportRead();
    return super.similarGramsSortedBy;
  }

  @override
  set similarGramsSortedBy(String value) {
    _$similarGramsSortedByAtom.reportWrite(value, super.similarGramsSortedBy,
        () {
      super.similarGramsSortedBy = value;
    });
  }

  final _$selectedRepeatedGramsAtom =
      Atom(name: '_AnalyzeStateBase.selectedRepeatedGrams');

  @override
  ObservableList<LiberTextClass> get selectedRepeatedGrams {
    _$selectedRepeatedGramsAtom.reportRead();
    return super.selectedRepeatedGrams;
  }

  @override
  set selectedRepeatedGrams(ObservableList<LiberTextClass> value) {
    _$selectedRepeatedGramsAtom.reportWrite(value, super.selectedRepeatedGrams,
        () {
      super.selectedRepeatedGrams = value;
    });
  }

  final _$selectedSimilarGramsAtom =
      Atom(name: '_AnalyzeStateBase.selectedSimilarGrams');

  @override
  ObservableList<LiberTextClass> get selectedSimilarGrams {
    _$selectedSimilarGramsAtom.reportRead();
    return super.selectedSimilarGrams;
  }

  @override
  set selectedSimilarGrams(ObservableList<LiberTextClass> value) {
    _$selectedSimilarGramsAtom.reportWrite(value, super.selectedSimilarGrams,
        () {
      super.selectedSimilarGrams = value;
    });
  }

  final _$selectedFrequenciesAtom =
      Atom(name: '_AnalyzeStateBase.selectedFrequencies');

  @override
  ObservableList<LiberTextClass> get selectedFrequencies {
    _$selectedFrequenciesAtom.reportRead();
    return super.selectedFrequencies;
  }

  @override
  set selectedFrequencies(ObservableList<LiberTextClass> value) {
    _$selectedFrequenciesAtom.reportWrite(value, super.selectedFrequencies, () {
      super.selectedFrequencies = value;
    });
  }

  final _$_AnalyzeStateBaseActionController =
      ActionController(name: '_AnalyzeStateBase');

  @override
  String get_grid_cipher() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.get_grid_cipher');
    try {
      return super.get_grid_cipher();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  int get_grid_x_axis_count() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.get_grid_x_axis_count');
    try {
      return super.get_grid_x_axis_count();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select_rune(String rune, int index, String type,
      {bool ignoreDuplicates = false}) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_rune');
    try {
      return super
          .select_rune(rune, index, type, ignoreDuplicates: ignoreDuplicates);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select_runes(String runes, String type) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_runes');
    try {
      return super.select_runes(runes, type);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void highlight_rune(String rune, int index, String type,
      {bool ignoreDuplicates = false, Color color}) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.highlight_rune');
    try {
      return super.highlight_rune(rune, index, type,
          ignoreDuplicates: ignoreDuplicates, color: color);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void highlight_all_instances_of_rune(String rune) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.highlight_all_instances_of_rune');
    try {
      return super.highlight_all_instances_of_rune(rune);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void highlight_gram(String gram, {Color color}) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.highlight_gram');
    try {
      return super.highlight_gram(gram, color: color);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear_selected_runes() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.clear_selected_runes');
    try {
      return super.clear_selected_runes();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void copy_selected_runes() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.copy_selected_runes');
    try {
      return super.copy_selected_runes();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select_highlighted_runes() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_highlighted_runes');
    try {
      return super.select_highlighted_runes();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select_non_highlighted_runes() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_non_highlighted_runes');
    try {
      return super.select_non_highlighted_runes();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void get_distance_between_selected_runes() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.get_distance_between_selected_runes');
    try {
      return super.get_distance_between_selected_runes();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void get_selected_runes_information() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.get_selected_runes_information');
    try {
      return super.get_selected_runes_information();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select_reading_mode(String readingMode) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_reading_mode');
    try {
      return super.select_reading_mode(readingMode);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select_cipher_mode(String cipherMode) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_cipher_mode');
    try {
      return super.select_cipher_mode(cipherMode);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeHighlightDropdownValue(String value) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.changeHighlightDropdownValue');
    try {
      return super.changeHighlightDropdownValue(value);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onHighlightDonePressed() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.onHighlightDonePressed');
    try {
      return super.onHighlightDonePressed();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changePrimeHighlightDropdownValue(String value) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.changePrimeHighlightDropdownValue');
    try {
      return super.changePrimeHighlightDropdownValue(value);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onPrimeHighlightDonePressed() {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.onPrimeHighlightDonePressed');
    try {
      return super.onPrimeHighlightDonePressed();
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onHighlightRegexDonePressed(String regex) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.onHighlightRegexDonePressed');
    try {
      return super.onHighlightRegexDonePressed(regex);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onHighlightEveryNthCharacterDonePressed(String number) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.onHighlightEveryNthCharacterDonePressed');
    try {
      return super.onHighlightEveryNthCharacterDonePressed(number);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onHighlightSimplePatternDonePressed(String pattern) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.onHighlightSimplePatternDonePressed');
    try {
      return super.onHighlightSimplePatternDonePressed(pattern);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeGramSortedBy(String value) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.changeGramSortedBy');
    try {
      return super.changeGramSortedBy(value);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeSimilarGramSortedBy(String value) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.changeSimilarGramSortedBy');
    try {
      return super.changeSimilarGramSortedBy(value);
    } finally {
      _$_AnalyzeStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedRunes: ${selectedRunes},
highlighedRunes: ${highlighedRunes},
readingMode: ${readingMode},
cipherMode: ${cipherMode},
highlightDropdownValue: ${highlightDropdownValue},
primeHighlightDropdownValue: ${primeHighlightDropdownValue},
repeatedGramsSortedBy: ${repeatedGramsSortedBy},
similarGramsSortedBy: ${similarGramsSortedBy},
selectedRepeatedGrams: ${selectedRepeatedGrams},
selectedSimilarGrams: ${selectedSimilarGrams},
selectedFrequencies: ${selectedFrequencies}
    ''';
  }
}
