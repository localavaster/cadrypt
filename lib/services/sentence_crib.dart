import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trotter/trotter.dart' as trotter;

import '../constants/runes.dart';
import '../constants/utils.dart';
import '../models/crib_match.dart';
import '../models/crib_settings.dart';
import '../models/sentence_crib_match.dart';
import 'crib.dart';

class SentenceCrib {
  SentenceCrib(this.context, this.settings, this.runeWords);

  final BuildContext context;
  final CribSettings settings;
  final List<String> runeWords;
  List<SentenceCribMatch> matches = [];

  Future<List<SentenceCribMatch>> sentenceCrib() async {
    List<List<int>> possibleWords = [];
    print('Generating possible words');

    for (final word in runeWords) {
      final crib = Crib(settings, word);

      List<CribMatch> matches = await crib.wordCrib();

      if (matches.length > 1000) {
        matches = matches.sublist(0, 1000);
      }

      matches.forEach((element) {
        possibleWords.add(element.crib_in_prime_form);
      });
    }

    // remove duplicates, not sure if an if contains is faster, honestly, also doesnt work for multiple words with same length
    possibleWords = possibleWords.toSet().toList();

    possibleWords.removeWhere((element) => element.contains(null));

    final reversedMap = {for (var e in letterToPrime.entries) e.value: e.key};

    bool shouldContinue = false;
    await showDialog<void>(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.30),
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: StatefulBuilder(
          builder: (context, setState) {
            // ignore: strict_raw_type
            final width = MediaQuery.of(context).size.width * 0.50;
            final height = MediaQuery.of(context).size.height * 0.90;
            return SizedBox(
              width: width,
              height: height,
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total permutations ${pow(possibleWords.length, runeWords.length)}'),
                      Text('Total words ${possibleWords.length}'),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: possibleWords.length,
                          itemBuilder: (context, index) {
                            final word = possibleWords[index];
                            return Container(
                              color: index.isOdd ? Colors.black.withOpacity(0.22) : Colors.black.withOpacity(0.37),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Builder(builder: (context) {
                                        if (word.length == 1 && word[0] == 0) {
                                          return const Text('DUMMYZERO', style: TextStyle(height: 1.0));
                                        }

                                        return Text(List<String>.generate(word.length, (index) => reversedMap[word[index]]).join(), style: const TextStyle(height: 1.0));
                                      }),
                                    ),
                                    Row(
                                      children: [
                                        Text(word.length.toString(), style: const TextStyle(height: 1.0)),
                                        const SizedBox(width: 4),
                                        Material(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                possibleWords.removeWhere((element) => element == possibleWords[index]);
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
                      Row(children: [
                        Expanded(
                          child: FlatButton(
                            color: Colors.red,
                            onPressed: () {
                              shouldContinue = false;
                              Navigator.of(context).pop();
                            },
                            child: const Text('CANCEL'),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            color: Colors.green[300],
                            onPressed: () {
                              shouldContinue = true;
                              Navigator.of(context).pop();
                            },
                            child: const Text('GO!'),
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

    await Future.delayed(const Duration(milliseconds: 400));

    if (!shouldContinue) return [];

    print('Total possible words: ${possibleWords.length}');

    // now lets create a file
    final outputFile = File('${Directory.current.path}/cribs/sentences/${runeWords.join('_')}.txt');

    if (outputFile.existsSync()) {
      outputFile.deleteSync();
      outputFile.createSync();
    } else {
      outputFile.createSync();
    }

    final outputSink = outputFile.openWrite(mode: FileMode.append);
    //time to generate permutations
    int totalRuneCharacters = 0;
    for (final word in runeWords) {
      totalRuneCharacters += word.length;
    }

    final runeWordsLength = List<int>.generate(runeWords.length, (index) => runeWords[index].length);
    final runeWordsLengthSum = runeWordsLength.sum;
    bool useLoop = false;
    final int pairsToGenerate = runeWords.length;
    if (pairsToGenerate == 2 || pairsToGenerate == 3 || pairsToGenerate == 4) {
      useLoop = true;
    }

    final highestPossibleNumber = 109 * runeWordsLengthSum;
    final sievedPrimes = prime_sieve(highestPossibleNumber);

    // what are the odds?
    sievedPrimes.removeWhere((element) => element <= (3 * totalRuneCharacters.floor()));
    //sieved_primes.removeWhere((element) => element >= (105 * (totalRuneCharacters / 3).floor()));

    final binaryTree = SplayTreeSet<int>.from(sievedPrimes.reversed); // place highest first, splay tree will give faster results as we go on,

    print('Total Primes: ${sievedPrimes.length}');
    print('First Prime: ${sievedPrimes.first}');
    print('Last Prime: ${sievedPrimes.last}');

    final timeNow = DateTime.now();

    if (useLoop) {
      // why did i write these out by hand, o(n) is clearly p
      if (pairsToGenerate == 2) {
        int iterations = 0;

        final List<List<int>> firstWords = possibleWords.where((element) => element.length == runeWords.first.length).toSet().toList();
        final List<List<int>> secondWords = possibleWords.where((element) => element.length == runeWords[1].length).toSet().toList();
        for (int first = 0; first < firstWords.length; first++) {
          for (int second = 0; second < secondWords.length; second++) {
            iterations++;

            if (iterations % 100000 == 0) {
              print(iterations);
            }

            if (iterations % 1000000 == 0) {
              await outputSink.flush();
            }

            final word = firstWords[first] + secondWords[second];

            final sum = word.sum;

            if (!binaryTree.contains(sum)) continue;

            outputSink.writeln('$word.$sum');
          }
        }
      } else if (pairsToGenerate == 3) {
        int iterations = 0;

        final List<List<int>> firstWords = possibleWords.where((element) => element.length == runeWords[0].length).toSet().toList();
        final List<List<int>> secondWords = possibleWords.where((element) => element.length == runeWords[1].length).toSet().toList();
        final List<List<int>> thirdWords = possibleWords.where((element) => element.length == runeWords[2].length).toSet().toList();
        for (int first = 0; first < firstWords.length; first++) {
          for (int second = 0; second < secondWords.length; second++) {
            for (int third = 0; third < thirdWords.length; third++) {
              iterations++;

              if (iterations % 100000 == 0) {
                print(iterations);
              }

              if (iterations % 1000000 == 0) {
                await outputSink.flush();
              }

              final word = firstWords[first] + secondWords[second] + thirdWords[third];

              final sum = word.sum;

              if (!binaryTree.contains(sum)) continue;

              outputSink.writeln('$word.$sum');
            }
          }
        }
      } else if (pairsToGenerate == 4) {
        int iterations = 0;

        final List<List<int>> firstWords = possibleWords.where((element) => element.length == runeWords[0].length).toSet().toList();
        final List<List<int>> secondWords = possibleWords.where((element) => element.length == runeWords[1].length).toSet().toList();
        final List<List<int>> thirdWords = possibleWords.where((element) => element.length == runeWords[2].length).toSet().toList();
        final List<List<int>> fourthWords = possibleWords.where((element) => element.length == runeWords[3].length).toSet().toList();
        for (int first = 0; first < firstWords.length; first++) {
          for (int second = 0; second < secondWords.length; second++) {
            for (int third = 0; third < thirdWords.length; third++) {
              for (int fourth = 0; fourth < fourthWords.length; fourth++) {
                iterations++;

                if (iterations % 100000 == 0) {
                  print(iterations);
                }

                if (iterations % 1000000 == 0) {
                  await outputSink.flush();
                }

                final word = firstWords[first] + secondWords[second] + thirdWords[third] + fourthWords[fourth];

                final sum = word.sum;

                if (!binaryTree.contains(sum)) continue;

                outputSink.writeln('$word.$sum');
              }
            }
          }
        }
      }
    } else {
      final possibleSentences = trotter.Combinations(pairsToGenerate, possibleWords);

      print('Total Permutations: ${possibleSentences.length}');
      print('Sample Permutation: ${possibleSentences.iterable.elementAt(0)}');

      int iterations = 0;
      permLoop:
      for (final p in possibleSentences()) {
        iterations++;

        if (iterations % 100000 == 0) {
          print('$iterations');
        }

        if (iterations % 1000000 == 0) {
          await outputSink.flush();
        }

        if (p[0].length != runeWords[0].length) continue;

        if (p.last.length != runeWords.last.length) continue;

        final joined = p.expand((pair) => pair).toList();

        if (joined.length != runeWordsLengthSum) continue;

        if (p.length > 2) {
          for (int i = 1; i < p.length - 1; i++) {
            if (p[i].length != runeWords[i].length) continue permLoop;
          }
        }

        //if (trimFromEnd != null) {
        //  joined.removeRange(joined.length - trimFromEnd, joined.length);
        //}

        final sum = joined.sum;

        if (!binaryTree.contains(sum)) continue;

        //results.add(joined); memory is a fickle thing...

        outputSink.writeln('$joined.$sum');
      }
    }

    print('Finished iterating possibilities');

    await outputSink.flush();
    await outputSink.close();

    print('Sink closed');

    final timeEnded = DateTime.now();

    final timeDifference = timeEnded.difference(timeNow);

    final readableOutputFile = File('${Directory.current.path}/cribs/sentences/${runeWords.join('_')}_readable.txt');
    if (readableOutputFile.existsSync()) {
      readableOutputFile.deleteSync();
      readableOutputFile.createSync();
    } else {
      readableOutputFile.createSync();
    }
    final readableOutputSink = readableOutputFile.openWrite(mode: FileMode.append);

    final outputFileLines = outputFile.readAsLinesSync();
    int iterations = 0;
    for (final element in outputFileLines) {
      iterations++;

      if (iterations % 100000 == 0) {
        await readableOutputSink.flush();
      }

      if (useLoop) {
        final formatted = element.replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '').split('.');
        final word = formatted[0].split(',');
        final sum = formatted[1];

        final letters = List<String>.generate(word.length, (index) => reversedMap[int.parse(word[index])]);
        final words = <String>[];

        int offset = 0;
        for (final word in runeWords) {
          words.add(letters.sublist(offset, offset + word.length).join());

          offset += word.length;
        }

        final bool emirp = is_emirp(int.parse(sum));

        readableOutputSink.writeln('${words.join(' ')} $sum $emirp');
      } else {
        final formatted = element.replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '').split('.');
        final word = formatted[0].split(',');
        final sum = formatted[1];

        final letters = List<String>.generate(word.length, (index) => reversedMap[int.parse(word[index])]);
        final words = <String>[];

        int offset = 0;
        for (final word in runeWords) {
          words.add(letters.sublist(offset, offset + word.length).join());

          offset += word.length;
        }

        final bool emirp = is_emirp(int.parse(sum));

        readableOutputSink.writeln('${words.join(' ')} $sum $emirp');
      }
    }

    print('Finished readable output');

    await readableOutputSink.flush();
    await readableOutputSink.close();

    print('Sink closed');

    print('Finished, time took V');
    print(timeDifference);
    print(timeDifference.inMilliseconds);
  }
}
