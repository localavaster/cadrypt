import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/runes.dart';
import '../constants/utils.dart';
import '../global/cipher.dart';
import '../models/console_state.dart';

class BodyInformation {
  BodyInformation(this.text);
  final String text;

  String toEnglish() {
    return List<String>.generate(text.characters.length, (index) {
      final character = text.characters.elementAt(index);

      if (runes.contains(character)) {
        return runeToEnglish[character];
      } else {
        return character;
      }
    }).join();
  }

  int total_characters() {
    int totalCharacters = 0;

    for (final character in text.characters) {
      if (runes.contains(character)) totalCharacters++;

      if (['-', ' ', '.'].contains(character)) totalCharacters++;

      if ('0123456789'.split('').contains(character)) totalCharacters++;
    }

    return totalCharacters;
  }

  int total_runes() {
    int totalRunes = 0;

    for (final character in text.characters) {
      if (runes.contains(character)) totalRunes++;
    }

    return totalRunes;
  }

  int total_spaces() {
    int totalSpaces = 0;

    for (final character in text.characters) {
      if ([' ', '-'].contains(character)) totalSpaces++;
    }

    return totalSpaces;
  }

  int gp_sum() {
    int sum = 0;

    for (final character in text.characters) {
      if (runes.contains(character)) {
        sum += int.parse(runePrimes[character]);
      }
    }

    return sum;
  }
}

