import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/models/console_state.dart';
import 'package:cicadrypt/models/crib_settings.dart';
import 'package:cicadrypt/models/magic_square_settings.dart';
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
        result.add(line.padRight(GetIt.I<Cipher>().longest_row, '%'));
      }

      return result.join();
    } else if (cipherMode == '3x3') {
      // not the best
      final flat_cipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flat_cipher.length; i = i + 3) {
        buffer.write('${flat_cipher.split('').sublist(i, (i + 3).clamp(0, flat_cipher.length).toInt()).join()} ');
      }

      return buffer.toString();
    } else if (cipherMode == '4x4') {
      // not the best
      final flat_cipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flat_cipher.length; i = i + 4) {
        buffer.write('${flat_cipher.split('').sublist(i, (i + 4).clamp(0, flat_cipher.length).toInt()).join()} ');
      }

      return buffer.toString();
    } else if (cipherMode == '5x5') {
      // not the best
      final flat_cipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flat_cipher.length; i = i + 5) {
        buffer.write('${flat_cipher.split('').sublist(i, (i + 5).clamp(0, flat_cipher.length).toInt()).join()} ');
      }

      return buffer.toString();
    }

    return GetIt.I<Cipher>().get_flat_cipher();
  }

  @action
  int get_grid_x_axis_count() {
    switch (cipherMode) {
      case 'regular':
        //return 13;
        return List<int>.generate(GetIt.I<Cipher>().raw_cipher.length, (index) => GetIt.I<Cipher>().raw_cipher[index].length).average().clamp(0, 28).toInt();

      case 'flat':
        //return 16;
        return List<int>.generate(GetIt.I<Cipher>().raw_cipher.length, (index) => GetIt.I<Cipher>().raw_cipher[index].length).sum().toInt() ~/ GetIt.I<Cipher>().raw_cipher.length;

      case 'true':
        return GetIt.I<Cipher>().get_longest_row();

      case '3x3':
        return 28;

      case '4x4':
        return 20;

      case '5x5':
        return 30;
    }

    return 20;
  }

  @observable
  ObservableList<RuneSelection> selectedRunes = ObservableList();

  @action
  void select_rune(String rune, int index, String type) {
    if (rune == 'auto') {
      final grid_cipher = get_grid_cipher();
      rune = grid_cipher.split('').elementAt(index);
      if (['%', r'$', '&'].contains(rune)) return;
    }
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

    selections.forEach((selection) {
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
    String runeToHighlight = rune;
    if (runeToHighlight == '.') runeToHighlight = r'\.';
    final pattern = RegExp('($runeToHighlight)');
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

    final distance = ((indexes[0] - indexes[1]).abs());

    GetIt.I.get<ConsoleState>(instanceName: 'analyze').write_to_console('Distance: ${selectedRunes[0].rune} <-> ${selectedRunes[1].rune} == $distance');
  }

  @action
  void get_selected_runes_information() {
    final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

    final selectedRuneLetters = List<String>.generate(selectedRunes.length, (index) => selectedRunes[index].rune);

    final primes = List<int>.generate(selectedRuneLetters.length, (index) => Conversions.runeToPrime(selectedRuneLetters[index]));
    final primesMod29 = List<int>.generate(selectedRuneLetters.length, (index) => (Conversions.runeToPrime(selectedRuneLetters[index]) % 29));
    final positions = List<int>.generate(selectedRuneLetters.length, (index) => runes.indexOf(selectedRuneLetters[index]));

    final primeSum = primes.sum();
    final positionsSum = positions.sum();

    console.write_to_console('=== Selection Info (${selectedRuneLetters.join()})');
    console.write_to_console('Length: ${selectedRuneLetters.length}');
    console.write_to_console('Prime Conversion: $primes');
    console.write_to_console('Prime(%29) Conversion: $primesMod29');
    console.write_to_console('Prime Conv. Sum: $primeSum');
    console.write_to_console('Position Conversion: $positions');
    console.write_to_console('Position Conv. Sum: $positionsSum');

    final word = List<String>.generate(positions.length, (index) => runeEnglish[positions[index]]);
    final atbashedWord = List<String>.generate(word.length, (index) => runeEnglish.reversed.toList()[positions[index]]);
    console.write_to_console('Word: ${word.join('')} | ${word.join('').reverse}');
    console.write_to_console('Atbash: ${atbashedWord.join('')} | ${atbashedWord.join('').reverse}');
  }

  @observable
  String readingMode = 'rune';

  @action
  void select_reading_mode(String readingMode) {
    this.readingMode = readingMode;
  }

  @observable
  String cipherMode = 'true';

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

      case 'doubleletterrunes':
        {
          final pattern = RegExp('[ᚦᛇᛝᚫᛡᛠ]', dotAll: true);
          final matches = pattern.allMatches(cipher);

          matches.forEach((match) {
            highlight_rune('', match.start, 'highlighter');
          });
        }
        break;

      case 'smallwords':
        {
          print(cipher);
          final pattern = RegExp(r'[-%&$ ][^ %$&]{1,2}[-%&$ ]', dotAll: true);
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
        break;

      case 'repeatwords':
        {
          print(cipher);
          final Map<String, int> seen = {};
          final cipherWords = GetIt.I<Cipher>().raw_cipher.join('').replaceAll('.', '-').replaceAll(r'$', '').replaceAll('%', '').replaceAll('&', '').replaceAll(' ', '-').split('-');

          for (final word in cipherWords) {
            if (seen.containsKey(word)) {
              seen[word] += 1;
            } else {
              seen[word] = 1;
            }
          }

          seen.removeWhere((key, value) => value == 1);

          List<int> indexesToHighlight = <int>[];
          seen.keys.forEach((word) {
            final pattern = RegExp('[-%& ]($word)[-%& ]');
            final matches = pattern.allMatches(cipher);

            print(matches.length);

            for (final match in matches) {
              int start = match.start;
              int end = match.end;

              if (start == end) {
                indexesToHighlight.add(start);
                continue;
              }

              start = start + 1; // else spaces will be highlighted
              end = end - 1;

              for (int i = start; i != end; i++) {
                indexesToHighlight.add(i);
              }
            }
          });

          indexesToHighlight = indexesToHighlight.toSet().toList();
          indexesToHighlight.forEach((match) {
            highlight_rune('', match, 'highlighter');
          });
        }
        break;

      case 'allvowels':
        {
          final pattern = RegExp('[ᚪᛖᛁᚩᚢᚫᛡ]', dotAll: true);
          final matches = pattern.allMatches(cipher);

          matches.forEach((match) {
            highlight_rune('', match.start, 'highlighter');
          });
        }
        break;

      case 'vowels':
        {
          final pattern = RegExp('[ᚪᛖᛁᚩᚢ]', dotAll: true);
          final matches = pattern.allMatches(cipher);

          matches.forEach((match) {
            highlight_rune('', match.start, 'highlighter');
          });
        }
        break;

      case 'rows':
        {
          final rows = GetIt.I<Cipher>().raw_cipher.length;
          final row_length = get_grid_x_axis_count();

          print('rows $rows');

          print('row length $row_length');

          for (int x = 0; x < rows; x++) {
            if (x.isOdd) continue;

            final row_start = row_length * x;
            final row_end = row_start + row_length;

            print('highlightinf $row_start to $row_end');

            for (int i = row_start; i < row_end; i++) {
              highlight_rune('', i, 'highlighter');
            }
          }
        }
        break;

      case 'columns':
        {
          final columns = GetIt.I<Cipher>().raw_cipher.length;
          final row_length = get_grid_x_axis_count();

          for (int x = 0; x < columns; x++) {
            final row_start = row_length * x;
            final row_end = row_start + row_length;

            print('highlightinf $row_start to $row_end');

            for (int i = row_start; i < row_end; i = i + 2) {
              highlight_rune('', i, 'highlighter');
            }
          }
        }
        break;

      case 'checkerboard':
        {
          final length = get_grid_x_axis_count() * GetIt.I<Cipher>().raw_cipher.length;

          for (int x = 0; x < length; x++) {
            if (x.isOdd) continue;

            highlight_rune('', x, 'highlighter');
          }
        }
        break;
    }
  }

  @observable
  String repeatedGramsSortedBy = 'count';

  @action
  void changeGramSortedBy(String value) {
    repeatedGramsSortedBy = value;
  }

  //

  final CribSettings cribSettings = CribSettings();

  final MagicSquareCribSettings magicSquareCribSettings = MagicSquareCribSettings();
}
