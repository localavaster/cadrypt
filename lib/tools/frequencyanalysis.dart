import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/libertext.dart';
import '../constants/runes.dart';
import '../pages/analyze/analyze_state.dart';

class AnalysisResult {
  AnalysisResult({this.start_index, this.ioc, this.text}) : length = text.rune.length {
    end_index = start_index + length;
  }

  final int start_index;
  int end_index;

  final int length;
  final double ioc;
  final LiberTextClass text;
}

void toolFrequencyAnalysis(BuildContext context) {
  List<AnalysisResult> results = [];
  final gridCipher = GetIt.I<AnalyzeState>().get_grid_cipher();

  final characterIndexes = <String, List<int>>{};

  for (int i = 0; i < gridCipher.length; i++) {
    final character = gridCipher.characters.elementAt(i);

    if (runes.contains(character) || character == ' ') {
      characterIndexes[character] ??= [];

      characterIndexes[character].add(i);
    }
  }

  print(characterIndexes);

  results = results.sortedBy<num>((element) => element.ioc).reversed.toList();

  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          final width = MediaQuery.of(context).size.width * 0.60;
          final height = MediaQuery.of(context).size.height * 0.80;
          return DefaultTabController(
            length: 1,
            child: SizedBox(
              width: width,
              height: height,
              child: Column(
                children: [
                  TabBar(tabs: [Tab(child: Text('Average'))]),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Builder(builder: (_) {
                                    final averages = <String, double>{};
                                    final minmaxes = <String, List<int>>{};
                                    print('a');
                                    characterIndexes.forEach((key, value) {
                                      if (value.length == 1) {
                                        averages[key] = value.first.toDouble();
                                        return;
                                      }
                                      final distances = List<int>.generate(value.length - 1, (index) => value[index + 1] - value[index]);

                                      averages[key] = distances.average;

                                      try {
                                        minmaxes[key] = [distances.min(), distances.max()];
                                      } catch (e) {
                                        minmaxes[key] = [0, 0];
                                      }
                                    });
                                    print('b');
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: averages.length,
                                      itemBuilder: (context, index) {
                                        final key = averages.keys.elementAt(index);

                                        final average = averages[key];
                                        final mm = minmaxes[key];
                                        final mmDistance = (mm.last - mm.first);

                                        return Container(
                                          color: index.isOdd ? Colors.black.withOpacity(0.22) : Colors.black.withOpacity(0.37),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(key.toString(), style: const TextStyle(height: 1.0)),
                                                ),
                                                Expanded(child: Container()),
                                                Text('Average: ${average.toStringAsFixed(3)}', style: const TextStyle(height: 1.0)),
                                                SizedBox(width: 2),
                                                Text('MinMax: $mm'),
                                                SizedBox(width: 2),
                                                Text('MinMax D: $mmDistance'),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