Future<void> toolDumpPageInfo(BuildContext context) async {
  final consoleState = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final paths = ['${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'), '${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/')];

  for (final path in paths) {
    final basePath = Directory(path);
    final outputPath = Directory('${Directory.current.path}/dumped_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));

    for (final file in basePath.listSync()) {
      final pageName = file.path.split('/').last;

      if (!pageName.endsWith('.txt')) continue;

      final outputFile = File('${outputPath.path}/$pageName');

      final pageLines = File(file.path).readAsLinesSync()..removeWhere((element) => ['%', r'$', '&'].contains(element) && element.length == 1);
      final pageCharacters = pageLines.join().split('');

      final joinedPage = pageLines.join().replaceAll(RegExp(r'[$%&]'), '').replaceAll(' ', '-').replaceAll('.', '-');

      final rawWords = joinedPage.replaceAll(RegExp('[.0123456789a-zA-Z]'), '');

      // output

      final words = rawWords.split('-')..removeWhere((element) => element == null || element.isEmpty || element == ' ');
      final totalWords = words.length;
      final totalUniqueWords = words.toSet().toList().length;
      final repeatingWords = words.where((a) => words.count((b) => b == a) != 1).toSet().toList();
      int totalRunes = 0;
      int totalSpaces = 0;
      int totalPeriods = 0;
      int totalGpSum = 0;
      final totalLines = pageLines.length;
      Map<int, List<String>> sortedByLengthWords = <int, List<String>>{};
      Map<String, int> sortedByCountWords = <String, int>{};
      // sentences
      final sentences = joinedPage.split('.');
      final totalSentences = sentences.length;

      Map<String, int> characterFrequencies = <String, int>{};

      for (final rune in runes) {
        characterFrequencies[rune] = pageCharacters.count((character) => character == rune);
      }
      characterFrequencies = Map.fromEntries(characterFrequencies.entries.sortedBy<num>((element) => element.value));

      for (final word in words) {
        sortedByLengthWords[word.length] ??= [];

        sortedByLengthWords[word.length].add(word);
      }
      sortedByLengthWords = Map.fromEntries(sortedByLengthWords.entries.sortedBy<num>((element) => element.key));

      for (final word in words) {
        if (sortedByCountWords.containsKey(word)) {
          sortedByCountWords[word]++;
        } else {
          sortedByCountWords[word] = 1;
        }
      }
      sortedByCountWords = Map.fromEntries(sortedByCountWords.entries.sortedBy<num>((element) => element.value));

      joinedPage.characters.forEach((character) {
        if (runes.contains(character)) totalRunes++;

        if (character == '-') totalSpaces++;

        if (character == '.') totalPeriods++;

        if (runes.contains(character)) {
          final gpValue = int.parse(runePrimes[character]);

          totalGpSum += gpValue;
        }
      });

      if (outputFile.existsSync()) {
        outputFile.deleteSync();
        outputFile.createSync();
      } else {
        outputFile.createSync();
      }

      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);
      outputFile.writeAsStringSync('== Entire Page Statistics\n', mode: FileMode.append);
      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Total Words: $totalWords | PRIME: ${is_prime(totalWords)}\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Total Unique Words: $totalUniqueWords | PRIME: ${is_prime(totalUniqueWords)}\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Repeated Words: $repeatingWords\n', mode: FileMode.append);

      outputFile.writeAsStringSync('Total Runes: $totalRunes | PRIME: ${is_prime(totalRunes)}\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Total Spaces: $totalSpaces | PRIME: ${is_prime(totalSpaces)}\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Total Periods: $totalPeriods | PRIME: ${is_prime(totalPeriods)}\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Total GP sum: $totalGpSum | PRIME: ${is_prime(totalGpSum)}\n', mode: FileMode.append);

      outputFile.writeAsStringSync('Total Sentences: $totalSentences | PRIME: ${is_prime(totalSentences)}\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Total Lines: $totalLines | PRIME: ${is_prime(totalLines)}\n', mode: FileMode.append);

      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);
      outputFile.writeAsStringSync('== Character Frequencies\n', mode: FileMode.append);
      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final rune in characterFrequencies.keys) {
        final count = characterFrequencies[rune];

        outputFile.writeAsStringSync('$rune $count | PRIME: ${is_prime(count)}\n', mode: FileMode.append);
      }

      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);
      outputFile.writeAsStringSync('== Character Frequencies As Sums\n', mode: FileMode.append);
      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final rune in characterFrequencies.keys) {
        final count = characterFrequencies[rune];
        final runeGpValue = int.parse(runePrimes[rune]);

        outputFile.writeAsStringSync('$rune ${runeGpValue * count} | PRIME: ${is_prime(runeGpValue * count)}\n', mode: FileMode.append);
      }

      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);
      outputFile.writeAsStringSync('== Sentence Characteristics\n', mode: FileMode.append);
      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final sentence in sentences) {
        if (sentence.isEmpty) continue;

        final bodyinfo = BodyInformation(sentence);

        outputFile.writeAsStringSync('Sentence: $sentence\n', mode: FileMode.append);
        outputFile.writeAsStringSync('English Sentence: ${bodyinfo.toEnglish()}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('Total Characters: ${bodyinfo.total_characters()} | PRIME: ${is_prime(bodyinfo.total_characters())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('Total Runes: ${bodyinfo.total_runes()} | PRIME: ${is_prime(bodyinfo.total_runes())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('Total Spaces: ${bodyinfo.total_spaces()} | PRIME: ${is_prime(bodyinfo.total_spaces())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('GP Sum: ${bodyinfo.gp_sum()} | PRIME: ${is_prime(bodyinfo.gp_sum())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('IoC: ${GetIt.I<Cipher>().get_index_of_coincidence(text: bodyinfo.text)}\n', mode: FileMode.append);
        if (sentence != sentences.last) {
          outputFile.writeAsStringSync('\n', mode: FileMode.append);
        }
      }

      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);
      outputFile.writeAsStringSync('== Line Characteristics\n', mode: FileMode.append);
      outputFile.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final line in pageLines) {
        if (line.isEmpty) continue;

        final bodyinfo = BodyInformation(line);

        outputFile.writeAsStringSync('Line: $line\n', mode: FileMode.append);
        outputFile.writeAsStringSync('English Line: ${bodyinfo.toEnglish()}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('Total Characters: ${bodyinfo.total_characters()} | PRIME: ${is_prime(bodyinfo.total_characters())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('Total Runes: ${bodyinfo.total_runes()} | PRIME: ${is_prime(bodyinfo.total_runes())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('Total Spaces: ${bodyinfo.total_spaces()} | PRIME: ${is_prime(bodyinfo.total_spaces())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('GP Sum: ${bodyinfo.gp_sum()} | PRIME: ${is_prime(bodyinfo.gp_sum())}\n', mode: FileMode.append);
        outputFile.writeAsStringSync('IoC: ${GetIt.I<Cipher>().get_index_of_coincidence(text: bodyinfo.text)}\n', mode: FileMode.append);
        if (line != pageLines.last) {
          outputFile.writeAsStringSync('\n', mode: FileMode.append);
        }
      }
    }
  }
}
