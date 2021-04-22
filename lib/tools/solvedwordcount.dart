import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../constants/runes.dart';
import '../models/console_state.dart';

Future<void> toolSolvedWordCount(BuildContext context) async {
  const bool saveToFile = true;

  final cicadaWordlist = File('${Directory.current.path}/english_words/cicada');

  if (saveToFile) {
    if (cicadaWordlist.existsSync()) {
      cicadaWordlist.deleteSync();
      cicadaWordlist.createSync();
    } else {
      cicadaWordlist.createSync();
    }
  }

  final consoleState = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final paths = [Directory('${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'))];

  // word, seen count
  Map<String, int> results = {};

  for (final file in paths.first.listSync()) {
    final pageName = file.path.split('/').last;

    if (!pageName.endsWith('.txt')) continue;
    if (!pageName.contains('deciphered')) continue;

    final pageBody = File(file.path).readAsLinesSync().join();
    final formattedPageBody = pageBody.replaceAll(RegExp(r'[$%&]'), '').replaceAll(' ', '-').replaceAll('.', '-');

    final pageWords = formattedPageBody.split('-');

    for (final word in pageWords) {
      final english = List<String>.generate(word.length, (index) => runeToEnglish[word.characters.elementAt(index)]).join();

      if (results.containsKey(english)) {
        results[english]++;
      } else {
        results[english] = 1;
      }
    }
  }

  final sortedEntries = results.entries.sortedBy<num>((element) => element.value);

  results = Map.fromEntries(sortedEntries);

  consoleState.write_to_console('WORD | SEEN COUNT');
  results.forEach((key, value) {
    consoleState.write_to_console('$key | $value');
  });

  if (saveToFile) {
    results.forEach((key, value) {
      cicadaWordlist.writeAsStringSync('${key.toLowerCase()}\n', mode: FileMode.append);
    });
  }
}
