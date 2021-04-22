import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/runes.dart';
import '../models/console_state.dart';

Future<void> toolEnglishWordCount(BuildContext context) async {
  const bool saveToFile = true;

  final englishWords = File('${Directory.current.path}/english_words/all').readAsLinesSync();

  final consoleState = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final paths = [Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'))];

  // word, seen count
  final Map<String, int> results = {};

  final List<String> globalWords = <String>[];

  for (final file in paths.first.listSync()) {
    final pageName = file.path.split('/').last;

    if (!pageName.endsWith('.txt')) continue;
    if (!pageName.contains('chapter')) continue;
    if (pageName.contains('numbers')) continue;

    final pageBody = File(file.path).readAsLinesSync().join();
    final formattedPageBody = pageBody.replaceAll(RegExp(r'[$%&]'), '').replaceAll(' ', '-').replaceAll('.', '-');

    final pageWords = formattedPageBody.split('-');

    print(pageWords);

    final foundPageWords = <String>[];
    consoleState.write_to_console('-> $pageName');

    for (final word in pageWords) {
      final english = List<String>.generate(word.length, (index) => runeToEnglish[word.characters.elementAt(index)]).join();

      if (englishWords.contains(english.toLowerCase())) {
        if (english == 'null') {
          foundPageWords.add(word);
        } else {
          foundPageWords.add(english);
        }
      }
    }

    globalWords.addAll(foundPageWords);
    foundPageWords.toSet().toList().forEach(consoleState.write_to_console);
  }

  consoleState.write_to_console('Multiple Occurences');
  for (final word in globalWords) {
    final count = globalWords.count((element) => element == word);

    if (count > 1) {
      consoleState.write_to_console(word);
    }
  }
}
