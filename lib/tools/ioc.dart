import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/libertext.dart';
import '../constants/runes.dart';
import '../global/cipher.dart';
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

void toolIocAnalysis(BuildContext context) {
  List<AnalysisResult> results = [];
  final gridCipher = GetIt.I<AnalyzeState>().get_grid_cipher();

  for (int size = 3; size < 50; size++) {
    for (int i = 0; i < gridCipher.length; i = i + size) {
      final subString = gridCipher.substring(i, (i + size).clamp(0, gridCipher.length).toInt());

      final ioc = GetIt.I<Cipher>().get_index_of_coincidence(text: subString);

      results.add(AnalysisResult(start_index: i, text: LiberText(subString), ioc: ioc));
    }
  }

  results = results.sortedBy<num>((element) => element.ioc).reversed.toList();

  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          int currentSelectedSortBy = 0;
          final width = MediaQuery.of(context).size.width * 0.60;
          final height = MediaQuery.of(context).size.height * 0.80;
          return DefaultTabController(
            length: 3,
            child: SizedBox(
              width: width,
              height: height,
              child: Column(
                children: [
                  const TabBar(tabs: [
                    Tab(
                      child: Text('All'),
                    ),
                    Tab(child: Text('Compacted All')),
                    Tab(
                      child: Text('Average'),
                    ),
                  ]),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // All
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: results.length,
                                    itemBuilder: (context, index) {
                                      final result = results[index];
                                      final string = result.text;
                                      final ioc = result.ioc.toStringAsFixed(4);

                                      return GestureDetector(
                                        onTap: () {
                                          for (int i = 0; i < string.rune.length; i++) {
                                            final character = string.rune.characters.elementAt(i);
                                            GetIt.I<AnalyzeState>().highlight_rune(character, (result.start_index + i), 'highlighter', ignoreDuplicates: true);
                                          }
                                        },
                                        child: Container(
                                          color: index.isOdd ? Colors.black.withOpacity(0.22) : Colors.black.withOpacity(0.37),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(string.rune.replaceAll(RegExp('[^ ${runes.join('')}]'), ''), style: const TextStyle(height: 1.0)),
                                                ),
                                                Expanded(child: Container()),
                                                Text(result.start_index.toString(), style: const TextStyle(height: 1.0)),
                                                const SizedBox(width: 4),
                                                Text(result.length.toString(), style: const TextStyle(height: 1.0)),
                                                const SizedBox(width: 4),
                                                Text(ioc, style: const TextStyle(height: 1.0))
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: double.infinity,
                                  child: Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: currentSelectedSortBy,
                                      items: const [
                                        DropdownMenuItem<int>(value: 0, child: Text('Sort By IoC')),
                                        DropdownMenuItem<int>(value: 1, child: Text('Sort By Nearest English IoC')),
                                        DropdownMenuItem<int>(value: 2, child: Text('Sort By Length')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          currentSelectedSortBy = value;

                                          if (value == 0) {
                                            results = results.sortedBy<num>((element) => element.ioc).reversed.toList();
                                          } else if (value == 1) {
                                            results = results.sortedBy<num>((element) => (0.060 - element.ioc).abs());
                                          } else if (value == 2) {
                                            results = results.sortedBy<num>((element) => element.length);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Compacted All
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Builder(builder: (_) {
                                    final iocs = <int, List<String>>{};

                                    for (int i = 3; i < 50; i++) {
                                      final resultsFiltered = results.where((element) => element.length == i).toList();
                                      final iocValues = List<double>.generate(resultsFiltered.length, (index) => resultsFiltered[index].ioc);

                                      for (final value in iocValues) {
                                        iocs[i] ??= [];

                                        if (!iocs[i].contains(value.toStringAsFixed(3))) {
                                          iocs[i].add(value.toStringAsFixed(3));
                                        }
                                      }
                                    }

                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: iocs.length,
                                      itemBuilder: (context, index) {
                                        final key = iocs.keys.elementAt(index);

                                        final iocValues = iocs[key];

                                        final asDoubles = List<double>.generate(iocValues.length, (index) => double.tryParse(iocValues[index]));

                                        final distances = List<double>.generate(asDoubles.length - 1, (index) => (asDoubles[index] - asDoubles[index + 1]).abs());

                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            color: index.isOdd ? Colors.black.withOpacity(0.22) : Colors.black.withOpacity(0.37),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Text('${key.toString()} | ${distances.average.toStringAsFixed(3)}', style: const TextStyle(height: 1.0)),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: List<Widget>.generate(
                                                      iocValues.length,
                                                      (index) {
                                                        final iocValue = iocValues[index];
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                          child: Text('($iocValue)'),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
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
                        // Averages
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Builder(builder: (_) {
                                    final averages = <int, double>{};
                                    final minmaxes = <int, List<double>>{};

                                    for (int i = 3; i < 50; i++) {
                                      final resultsFiltered = results.where((element) => element.length == i).toList();
                                      final iocValues = List<double>.generate(resultsFiltered.length, (index) => resultsFiltered[index].ioc);

                                      averages[i] = iocValues.average;
                                      minmaxes[i] = [iocValues.min(), iocValues.max()];
                                    }

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
                                                const SizedBox(width: 4),
                                                Text('| Distance: ${mmDistance.toStringAsFixed(5)} [${mm.first.toStringAsFixed(3)}, ${mm.last.toStringAsFixed(3)}]', style: const TextStyle(height: 1.0)),
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
