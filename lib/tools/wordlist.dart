import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

void toolWordListViewer(BuildContext context) {
  // dont rebuild these with setstate
  final wordFile = File('${Directory.current.path}/english_words/cicada');
  final wordList = wordFile.readAsLinesSync().sortedBy<num>((element) => element.length);

  int currentSelectedWordLength = 1;

  List<String> visibleWordList = List.from(wordList)..removeWhere((element) => element.length != currentSelectedWordLength);

  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          final width = MediaQuery.of(context).size.width * 0.40;
          final height = MediaQuery.of(context).size.height * 0.80;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 22,
                          child: Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 15,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: (MediaQuery.of(context).size.width * 0.37) / 15,
                                  child: Material(
                                    color: (index + 1) == currentSelectedWordLength ? Colors.cyan.withOpacity(0.22) : Colors.black.withOpacity(0.22),
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        currentSelectedWordLength = (index + 1);

                                        visibleWordList = List.from(wordList)..removeWhere((element) => element.length != currentSelectedWordLength);
                                      }),
                                      child: Center(
                                        child: Text(
                                          (index + 1).toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: visibleWordList.length,
                        itemBuilder: (context, index) {
                          final word = visibleWordList[index];

                          return Container(
                            color: index.isOdd ? Colors.black.withOpacity(0.22) : Colors.black.withOpacity(0.37),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(word, style: const TextStyle(height: 1.0)),
                                  ),
                                  Row(
                                    children: [
                                      Text(word.length.toString(), style: const TextStyle(height: 1.0)),
                                      const SizedBox(width: 4),
                                      Material(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              wordList.removeWhere((element) => element == word);
                                            });
                                          },
                                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(
                        child: FlatButton(
                          color: Colors.green[300],
                          onPressed: () {
                            wordFile.deleteSync();
                            wordFile.createSync();

                            for (final word in wordList.toSet()) {
                              wordFile.writeAsStringSync('$word\n', mode: FileMode.append);
                            }
                          },
                          child: const Text('SAVE'),
                        ),
                      ),
                    ])
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
