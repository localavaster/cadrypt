import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/models/rune_selection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:mobx/mobx.dart';

import 'package:flutter/services.dart';

import 'package:characters/characters.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

part 'analyze_state.g.dart';

class AnalyzeState = _AnalyzeStateBase with _$AnalyzeState;

abstract class _AnalyzeStateBase with Store {
  @action
  String get_grid_cipher() {
    if (cipherMode == 'regular') {
      return GetIt.I<Cipher>().raw_cipher.join();
    } else if (cipherMode == 'flat') {
      return GetIt.I<Cipher>().get_flat_cipher();
    } else if (cipherMode == 'true') {
      final temporary = GetIt.I<Cipher>().raw_cipher;
      final result = <String>[];

      for (final line in temporary) {
        result.add(line.padRight(GetIt.I<Cipher>().longest_row));
      }

      return result.join();
    }

    return GetIt.I<Cipher>().get_flat_cipher();
  }

  @action
  int get_grid_x_axis_count() {
    switch (cipherMode) {
      case 'regular':
        return List<int>.generate(GetIt.I<Cipher>().raw_cipher.length, (index) => GetIt.I<Cipher>().raw_cipher[index].length).average().toInt();

      case 'flat':
        return List<int>.generate(GetIt.I<Cipher>().raw_cipher.length, (index) => GetIt.I<Cipher>().raw_cipher[index].length).sum().toInt() ~/ 24;

      case 'true':
        return GetIt.I<Cipher>().get_longest_row();
    }

    return 20;
  }

  @observable
  ObservableList<RuneSelection> selectedRunes = ObservableList();

  @action
  void select_rune(String rune, int index, String type) {
    selectedRunes ??= ObservableList();

    final selection = RuneSelection(index, rune, type);

    if (selectedRunes.contains(selection)) {
      selectedRunes.remove(selection);
    } else // doesnt contain
    {
      selectedRunes.add(selection);
    }
  }

  @action
  void select_runes(String runes, String type) {
    selectedRunes ??= ObservableList();

    final split_runes = runes.split('');

    final selections = List<RuneSelection>.generate(split_runes.length, (index) => RuneSelection(-1, split_runes[index], type));

    print(selections);

    selections.forEach((selection) {
      print('${selection.rune} ${selection.index}');
      selectedRunes.add(selection);
    });
  }

  @observable
  ObservableList<RuneSelection> highlighedRunes = ObservableList();

  @action
  void highlight_rune(String rune, int index, String type) {
    highlighedRunes ??= ObservableList();

    final selection = RuneSelection(index, rune, type);

    if (highlighedRunes.contains(selection)) {
      if (type == 'gramhighlighter') return;

      highlighedRunes.remove(selection);
    } else // doesnt contain
    {
      highlighedRunes.add(selection);
    }
  }

  @action
  void highlight_all_instances_of_rune(String rune) {
    final pattern = RegExp('($rune)');
    final matches = pattern.allMatches(get_grid_cipher());

    //final matchIndexes = List<int>.generate(matches.length, (index) => matches.elementAt(index).start);

    matches.forEach((match) {
      highlight_rune('rune', match.start, 'highlighter');
    });
  }

  @action
  void highlight_gram(String gram) {
    final pattern = RegExp('($gram)');
    final matches = pattern.allMatches(get_grid_cipher());

    matches.forEach((match) {
      for (int i = match.start; i != match.end; i++) {
        highlight_rune('rune', i, 'gramhighlighter');
      }
    });
  }

  String get_letter_at_index(int index) {
    return GetIt.I<Cipher>().raw_cipher.join().characters.elementAt(index);
  }

  @action
  void clear_selected_runes() {
    selectedRunes.clear();
  }

  @action
  void copy_selected_runes() {
    Clipboard.setData(ClipboardData(text: List<String>.generate(selectedRunes.length, (index) => selectedRunes[index].rune).join()));
  }

  @action
  void get_distance_between_selected_runes() {
    final indexes = List<int>.generate(selectedRunes.length, (index) => selectedRunes[index].index);

    final distance = ((indexes[0] - indexes[1]).abs() + 1);

    Clipboard.setData(ClipboardData(text: distance.toString()));
  }

  @observable
  String readingMode = 'rune';

  @action
  void select_reading_mode(String readingMode) {
    this.readingMode = readingMode;
  }

  @observable
  String cipherMode = 'regular';

  @action
  void select_cipher_mode(String cipherMode) {
    print('changing cipher mode to $cipherMode');
    this.cipherMode = cipherMode;
  }

  //

  @observable
  String highlightDropdownValue = 'f';

  @action
  void changeHighlightDropdownValue(String value) {
    highlightDropdownValue = value;
  }

  @action
  void onHighlightDonePressed() {
    final cipher = get_grid_cipher();

    switch (highlightDropdownValue) {
      case 'f':
        {
          final pattern = RegExp('(ᚠ)');
          final matches = pattern.allMatches(cipher);

          matches.forEach((match) {
            highlight_rune('ᚠ', match.start, 'highlighter');
          });
        }
        break;

      case 'doubleletters':
        {
          final pattern = RegExp(r'([^ ])\1', dotAll: true);
          final matches = pattern.allMatches(cipher);

          final matchIndexesStart = List<int>.generate(matches.length, (index) => matches.elementAt(index).start);
          final matchIndexesEnd = List<int>.generate(matches.length, (index) => matches.elementAt(index).end - 1);
          final result = matchIndexesStart + matchIndexesEnd;

          result.forEach((match) {
            highlight_rune('', match, 'highlighter');
          });
        }
        break;

      case 'smallwords':
        {
          final pattern = RegExp(' ([^ ]{1,3}) ', dotAll: true);
          final matches = pattern.allMatches(cipher);
          final indexesToHighlight = <int>[];

          for (final match in matches) {
            final start = match.start + 1; // +1 and -1 because of space, not a regex god
            final end = match.end - 1;

            for (int i = start; i != end; i++) {
              indexesToHighlight.add(i);
            }
          }

          indexesToHighlight.forEach((match) {
            highlight_rune('', match, 'highlighter');
          });
        }
    }
  }
}
