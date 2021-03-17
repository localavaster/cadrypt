import 'dart:io';

import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../global/cipher.dart';
import '../models/console_state.dart';
import '../models/crib_settings.dart';
import '../services/crib.dart';

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
    int total_characters = 0;

    for (final character in text.characters) {
      if (runes.contains(character)) total_characters++;

      if (['-', ' ', '.'].contains(character)) total_characters++;

      if ('0123456789'.split('').contains(character)) total_characters++;
    }

    return total_characters;
  }

  int total_runes() {
    int total_runes = 0;

    for (final character in text.characters) {
      if (runes.contains(character)) total_runes++;
    }

    return total_runes;
  }

  int total_spaces() {
    int total_spaces = 0;

    for (final character in text.characters) {
      if ([' ', '-'].contains(character)) total_spaces++;
    }

    return total_spaces;
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
  final console_state = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final paths = ['${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'), '${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/')];

  for (final path in paths) {
    final basePath = Directory(path);
    final outputPath = Directory('${Directory.current.path}/dumped_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));

    for (final file in basePath.listSync()) {
      final page_name = file.path.split('/').last;

      if (!page_name.endsWith('.txt')) continue;

      final output_file = File('${outputPath.path}/${page_name}');

      final page_lines = File(file.path).readAsLinesSync()..removeWhere((element) => ['%', r'$', '&'].contains(element) && element.length == 1);
      final page_characters = page_lines.join().split('');

      final joined_page = page_lines.join().replaceAll(RegExp(r'[$%&]'), '').replaceAll(' ', '-').replaceAll('.', '-');

      final raw_words = joined_page.replaceAll(RegExp('[.0123456789a-zA-Z]', dotAll: false), '');

      // output

      final words = raw_words.split('-')..removeWhere((element) => element == null || element.isEmpty || element == ' ');
      final total_words = words.length;
      final total_unique_words = words.toSet().toList().length;
      final repeating_words = words.where((a) => words.count((b) => b == a) != 1).toSet().toList();
      int total_runes = 0;
      int total_spaces = 0;
      int total_periods = 0;
      int total_gp_sum = 0;
      final total_lines = page_lines.length;
      Map<int, List<String>> sorted_by_length_words = <int, List<String>>{};
      Map<String, int> sorted_by_count_words = <String, int>{};
      // sentences
      final sentences = joined_page.split('.');
      final total_sentences = sentences.length;

      Map<String, int> character_frequencies = <String, int>{};

      for (final rune in runes) {
        character_frequencies[rune] = page_characters.count((character) => character == rune);
      }
      character_frequencies = SortedMap.from(character_frequencies, const Ordering.byValue());

      for (final word in words) {
        sorted_by_length_words[word.length] ??= [];

        sorted_by_length_words[word.length].add(word);
      }
      sorted_by_length_words = SortedMap<int, List<String>>.from(sorted_by_length_words, const Ordering.byKey());

      for (final word in words) {
        if (sorted_by_count_words.containsKey(word)) {
          sorted_by_count_words[word]++;
        } else {
          sorted_by_count_words[word] = 1;
        }
      }
      sorted_by_count_words = SortedMap.from(sorted_by_count_words, const Ordering.byValue());

      joined_page.characters.forEach((character) {
        if (runes.contains(character)) total_runes++;

        if (character == '-') total_spaces++;

        if (character == '.') total_periods++;

        if (runes.contains(character)) {
          final gp_value = int.parse(runePrimes[character]);

          total_gp_sum += gp_value;
        }
      });

      if (output_file.existsSync()) {
        output_file.deleteSync();
        output_file.createSync();
      } else {
        output_file.createSync();
      }

      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);
      output_file.writeAsStringSync('== Entire Page Statistics\n', mode: FileMode.append);
      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);
      output_file.writeAsStringSync('Total Words: ${total_words} | PRIME: ${is_prime(total_words)}\n', mode: FileMode.append);
      output_file.writeAsStringSync('Total Unique Words: ${total_unique_words} | PRIME: ${is_prime(total_unique_words)}\n', mode: FileMode.append);
      output_file.writeAsStringSync('Repeated Words: ${repeating_words}\n', mode: FileMode.append);

      output_file.writeAsStringSync('Total Runes: ${total_runes} | PRIME: ${is_prime(total_runes)}\n', mode: FileMode.append);
      output_file.writeAsStringSync('Total Spaces: ${total_spaces} | PRIME: ${is_prime(total_spaces)}\n', mode: FileMode.append);
      output_file.writeAsStringSync('Total Periods: ${total_periods} | PRIME: ${is_prime(total_periods)}\n', mode: FileMode.append);
      output_file.writeAsStringSync('Total GP sum: ${total_gp_sum} | PRIME: ${is_prime(total_gp_sum)}\n', mode: FileMode.append);

      output_file.writeAsStringSync('Total Sentences: ${total_sentences} | PRIME: ${is_prime(total_sentences)}\n', mode: FileMode.append);
      output_file.writeAsStringSync('Total Lines: ${total_lines} | PRIME: ${is_prime(total_lines)}\n', mode: FileMode.append);

      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);
      output_file.writeAsStringSync('== Character Frequencies\n', mode: FileMode.append);
      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final rune in character_frequencies.keys) {
        final count = character_frequencies[rune];

        output_file.writeAsStringSync('$rune $count | PRIME: ${is_prime(count)}\n', mode: FileMode.append);
      }

      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);
      output_file.writeAsStringSync('== Character Frequencies As Sums\n', mode: FileMode.append);
      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final rune in character_frequencies.keys) {
        final count = character_frequencies[rune];
        final rune_gp_value = int.parse(runePrimes[rune]);

        output_file.writeAsStringSync('$rune ${rune_gp_value * count} | PRIME: ${is_prime(rune_gp_value * count)}\n', mode: FileMode.append);
      }

      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);
      output_file.writeAsStringSync('== Sentence Characteristics\n', mode: FileMode.append);
      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final sentence in sentences) {
        if (sentence.isEmpty) continue;

        final bodyinfo = BodyInformation(sentence);

        output_file.writeAsStringSync('Sentence: $sentence\n', mode: FileMode.append);
        output_file.writeAsStringSync('English Sentence: ${bodyinfo.toEnglish()}\n', mode: FileMode.append);
        output_file.writeAsStringSync('Total Characters: ${bodyinfo.total_characters()} | PRIME: ${is_prime(bodyinfo.total_characters())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('Total Runes: ${bodyinfo.total_runes()} | PRIME: ${is_prime(bodyinfo.total_runes())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('Total Spaces: ${bodyinfo.total_spaces()} | PRIME: ${is_prime(bodyinfo.total_spaces())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('GP Sum: ${bodyinfo.gp_sum()} | PRIME: ${is_prime(bodyinfo.gp_sum())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('IoC: ${GetIt.I<Cipher>().get_index_of_coincidence(text: bodyinfo.text)}\n', mode: FileMode.append);
        if (sentence != sentences.last) {
          output_file.writeAsStringSync('\n', mode: FileMode.append);
        }
      }

      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);
      output_file.writeAsStringSync('== Line Characteristics\n', mode: FileMode.append);
      output_file.writeAsStringSync('==========================\n', mode: FileMode.append);

      for (final line in page_lines) {
        if (line.isEmpty) continue;

        final bodyinfo = BodyInformation(line);

        output_file.writeAsStringSync('Line: $line\n', mode: FileMode.append);
        output_file.writeAsStringSync('English Line: ${bodyinfo.toEnglish()}\n', mode: FileMode.append);
        output_file.writeAsStringSync('Total Characters: ${bodyinfo.total_characters()} | PRIME: ${is_prime(bodyinfo.total_characters())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('Total Runes: ${bodyinfo.total_runes()} | PRIME: ${is_prime(bodyinfo.total_runes())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('Total Spaces: ${bodyinfo.total_spaces()} | PRIME: ${is_prime(bodyinfo.total_spaces())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('GP Sum: ${bodyinfo.gp_sum()} | PRIME: ${is_prime(bodyinfo.gp_sum())}\n', mode: FileMode.append);
        output_file.writeAsStringSync('IoC: ${GetIt.I<Cipher>().get_index_of_coincidence(text: bodyinfo.text)}\n', mode: FileMode.append);
        if (line != page_lines.last) {
          output_file.writeAsStringSync('\n', mode: FileMode.append);
        }
      }
    }
  }
}
