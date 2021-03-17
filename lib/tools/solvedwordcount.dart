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

Future<void> toolSolvedWordCount(BuildContext context) async {
  bool save_to_file = true;

  final cicada_wordlist = File('${Directory.current.path}/english_words/cicada');

  if (save_to_file) {
    if (cicada_wordlist.existsSync()) {
      cicada_wordlist.deleteSync();
      cicada_wordlist.createSync();
    } else {
      cicada_wordlist.createSync();
    }
  }

  final console_state = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final paths = [Directory('${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'))];

  // word, seen count
  Map<String, int> results = {};

  for (final file in paths.first.listSync()) {
    final page_name = file.path.split('/').last;

    if (!page_name.endsWith('.txt')) continue;
    if (!page_name.contains('deciphered')) continue;

    final page_body = File(file.path).readAsLinesSync().join();
    final formatted_page_body = page_body.replaceAll(RegExp(r'[$%&]'), '').replaceAll(' ', '-').replaceAll('.', '-');

    final page_words = formatted_page_body.split('-');

    for (final word in page_words) {
      final english = List<String>.generate(word.length, (index) => runeToEnglish[word.characters.elementAt(index)]).join();

      if (results.containsKey(english)) {
        results[english]++;
      } else {
        results[english] = 1;
      }
    }
  }

  results = SortedMap.from(results, const Ordering.byValue());

  console_state.write_to_console('WORD | SEEN COUNT');
  results.forEach((key, value) {
    console_state.write_to_console('$key | $value');
  });

  if (save_to_file) {
    results.forEach((key, value) {
      cicada_wordlist.writeAsStringSync('${key.toLowerCase()}\n', mode: FileMode.append);
    });
  }
}
