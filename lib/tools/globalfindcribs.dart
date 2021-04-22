import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../constants/runes.dart';
import '../models/console_state.dart';
import '../pages/analyze/analyze_state.dart';
import '../services/crib.dart';

void toolGlobalFindCribs(BuildContext context) {
  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          // ignore: strict_raw_type

          final wordTextController = TextEditingController();

          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.20;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: wordTextController,
                          decoration: const InputDecoration().copyWith(labelText: 'Word to find', hintText: 'English Word'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: FlatButton(
                            color: Theme.of(context).backgroundColor,
                            onPressed: () async {
                              // results are {sequence, line numbers}
                              final results = <String, List<int>>{};
                              final List<String> wordsToFind = wordTextController.text.replaceAll(' ', '').trim().split(',');
                              if (wordsToFind.isEmpty) {
                                wordsToFind.add(wordTextController.text);
                              }

                              final runeWordsToFind = <String>[];

                              for (final words in wordsToFind) {
                                final gematriaCharacters = gematriaRegex.allMatches(words.toLowerCase()).map((e) => e.group(0)).toList(); // slow

                                final gematria = List<String>.generate(gematriaCharacters.length, (index) {
                                  final character = gematriaCharacters.elementAt(index);
                                  int idx = runeEnglish.indexOf(character);
                                  if (idx == -1) idx = altRuneEnglish.indexOf(character);

                                  if (idx == -1) {
                                    return character;
                                  } else {
                                    return runes[idx];
                                  }
                                }).join();

                                runeWordsToFind.add(gematria);
                              }

                              final wordsLength = List<int>.generate(runeWordsToFind.length, (index) => runeWordsToFind[index].length);

                              final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');
                              final analyzeState = GetIt.I.get<AnalyzeState>();

                              final pageDirectory = Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));
                              List<FileSystemEntity> pages = pageDirectory.listSync();
                              pages.removeWhere((element) => element.path.contains('chapter'));

                              final numberRegex = RegExp('[^0-9]');

                              pages = pages.sortedBy<num>((element) {
                                final path = element.path.replaceAll(numberRegex, '');

                                if (path.isEmpty) return 0;

                                return int.parse(path);
                              });

                              console.write_to_console('Starting global crib with output settings...');
                              console.write_to_console(analyzeState.cribSettings.outputFillers.join(' | ').trim());

                              for (final page in pages) {
                                if (!page.path.endsWith('.txt')) continue;

                                final pageHandle = File(page.path);
                                final pageBody = pageHandle.readAsStringSync().trim().replaceAll(RegExp(r'[$&%]'), '').replaceAll('.', '-').replaceAll(RegExp(r'[a-zA-Z0-9]'), '').replaceAll(RegExp('\n'), '');

                                console.write_to_console('Results for ${page.path.split('/').last}');

                                final pageWords = pageBody.split('-');
                                pageWords.removeWhere((element) => !wordsLength.contains(element.length));

                                if (pageWords.isEmpty) continue;

                                for (final word in pageWords) {
                                  final cribber = Crib(analyzeState.cribSettings, word);

                                  try {
                                    cribber.matches = await cribber.wordCrib(onlyIncludeWords: wordsToFind);

                                    cribber.matches.forEach((element) {
                                      console.write_to_console('ioo(${pageWords.indexOf(word)}) ${element.toConsoleString(analyzeState.cribSettings.outputFillers)}');
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              }

                              console.save_buffer_to_file('${Directory.current.path}/console_output/global_crib_${wordsToFind.first}.txt');
                            },
                            child: const Text('Find'),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      ),
    ),
  );
}
