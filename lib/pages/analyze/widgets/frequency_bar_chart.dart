import 'package:cicadrypt/constants/libertext.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../../../global/cipher.dart';

class FrequencyBarChart extends StatefulWidget {
  const FrequencyBarChart({Key key}) : super(key: key);

  @override
  _FrequencyBarChartState createState() => _FrequencyBarChartState();
}

class _FrequencyBarChartState extends State<FrequencyBarChart> {
  Map<LiberTextClass, int> frequencies;

  final Color barColor = Colors.cyan[300];
  final Color bottomTitleColor = Colors.white;
  final double barWidth = 5.0;

  List<BarChartGroupData> items = [];

  BarChartGroupData generateChartItem(int x, double y) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(y: y, colors: [barColor], width: barWidth, borderRadius: BorderRadius.zero)
    ]);
  }

  @override
  void initState() {
    frequencies = GetIt.I<Cipher>().get_character_frequencies();

    frequencies.keys.forEachIndexed((index, rune) {
      final count = frequencies[rune];

      items.add(generateChartItem(index, count.toDouble()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Builder(
        builder: (context) {
          // ignore: strict_raw_type

          final width = MediaQuery.of(context).size.width * 0.90;
          final height = MediaQuery.of(context).size.height * 0.60;
          return Container(
            width: width,
            height: height,
            color: Colors.transparent,
            child: Material(
              color: Theme.of(context).cardColor,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Frequency Graph', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          alignment: BarChartAlignment.center,
                          groupsSpace: 12,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                              showTitles: true,
                              margin: 4,
                              getTextStyles: (value) => TextStyle(color: bottomTitleColor, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'SegoeUISymbol'),
                              getTitles: (value) {
                                return frequencies.keys.elementAt(value.toInt()).rune;
                              },
                            ),
                            leftTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                getTextStyles: (value) => const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'SegoeUISymbol'),
                                getTitles: (value) {
                                  return '${value.round()}';
                                }),
                          ),
                          barGroups: items,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
