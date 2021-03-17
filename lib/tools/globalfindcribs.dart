import 'dart:io';

import 'package:cicadrypt/models/console_state.dart';
import 'package:cicadrypt/pages/analyze/analyze_state.dart';
import 'package:cicadrypt/services/crib.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:collection/collection.dart';

import '../constants/runes.dart';

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
                              List<String> words_to_find = wordTextController.text.replaceAll(' ', '').trim().split(',');
                              if (words_to_find.isEmpty) {
                                words_to_find.add(wordTextController.text);
                              }

                              final rune_words_to_find = <String>[];

                              for (final words in words_to_find) {
                                final gematria_characters = gematriaRegex.allMatches(words.toLowerCase()).map((e) => e.group(0)).toList(); // slow

                                final gematria = List<String>.generate(gematria_characters.length, (index) {
                                  final character = gematria_characters.elementAt(index);
                                  int idx = runeEnglish.indexOf(character);
                                  if (idx == -1) idx = altRuneEnglish.indexOf(character);

                                  if (idx == -1) {
                                    return character;
                                  } else {
                                    return runes[idx];
                                  }
                                }).join();

                                rune_words_to_find.add(gematria);
                              }

                              final words_length = List<int>.generate(rune_words_to_find.length, (index) => rune_words_to_find[index].length);

                              final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');
                              final analyze_state = GetIt.I.get<AnalyzeState>();

                              final page_directory = Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));
                              List<FileSystemEntity> pages = page_directory.listSync();
                              pages.removeWhere((element) => element.path.contains('chapter'));

                              final numberRegex = RegExp('[^0-9]');

                              pages = pages.sortedBy<num>((element) {
                                final path = element.path.replaceAll(numberRegex, '');

                                if (path.isEmpty) return 0;

                                return int.parse(path);
                              });

                              console.write_to_console('Starting global crib with output settings...');
                              console.write_to_console(analyze_state.cribSettings.outputFillers.join(' | ').trim());

                              for (final page in pages) {
                                if (!page.path.endsWith('.txt')) continue;

                                final page_handle = File(page.path);
                                final page_body = page_handle.readAsStringSync().trim().replaceAll(RegExp(r'[$&%]'), '').replaceAll('.', '-').replaceAll(RegExp(r'[a-zA-Z0-9]'), '').replaceAll(RegExp('\n'), '');

                                console.write_to_console('Results for ${page.path.split('/').last}');

                                final page_words = page_body.split('-');
                                page_words.removeWhere((element) => !words_length.contains(element.length));

                                if (page_words.isEmpty) continue;

                                for (final word in page_words) {
                                  final cribber = Crib(analyze_state.cribSettings, word);

                                  try {
                                    cribber.matches = await cribber.wordCrib(onlyIncludeWords: words_to_find);

                                    cribber.matches.forEach((element) {
                                      console.write_to_console('ioo(${page_words.indexOf(word)}) ${element.toConsoleString(analyze_state.cribSettings.outputFillers)}');
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              }

                              console.save_buffer_to_file('${Directory.current.path}/console_output/global_crib_${words_to_find.first}.txt');
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
