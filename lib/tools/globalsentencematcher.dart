import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/runes.dart';
import '../models/console_state.dart';
import '../pages/analyze/analyze_state.dart';

void toolGlobalFindSentence(BuildContext context) {
  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          // ignore: strict_raw_type

          final sentenceTextController = TextEditingController();

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
                          controller: sentenceTextController,
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
                              final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');
                              final analyzeState = GetIt.I.get<AnalyzeState>();

                              // parse pages
                              for (int sentenceLength = 3; sentenceLength < 16; sentenceLength++) {
                                List<String> sentences = <String>[];

                                final solvedPages = Directory('${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));

                                for (final page in solvedPages.listSync()) {
                                  if (!page.path.endsWith('.txt')) continue;
                                  if (!page.path.contains('deciphered')) continue;

                                  final pageHandle = File(page.path);
                                  // ignore: unnecessary_raw_strings
                                  final pageBody = pageHandle.readAsStringSync().trim().replaceAll(RegExp(r'[$&%]'), '').replaceAll('.', '-').replaceAll(RegExp(r'[a-zA-Z0-9]'), '').replaceAll(RegExp('\n'), '').replaceAll('-', ' ');
                                  final pageWords = pageBody.split(' ');
                                  pageWords.removeWhere((element) => element.isEmpty || element == null);

                                  for (int i = 0; i < pageWords.length; i++) {
                                    final int offset = sentenceLength;
                                    final sentence = pageWords.sublist(i, (i + offset).clamp(0, pageWords.length).toInt());
                                    if (sentence.length == offset) {
                                      sentences.add(sentence.join(' '));
                                    }
                                  }
                                }

                                sentences = sentences.toSet().toList();

                                // parse pages

                                final pageDirectory = Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));
                                List<FileSystemEntity> pages = pageDirectory.listSync();
                                pages.removeWhere((element) => !element.path.contains('chapter'));

                                final numberRegex = RegExp('[^0-9]');

                                pages = pages.sortedBy<num>((element) {
                                  final path = element.path.replaceAll(numberRegex, '');

                                  if (path.isEmpty) return 0;

                                  return int.parse(path);
                                });

                                print(pages);

                                for (final sentence in sentences) {
                                  // sentence, pagename, listofoccurences
                                  final sentenceMatches = <String, Map<String, List<String>>>{};

                                  for (final page in pages) {
                                    sentenceMatches[sentence] ??= {};

                                    if (!page.path.endsWith('.txt')) continue;

                                    final pageHandle = File(page.path);
                                    final pageBody = pageHandle.readAsStringSync().trim().replaceAll(RegExp(r'[$&%]'), '').replaceAll(RegExp(r'[a-zA-Z0-9]'), '').replaceAll('-', ' ');

                                    final sentenceToFind = sentence.replaceAll(RegExp('[^ ]'), '[${runes.join()}]');

                                    final regexSentence = RegExp('([. ]$sentenceToFind[. ])');

                                    final matches = regexSentence.allMatches(pageBody.replaceAll(RegExp('\n'), ''));

                                    //print('parsing page: ${page_handle.path.split('/').last.allBefore('.')} matcher: $regexSentence. matches: ${matches.length}');

                                    matches.forEach((element) {
                                      sentenceMatches[sentence][pageHandle.path.split('/').last.allBefore('.')] ??= [];

                                      sentenceMatches[sentence][pageHandle.path.split('/').last.allBefore('.')].add(element.group(0));
                                    });
                                  }

                                  if (sentenceMatches[sentence].isNotEmpty) {
                                    final sentenceEnglish = List<String>.generate(sentence.length, (index) {
                                      final character = sentence.characters.elementAt(index);
                                      if (!runes.contains(character)) {
                                        return '_';
                                      } else {
                                        final idx = runes.indexOf(character);

                                        return runeEnglish[idx];
                                      }
                                    });

                                    sentenceMatches[sentence].forEach((key, value) {
                                      final pageName = key;
                                      final indexes = value;

                                      final outputFile = File('${Directory.current.path}/console_output/sentence_finder/${sentenceLength}_${pageName}_${sentenceEnglish.join()}');
                                      if (outputFile.existsSync()) {
                                        outputFile.deleteSync();
                                        outputFile.createSync();
                                      } else {
                                        outputFile.createSync();
                                      }

                                      indexes.forEach((element) {
                                        outputFile.writeAsStringSync('${element.replaceAll(' ', '-')}\n', mode: FileMode.append);
                                      });
                                    });
                                  }
                                }
                              }

                              /*final rebuilt_gematria_characters = <String>[];

                              for (final word in sentenceTextController.text.split(' ')) {
                                final gematria_characters = gematriaRegex.allMatches(word.toLowerCase()).map((e) => e.group(0)).toList();

                                final buffer = StringBuffer();
                                for (final character in gematria_characters) {
                                  int english_idx = runeEnglish.indexOf(character);
                                  if (english_idx == -1) english_idx = altRuneEnglish.indexOf(character);
                                  buffer.write(runes[english_idx]);
                                }

                                rebuilt_gematria_characters.add(buffer.toString());
                              }

                              final sentenceToFind = rebuilt_gematria_characters.join(' ').replaceAll(RegExp('[^ ]'), '[${runes.join()}]');

                              final regexSentence = RegExp('([. ]$sentenceToFind[. ])');

                              print(regexSentence);

                              final page_directory = Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));
                              List<FileSystemEntity> pages = page_directory.listSync();
                              pages.removeWhere((element) => element.path.contains('chapter'));

                              final numberRegex = RegExp('[^0-9]');

                              pages = pages.sortedBy<num>((element) {
                                final path = element.path.replaceAll(numberRegex, '');

                                if (path.isEmpty) return 0;

                                return int.parse(path);
                              });

                              console.write_to_console('Starting global crib for (${sentenceTextController.text}) with output settings...');
                              console.write_to_console(analyze_state.cribSettings.outputFillers.join(' | ').trim());

                              for (final page in pages) {
                                if (!page.path.endsWith('.txt')) continue;

                                final page_handle = File(page.path);
                                final page_body = page_handle.readAsStringSync().trim().replaceAll(RegExp(r'[$&%]'), '').replaceAll('.', '-').replaceAll(RegExp(r'[a-zA-Z0-9]'), '').replaceAll(RegExp('\n'), '').replaceAll('-', ' ');

                                console.write_to_console('Results for ${page.path.split('/').last}');

                                print(page_body);

                                final matches = regexSentence.allMatches(page_body);

                                matches.forEach((element) {
                                  console.write_to_console('${element.start}-${element.end} -> ${element.group(0)}');
                                });
                              }*/
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
