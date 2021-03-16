import 'dart:io';

import 'package:characters/characters.dart';
import 'package:cicadrypt/constants/libertext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../../constants/runes.dart';
import '../../constants/utils.dart';
import '../../constants/extensions.dart';
import '../../global/cipher.dart';
import '../../models/console_state.dart';
import '../../models/crib_settings.dart';
import '../../models/magic_square_settings.dart';
import '../../models/rune_selection.dart';

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
    } else if (cipherMode == 'sentences') {
      final temporary = GetIt.I<Cipher>().raw_cipher.join().replaceAll(RegExp(r'[$%&]'), '');
      final result = <String>[];

      final split_sentences = temporary.split('.');

      for (final line in split_sentences) {
        final modifiedLine = '$line.';
        if (modifiedLine.length > GetIt.I<Cipher>().longest_row) {
          // get remainder of longest row, then pad by it
          final remainder = modifiedLine.length % GetIt.I<Cipher>().longest_row;
          if (remainder != 0) {
            final toPad = GetIt.I<Cipher>().longest_row - remainder;

            result.add(modifiedLine + ('%' * toPad));
          } else {
            result.add(modifiedLine);
          }
        } else {
          result.add(modifiedLine.padRight(GetIt.I<Cipher>().longest_row, '%'));
        }

        if (!modifiedLine.startsWith(RegExp(r'[$%&]'))) {
          result.add(List<String>.generate(GetIt.I<Cipher>().longest_row, (index) => '%').join());
        }
      }

      result.forEach(print);

      result.removeWhere((element) => element.startsWith('.') && element.endsWith('%') && element.characters.elementAt(15) == '%');

      return result.join();
    } else if (cipherMode == '2x2') {
      // not the best
      final flat_cipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flat_cipher.length; i = i + 2) {
        buffer.write('${flat_cipher.split('').sublist(i, (i + 2).clamp(0, flat_cipher.length).toInt()).join()} ');
      }

      return buffer.toString();
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
        return List<int>.generate(GetIt.I<Cipher>().raw_cipher.length, (index) => GetIt.I<Cipher>().raw_cipher[index].length).average.toInt().clamp(0, 28).toInt();

      case 'flat':
        return List<int>.generate(GetIt.I<Cipher>().raw_cipher.length, (index) => GetIt.I<Cipher>().raw_cipher[index].length).average.toInt().clamp(0, 28).toInt();

      case 'true':
        return GetIt.I<Cipher>().get_longest_row();

      case 'sentences':
        return GetIt.I<Cipher>().get_longest_row();

      case '2x2':
        return 24;

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
  void select_rune(String rune, int index, String type, {bool ignoreDuplicates = false}) {
    if (rune == 'auto') {
      final grid_cipher = get_grid_cipher();
      // ignore: parameter_assignments
      rune = grid_cipher.split('').elementAt(index);
      if (['%', r'$', '&'].contains(rune)) return;
    }
    selectedRunes ??= ObservableList();

    final selection = RuneSelection(index, rune, type);

    if (selectedRunes.contains(selection)) {
      if (ignoreDuplicates) return;

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
  void highlight_rune(String rune, int index, String type, {bool ignoreDuplicates = false, Color color = null}) {
    highlighedRunes ??= ObservableList();

    final selection = RuneSelection(index, rune, type, color: color);

    if (highlighedRunes.contains(selection)) {
      if (type == 'gramhighlighter') return;
      if (ignoreDuplicates) return;

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
  void highlight_gram(String gram, {Color color = null}) {
    final pattern = RegExp('($gram)');
    final matches = pattern.allMatches(get_grid_cipher());

    matches.forEach((match) {
      for (int i = match.start; i != match.end; i++) {
        highlight_rune('rune', i, 'gramhighlighter', color: color);
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
    String data;

    if (readingMode == 'rune') {
      data = List<String>.generate(selectedRunes.length, (index) => selectedRunes[index].rune).join();
    } else if (readingMode == 'english') {
      final runes = List<String>.generate(selectedRunes.length, (index) => selectedRunes[index].rune);

      data = List<String>.generate(runes.length, (index) {
        if (runeToEnglish.keys.contains(runes[index])) {
          return runeToEnglish[runes[index]];
        } else {
          return runes[index];
        }
      }).join();
    } else {
      data = List<String>.generate(selectedRunes.length, (index) => selectedRunes[index].rune).join();
    }

    Clipboard.setData(ClipboardData(text: data));
  }

  @action
  void get_distance_between_selected_runes() {
    final indexes = List<int>.generate(selectedRunes.length, (index) => selectedRunes[index].index);

    final distance = (indexes[0] - indexes[1]).abs();

    GetIt.I.get<ConsoleState>(instanceName: 'analyze').write_to_console('Distance: ${selectedRunes[0].rune} <-> ${selectedRunes[1].rune} == $distance');
    GetIt.I.get<ConsoleState>(instanceName: 'analyze').write_to_console('Factors of (${distance}): ${distance.factors()}');
  }

  @action
  void get_selected_runes_information() {
    final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

    final selectedRuneLetters = List<String>.generate(selectedRunes.length, (index) => selectedRunes[index].rune);

    final primes = List<int>.generate(selectedRuneLetters.length, (index) => Conversions.runeToPrime(selectedRuneLetters[index]));
    final primesMod29 = List<int>.generate(selectedRuneLetters.length, (index) => Conversions.runeToPrime(selectedRuneLetters[index]) % 29);
    final positions = List<int>.generate(selectedRuneLetters.length, (index) => runes.indexOf(selectedRuneLetters[index]));

    final primeSum = primes.sum;
    final positionsSum = positions.sum;

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

    //

    final gp_word = <List<String>>[];

    final reversed_map = {for (var e in runePrimes.entries) int.parse(e.value): e.key};

    for (final rune in selectedRuneLetters) {
      final gp_possibilities = get_gp_modulos(runes.indexOf(rune));

      final poss = <String>[];
      for (final p in gp_possibilities) {
        poss.add(runeToEnglish[reversed_map[p]]);
      }

      gp_word.add(poss);
    }
    console.write_to_console('GP: $gp_word');

    final flat_gp = gp_word.expand((element) => element).toList();
    final flat_gp_to_indexes = List<int>.generate(flat_gp.length, (index) {
      int idx = runeEnglish.indexOf(flat_gp[index].toLowerCase());
      if (idx == -1) idx = altRuneEnglish.indexOf(flat_gp[index].toLowerCase());

      return idx;
    });

    final atbashedGP = List<String>.generate(flat_gp_to_indexes.length, (index) {
      int idx = runeEnglish.indexOf(flat_gp[index].toLowerCase());
      if (idx == -1) idx = altRuneEnglish.indexOf(flat_gp[index].toLowerCase());

      return runeEnglish[idx];
    });
    console.write_to_console('Atbash GP: ${atbashedGP.join()}');
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

      case 'i':
        {
          final pattern = RegExp('(ᛁ)');
          final matches = pattern.allMatches(cipher);

          matches.forEach((match) {
            highlight_rune('ᛁ', match.start, 'highlighter');
          });
        }
        break;

      case 'repeatedpatterns':
        {
          //TODO: all letters

          final Map<String, List<int>> letterIndexesOfOccurence = {};
          final grid_cipher = get_grid_cipher();
          for (int i = 0; i < grid_cipher.length; i++) {
            final current_character = grid_cipher.characters.elementAt(i);
            if (['%', r'$', '&', ' ', '-'].contains(current_character)) continue;

            letterIndexesOfOccurence[current_character] ??= [];

            letterIndexesOfOccurence[current_character].add(i);
          }

          final Map<int, int> seenFactors = {};

          letterIndexesOfOccurence.forEach((key, value) {
            final letter = key;

            for (int i = 0; i < value.length - 2; i++) {
              final curIndex = value[i];
              final nextIndex = value[i + 1];
              final nextNextIndex = value[i + 2];

              final curNextDiff = nextIndex - curIndex;
              final nextNextDiff = nextNextIndex - nextIndex;

              if (curNextDiff == nextNextDiff) {
                final factors = curNextDiff.factors();
                factors.forEach((element) {
                  if (seenFactors.containsKey(element)) {
                    seenFactors[element]++;
                  } else {
                    seenFactors[element] = 1;
                  }
                });

                highlight_rune(letter, curIndex, 'highlighter', ignoreDuplicates: true);
                highlight_rune(letter, nextIndex, 'highlighter', ignoreDuplicates: true);
                highlight_rune(letter, nextNextIndex, 'highlighter', ignoreDuplicates: true);
              }
            }
          });

          seenFactors.removeWhere((key, value) => value == 1);

          seenFactors.forEach((key, value) {
            print('Factor: $key | Times Occured: $value');
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

          final List<int> differences = [];

          for (int i = 0; i < matchIndexesStart.length - 1; i++) {
            final current = matchIndexesStart[i];
            final next = matchIndexesStart[i + 1];

            differences.add((next - current) - 1);
          }

          result.forEach((match) {
            highlight_rune('', match, 'highlighter');
          });
        }
        break;

      case 'neardoubleletters':
        {
          final int space = 2;
          final List<int> indexesToHighlight = [];
          final grid_cipher = get_grid_cipher();
          for (int i = 0; i < grid_cipher.length - space; i++) {
            final current_character = grid_cipher.characters.elementAt(i);
            if (['%', r'$', '&'].contains(current_character)) continue;

            final next_character = grid_cipher.characters.elementAt(i + space);

            if (current_character == next_character) indexesToHighlight.add(i);
          }

          indexesToHighlight.forEach((match) {
            highlight_rune('', match, 'highlighter');
            highlight_rune('', match + space, 'highlighter');
          });
        }
        break;

      case 'near2doubleletters':
        {
          const int space = 3;
          final List<int> indexesToHighlight = [];
          final grid_cipher = get_grid_cipher();
          for (int i = 0; i < grid_cipher.length - space; i++) {
            final current_character = grid_cipher.characters.elementAt(i);
            if (['%', r'$', '&'].contains(current_character)) continue;

            final next_character = grid_cipher.characters.elementAt(i + space);

            if (current_character == next_character) indexesToHighlight.add(i);
          }

          indexesToHighlight.forEach((match) {
            highlight_rune('', match, 'highlighter');
            highlight_rune('', match + space, 'highlighter');
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

      case 'englishtrigrams':
        {
          final english_trigrams = File('${Directory.current.path}/english_statistics/english_trigrams.txt').readAsLinesSync();

          for (final t in english_trigrams) {
            final split = t.split(' ');
            final trigram = split.first;
            final count = int.parse(split.last);

            if (count < 500000) continue;

            final splitTrigram = gematriaRegex.allMatches(trigram.toLowerCase()).map((e) => e.group(0)).toList(); // slow

            final runeTrigram = List<String>.generate(splitTrigram.length, (index) {
              int idx = runeEnglish.indexOf(splitTrigram[index]);
              idx ??= altRuneEnglish.indexOf(splitTrigram[index]);

              return runes[idx];
            }).join();

            final pattern = RegExp('($runeTrigram)', dotAll: true);
            final matches = pattern.allMatches(cipher);

            matches.forEach((match) {
              for (int i = match.start; i != match.end; i++) {
                highlight_rune('', i, 'highlighter');
              }
            });
          }
        }
        break;

      case 'rows':
        {
          final rows = GetIt.I<Cipher>().raw_cipher.length;
          final row_length = get_grid_x_axis_count();

          for (int x = 0; x < rows; x++) {
            if (x.isOdd) continue;

            final row_start = row_length * x;
            final row_end = row_start + row_length;

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
  String primeHighlightDropdownValue = 'primepairs';

  @action
  void changePrimeHighlightDropdownValue(String value) {
    primeHighlightDropdownValue = value;
  }

  @action
  void onPrimeHighlightDonePressed() {
    final cipher = get_grid_cipher();

    switch (primeHighlightDropdownValue) {
      case 'primepairs':
        {
          for (int i = 0; i < cipher.length; i = i + 2) {
            final characters = [cipher.characters.elementAt(i), cipher.characters.elementAt(i + 1)];

            final character_values = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              character_values.add(int.parse(runePrimes[character]));
            }

            final sum = character_values.sum;

            if (is_prime(sum)) {
              final col = get_prime_color(sum);

              highlight_rune('', i, 'highlighter', color: col);
              highlight_rune('', i + 1, 'highlighter', color: col);
            }
          }
        }
        break;

      case 'primetriads':
        {
          for (int i = 0; i < cipher.length; i = i + 3) {
            final characters = [cipher.characters.elementAt(i), cipher.characters.elementAt(i + 1), cipher.characters.elementAt(i + 2)];

            final character_values = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              character_values.add(int.parse(runePrimes[character]));
            }

            final sum = character_values.sum;

            if (is_prime(sum)) {
              final col = get_prime_color(sum);

              highlight_rune('', i, 'highlighter', color: col);
              highlight_rune('', i + 1, 'highlighter', color: col);
              highlight_rune('', i + 2, 'highlighter', color: col);
            }
          }
        }
        break;

      case 'primequartet':
        {
          for (int i = 0; i < cipher.length; i = i + 4) {
            final characters = [cipher.characters.elementAt(i), cipher.characters.elementAt(i + 1), cipher.characters.elementAt(i + 2), cipher.characters.elementAt(i + 3)];

            final character_values = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              character_values.add(int.parse(runePrimes[character]));
            }

            final sum = character_values.sum;

            if (is_prime(sum)) {
              final col = get_prime_color(sum);

              highlight_rune('', i, 'highlighter', color: col);
              highlight_rune('', i + 1, 'highlighter', color: col);
              highlight_rune('', i + 2, 'highlighter', color: col);
              highlight_rune('', i + 3, 'highlighter', color: col);
            }
          }
        }
        break;

      case 'primefives':
        {
          for (int i = 0; i < cipher.length; i = i + 5) {
            final characters = [cipher.characters.elementAt(i), cipher.characters.elementAt(i + 1), cipher.characters.elementAt(i + 2), cipher.characters.elementAt(i + 3), cipher.characters.elementAt(i + 4)];

            final character_values = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              character_values.add(int.parse(runePrimes[character]));
            }

            final sum = character_values.sum;

            if (is_prime(sum)) {
              final col = get_prime_color(sum);

              highlight_rune('', i, 'highlighter', color: col);
              highlight_rune('', i + 1, 'highlighter', color: col);
              highlight_rune('', i + 2, 'highlighter', color: col);
              highlight_rune('', i + 3, 'highlighter', color: col);
              highlight_rune('', i + 4, 'highlighter', color: col);
            }
          }
        }
        break;

      case 'specialprimerun':
        {
          final special_values = [1311];

          for (final value in special_values) {
            offsetloop:
            for (int offset = 0; offset < cipher.length; offset++) {
              final current_values = <int>[];
              for (int i = offset; i < cipher.length; i++) {
                final character = cipher.characters.elementAt(i);

                if (!runes.contains(character)) continue;

                current_values.add(int.parse(runePrimes[character]));

                final sum = current_values.sum;

                if (sum == value) {
                  final col = randomColor();

                  highlight_rune('', i - (current_values.length - 1), 'highlighter', color: col);
                  highlight_rune('', i, 'highlighter', color: col);
                }

                if (sum > value) continue offsetloop;
              }
            }
          }
        }
        break;

      case 'primerun':
        {
          final gp_values = <int>[];
          for (int i = 0; i < cipher.length; i++) {
            final character = cipher.characters.elementAt(i);

            if (!runes.contains(character)) continue;

            gp_values.add(int.parse(runePrimes[character]));

            final sum = gp_values.sum;

            if (!is_prime(sum)) {
              highlight_rune('', i, 'highlighter');
            } else {
              highlight_rune('', i, 'highlighter', color: get_prime_color(sum));
            }
          }
        }
        break;

      case 'primestoprun':
        {
          final gp_values = <int>[];
          for (int i = 0; i < cipher.length; i++) {
            final character = cipher.characters.elementAt(i);

            if (!runes.contains(character)) {
              gp_values.add(0);
              continue;
            }

            gp_values.add(int.parse(runePrimes[character]));

            if (gp_values.where((element) => element != 0).length <= 1) continue;

            final sum = gp_values.sum;

            if (is_prime(sum)) {
              // + 1 to shift to right
              final col = get_prime_color(sum);
              for (int x = (i - (gp_values.length)) + 1; x < (i + 1); x++) {
                highlight_rune('', x, 'highlighter', color: col);
              }

              gp_values.clear();
            }
          }
        }
        break;

      case 'primewordrun':
        {
          final formatted_cipher = cipher.replaceAll('%', '').replaceAll('.', ' ').split(' ');

          formatted_cipher.removeWhere((element) => element.length == 1);

          for (final word in formatted_cipher) {
            final split_word = word.split('');

            split_word.removeWhere((element) => !runes.contains(element));

            final gp_values = List<int>.generate(split_word.length, (index) => int.parse(runePrimes[split_word[index]]));

            final sum = gp_values.sum;

            if (is_prime(sum)) {
              final color = get_prime_color(sum);
              final pattern = RegExp('($word)[ %]');
              final matches = pattern.allMatches(cipher);

              matches.forEach((match) {
                if (match.start != match.end) {
                  for (int i = match.start; i < match.end - 1; i++) {
                    highlight_rune('', i, 'highlighter', color: color);
                  }
                } else {
                  highlight_rune('', match.start, 'highlighter', color: color);
                }
              });
            }
          }
        }
        break;

      case 'primesentencerun':
        {
          final formatted_cipher = cipher.replaceAll('%', '').split('.');

          formatted_cipher.removeWhere((element) => element.length == 1);

          for (final word in formatted_cipher) {
            final split_word = word.split('');

            split_word.removeWhere((element) => !runes.contains(element));

            final gp_values = List<int>.generate(split_word.length, (index) => int.parse(runePrimes[split_word[index]]));

            final sum = gp_values.sum;

            if (is_prime(sum)) {
              final color = get_prime_color(sum);
              final pattern = RegExp('($word)[ %.]');
              final matches = pattern.allMatches(cipher);

              matches.forEach((match) {
                if (match.start != match.end) {
                  for (int i = match.start; i < match.end - 1; i++) {
                    highlight_rune('', i, 'highlighter', color: color);
                  }
                } else {
                  highlight_rune('', match.start, 'highlighter', color: color);
                }
              });
            }
          }
        }
        break;

      case 'reverseprimerun':
        {
          final gp_values = <int>[];
          for (int i = cipher.length - 1; i != -1; i--) {
            final character = cipher.characters.elementAt(i);

            if (!runes.contains(character)) continue;

            gp_values.add(int.parse(runePrimes[character]));

            final sum = gp_values.sum;

            if (!is_prime(sum)) {
              highlight_rune('', i, 'highlighter');
            } else {
              highlight_rune('', i, 'highlighter', color: get_prime_color(sum));
            }
          }
        }
        break;
    }
  }

  @action
  void onHighlightRegexDonePressed(String regex) {
    final cipher = get_grid_cipher();

    final pattern = RegExp(regex);
    final matches = pattern.allMatches(cipher);

    matches.forEach((match) {
      if (match.start != match.end) {
        for (int i = match.start; i != match.end; i++) {
          highlight_rune('', i, 'highlighter');
        }
      } else {
        highlight_rune('', match.start, 'highlighter');
      }
    });
  }

  @observable
  String repeatedGramsSortedBy = 'count';

  @action
  void changeGramSortedBy(String value) {
    repeatedGramsSortedBy = value;
  }

  @observable
  String similarGramsSortedBy = 'count';

  @action
  void changeSimilarGramSortedBy(String value) {
    similarGramsSortedBy = value;
  }

  // selection

  @observable
  ObservableList<LiberTextClass> selectedRepeatedGrams = ObservableList();

  @observable
  ObservableList<LiberTextClass> selectedSimilarGrams = ObservableList();

  @observable
  ObservableList<LiberTextClass> selectedFrequencies = ObservableList();

  //

  final CribSettings cribSettings = CribSettings();

  final MagicSquareCribSettings magicSquareCribSettings = MagicSquareCribSettings();
}
