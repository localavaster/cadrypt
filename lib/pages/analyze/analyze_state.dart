import 'dart:io';

import 'package:characters/characters.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../../constants/extensions.dart';
import '../../constants/libertext.dart';
import '../../constants/runes.dart';
import '../../constants/utils.dart';
import '../../global/cipher.dart';
import '../../models/console_state.dart';
import '../../models/crib_settings.dart';
import '../../models/magic_square_settings.dart';
import '../../models/rune_selection.dart';

part 'analyze_state.g.dart';

class AnalyzeState = _AnalyzeStateBase with _$AnalyzeState;

abstract class _AnalyzeStateBase with Store {
  final global_key = GlobalKey<State>();

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

      final splitSentences = temporary.split('.');

      for (final line in splitSentences) {
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

      result.removeWhere((element) => element.startsWith('.') && element.endsWith('%') && element.characters.elementAt(15) == '%');

      return result.join();
    } else if (cipherMode == '2x2') {
      // not the best
      final flatCipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flatCipher.length; i = i + 2) {
        buffer.write('${flatCipher.split('').sublist(i, (i + 2).clamp(0, flatCipher.length).toInt()).join()} ');
      }

      return buffer.toString();
    } else if (cipherMode == '3x3') {
      // not the best
      final flatCipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flatCipher.length; i = i + 3) {
        buffer.write('${flatCipher.split('').sublist(i, (i + 3).clamp(0, flatCipher.length).toInt()).join()} ');
      }

      return buffer.toString();
    } else if (cipherMode == '4x4') {
      // not the best
      final flatCipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flatCipher.length; i = i + 4) {
        buffer.write('${flatCipher.split('').sublist(i, (i + 4).clamp(0, flatCipher.length).toInt()).join()} ');
      }

      return buffer.toString();
    } else if (cipherMode == '5x5') {
      // not the best
      final flatCipher = GetIt.I<Cipher>().get_flat_cipher();
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i <= flatCipher.length; i = i + 5) {
        buffer.write('${flatCipher.split('').sublist(i, (i + 5).clamp(0, flatCipher.length).toInt()).join()} ');
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
      final gridCipher = get_grid_cipher();
      // ignore: parameter_assignments
      rune = gridCipher.split('').elementAt(index);
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

    final splitRunes = runes.split('');

    final selections = List<RuneSelection>.generate(splitRunes.length, (index) => RuneSelection(-1, splitRunes[index], type));

    selections.forEach((selection) {
      selectedRunes.add(selection);
    });
  }

  @observable
  ObservableList<RuneSelection> highlighedRunes = ObservableList();

  @action
  void highlight_rune(String rune, int index, String type, {bool ignoreDuplicates = false, Color color}) {
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
  void highlight_gram(String gram, {Color color}) {
    final buffer = StringBuffer(); // fix spaces, not the best
    for (int i = 0; i < gram.length; i++) {
      final character = gram.characters.elementAt(i);

      buffer.write(character);
      if (i != gram.length - 1) buffer.write('[ .%]*');
    }
    print(buffer.toString());
    final pattern = RegExp('(${buffer.toString()})');
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
  void select_highlighted_runes() {
    final highlightedIndexes = List<int>.generate(highlighedRunes.length, (index) => highlighedRunes[index].index);
    final gridCipher = get_grid_cipher();

    for (int i = 0; i < gridCipher.length; i++) {
      final character = gridCipher.characters.elementAt(i);

      if (highlightedIndexes.contains(i)) {
        select_rune(character, i, 'mouse');
      }
    }
  }

  @action
  void select_non_highlighted_runes() {
    final highlightedIndexes = List<int>.generate(highlighedRunes.length, (index) => highlighedRunes[index].index);
    final gridCipher = get_grid_cipher();

    for (int i = 0; i < gridCipher.length; i++) {
      final character = gridCipher.characters.elementAt(i);

      if (!highlightedIndexes.contains(i)) {
        select_rune(character, i, 'mouse');
      }
    }
  }

  @action
  void get_distance_between_selected_runes() {
    final indexes = List<int>.generate(selectedRunes.length, (index) => selectedRunes[index].index);

    final distance = (indexes[0] - indexes[1]).abs();

    GetIt.I.get<ConsoleState>(instanceName: 'analyze').write_to_console('Distance: ${selectedRunes[0].rune} <-> ${selectedRunes[1].rune} == $distance');
    GetIt.I.get<ConsoleState>(instanceName: 'analyze').write_to_console('Factors of ($distance): ${distance.factors()}');
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

    final gpWord = <List<String>>[];

    final reversedMap = {for (var e in runePrimes.entries) int.parse(e.value): e.key};

    for (final rune in selectedRuneLetters) {
      final gpPossibilities = get_gp_modulos(runes.indexOf(rune));

      final poss = <String>[];
      for (final p in gpPossibilities) {
        poss.add(runeToEnglish[reversedMap[p]]);
      }

      gpWord.add(poss);
    }
    console.write_to_console('GP: $gpWord');

    final flatGp = gpWord.expand((element) => element).toList();
    final flatGpToIndexes = List<int>.generate(flatGp.length, (index) {
      int idx = runeEnglish.indexOf(flatGp[index].toLowerCase());
      if (idx == -1) idx = altRuneEnglish.indexOf(flatGp[index].toLowerCase());

      return idx;
    });

    final atbashedGP = List<String>.generate(flatGpToIndexes.length, (index) {
      int idx = runeEnglish.indexOf(flatGp[index].toLowerCase());
      if (idx == -1) idx = altRuneEnglish.indexOf(flatGp[index].toLowerCase());

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
          final gridCipher = get_grid_cipher();
          for (int i = 0; i < gridCipher.length; i++) {
            final currentCharacter = gridCipher.characters.elementAt(i);
            if (['%', r'$', '&', ' ', '-'].contains(currentCharacter)) continue;

            letterIndexesOfOccurence[currentCharacter] ??= [];

            letterIndexesOfOccurence[currentCharacter].add(i);
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
          const int space = 2;
          final List<int> indexesToHighlight = [];
          final gridCipher = get_grid_cipher();
          for (int i = 0; i < gridCipher.length - space; i++) {
            final currentCharacter = gridCipher.characters.elementAt(i);
            if (['%', r'$', '&'].contains(currentCharacter)) continue;

            final nextCharacter = gridCipher.characters.elementAt(i + space);

            if (currentCharacter == nextCharacter) indexesToHighlight.add(i);
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
          final gridCipher = get_grid_cipher();
          for (int i = 0; i < gridCipher.length - space; i++) {
            final currentCharacter = gridCipher.characters.elementAt(i);
            if (['%', r'$', '&'].contains(currentCharacter)) continue;

            final nextCharacter = gridCipher.characters.elementAt(i + space);

            if (currentCharacter == nextCharacter) indexesToHighlight.add(i);
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

      case 'singleletterrunes':
        {
          final pattern = RegExp('[^ᚦᛇᛝᚫᛡᛠ]', dotAll: true);
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
          final englishTrigrams = File('${Directory.current.path}/english_statistics/english_trigrams.txt').readAsLinesSync();

          for (final t in englishTrigrams) {
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
          final rowLength = get_grid_x_axis_count();

          for (int x = 0; x < rows; x++) {
            if (x.isOdd) continue;

            final rowStart = rowLength * x;
            final rowEnd = rowStart + rowLength;

            for (int i = rowStart; i < rowEnd; i++) {
              highlight_rune('', i, 'highlighter');
            }
          }
        }
        break;

      case 'columns':
        {
          final columns = GetIt.I<Cipher>().raw_cipher.length;
          final rowLength = get_grid_x_axis_count();

          for (int x = 0; x < columns; x++) {
            final rowStart = rowLength * x;
            final rowEnd = rowStart + rowLength;

            for (int i = rowStart; i < rowEnd; i = i + 2) {
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

      case 'samegpwords':
        {
          final formattedCipher = cipher.replaceAll(RegExp(r'[%$&]'), '').replaceAll('.', ' ').replaceAll('-', ' ').split(' ');

          //formatted_cipher.removeWhere((element) => element.length == 1);

          int x = 0;
          final alreadyFound = <String>[];
          for (final word in formattedCipher) {
            if (alreadyFound.contains(word)) continue;
            final sum = LiberText(word).prime_sum;
            final duplicateSums = <String>[];

            for (final match in formattedCipher) {
              if (match == word) continue;

              if (match.length != word.length) continue;

              final matchSum = LiberText(match).prime_sum;

              if (matchSum == sum) duplicateSums.add(LiberText(match).rune);
            }

            if (duplicateSums.isNotEmpty) {
              alreadyFound.addAll(duplicateSums);
              alreadyFound.add(word);
              if (word.length >= 2) {
                x++;
                print('Group $x ${duplicateSums.length + 1}');
                print(word);
                duplicateSums.forEach(print);
              }

              final baseColor = randomColor();
              final originalPattern = RegExp('[-%&. ]($word)[-%&. ]');
              final matches = originalPattern.allMatches(cipher);

              for (final match in matches) {
                for (int i = match.start + 1; i < match.end - 1; i++) {
                  highlight_rune('', i, 'highlighter', color: baseColor, ignoreDuplicates: true);
                }
              }

              for (final sumword in duplicateSums) {
                final originalPattern = RegExp('[-%&. ]($sumword)[-%&. ]');
                final matches = originalPattern.allMatches(cipher);
                for (final match in matches) {
                  for (int i = match.start + 1; i < match.end - 1; i++) {
                    highlight_rune('', i, 'highlighter', color: baseColor, ignoreDuplicates: true);
                  }
                }
              }
              /*matches.forEach((match) {
                if (match.start != match.end) {
                  for (int i = match.start; i < match.end - 1; i++) {
                    highlight_rune('', i, 'highlighter', color: color);
                  }
                } else {
                  highlight_rune('', match.start, 'highlighter', color: color);
                }
              });*/
            }
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

            final characterValues = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              characterValues.add(int.parse(runePrimes[character]));
            }

            final sum = characterValues.sum;

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

            final characterValues = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              characterValues.add(int.parse(runePrimes[character]));
            }

            final sum = characterValues.sum;

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

            final characterValues = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              characterValues.add(int.parse(runePrimes[character]));
            }

            final sum = characterValues.sum;

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

            final characterValues = <int>[];
            for (final character in characters) {
              if (!runes.contains(character)) continue;

              characterValues.add(int.parse(runePrimes[character]));
            }

            final sum = characterValues.sum;

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
          final specialValues = [1311];

          for (final value in specialValues) {
            offsetloop:
            for (int offset = 0; offset < cipher.length; offset++) {
              final currentValues = <int>[];
              for (int i = offset; i < cipher.length; i++) {
                final character = cipher.characters.elementAt(i);

                if (!runes.contains(character)) continue;

                currentValues.add(int.parse(runePrimes[character]));

                final sum = currentValues.sum;

                if (sum == value) {
                  final col = randomColor();

                  highlight_rune('', i - (currentValues.length - 1), 'highlighter', color: col);
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
          final gpValues = <int>[];
          for (int i = 0; i < cipher.length; i++) {
            final character = cipher.characters.elementAt(i);

            if (!runes.contains(character)) continue;

            gpValues.add(int.parse(runePrimes[character]));

            final sum = gpValues.sum;

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
          final gpValues = <int>[];
          for (int i = 0; i < cipher.length; i++) {
            final character = cipher.characters.elementAt(i);

            if (!runes.contains(character)) {
              gpValues.add(0);
              continue;
            }

            gpValues.add(int.parse(runePrimes[character]));

            if (gpValues.where((element) => element != 0).length <= 1) continue;

            final sum = gpValues.sum;

            if (is_prime(sum)) {
              // + 1 to shift to right
              final col = get_prime_color(sum);
              for (int x = (i - (gpValues.length)) + 1; x < (i + 1); x++) {
                highlight_rune('', x, 'highlighter', color: col);
              }

              gpValues.clear();
            }
          }
        }
        break;

      case 'primewordrun':
        {
          final formattedCipher = cipher.replaceAll('%', '').replaceAll('.', ' ').split(' ');

          formattedCipher.removeWhere((element) => element.length == 1);

          for (final word in formattedCipher) {
            final splitWord = word.split('');

            splitWord.removeWhere((element) => !runes.contains(element));

            final gpValues = List<int>.generate(splitWord.length, (index) => int.parse(runePrimes[splitWord[index]]));

            final sum = gpValues.sum;

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
          final formattedCipher = cipher.replaceAll('%', '').split('.');

          formattedCipher.removeWhere((element) => element.length == 1);

          for (final word in formattedCipher) {
            final splitWord = word.split('');

            splitWord.removeWhere((element) => !runes.contains(element));

            final gpValues = List<int>.generate(splitWord.length, (index) => int.parse(runePrimes[splitWord[index]]));

            final sum = gpValues.sum;

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
          final gpValues = <int>[];
          for (int i = cipher.length - 1; i != -1; i--) {
            final character = cipher.characters.elementAt(i);

            if (!runes.contains(character)) continue;

            gpValues.add(int.parse(runePrimes[character]));

            final sum = gpValues.sum;

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

  @action
  void onHighlightEveryNthCharacterDonePressed(String number) {
    final cipher = get_grid_cipher();

    final parsedNumber = int.tryParse(number);

    if (parsedNumber == null) return;

    for (int i = 0; i < cipher.length; i++) {
      if (i % parsedNumber == 0) highlight_rune('', i, 'highlighter');
    }
  }

  @action
  void onHighlightSimplePatternDonePressed(String pattern) {
    final cipher = get_grid_cipher();

    final formattedPattern = pattern.trim().toLowerCase();
    final formattedKey = formattedPattern.allAfter(' ');

    final characterToHighlight = formattedPattern.characters.first;

    final highlightKey = List<bool>.generate(formattedKey.length, (index) {
      final character = formattedKey.characters.elementAt(index);

      if (character == characterToHighlight) {
        return true;
      } else {
        return false;
      }
    });

    int keyPosition = 0;
    for (int i = 0; i < cipher.length; i++) {
      final keyValue = highlightKey[(i % highlightKey.length)];
      if (keyValue == true) {
        highlight_rune('', i, 'highlighter');
      }
      keyPosition++;
    }
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
