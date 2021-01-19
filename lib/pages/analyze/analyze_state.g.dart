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
  void select_rune(String rune, int index, String type) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.select_rune');
    try {
      return super.select_rune(rune, index, type);
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
  void highlight_rune(String rune, int index, String type) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.highlight_rune');
    try {
      return super.highlight_rune(rune, index, type);
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
  void highlight_gram(String gram) {
    final _$actionInfo = _$_AnalyzeStateBaseActionController.startAction(
        name: '_AnalyzeStateBase.highlight_gram');
    try {
      return super.highlight_gram(gram);
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
  String toString() {
    return '''
selectedRunes: ${selectedRunes},
highlighedRunes: ${highlighedRunes},
readingMode: ${readingMode},
cipherMode: ${cipherMode},
highlightDropdownValue: ${highlightDropdownValue}
    ''';
  }
}
