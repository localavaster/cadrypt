import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/pages/analyze/widgets/frequency_bar_chart.dart';
import 'package:cicadrypt/widgets/container_header.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sortedmap/sortedmap.dart';

import '../analyze_state.dart';

class FrequencyContainer extends StatelessWidget {
  const FrequencyContainer({
    Key key,
    @required this.frequencyScrollController,
    @required this.state,
  }) : super(key: key);

  final ScrollController frequencyScrollController;
  final AnalyzeState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.50,
        width: MediaQuery.of(context).size.width * 0.20,
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ContainerHeader(
              name: 'Frequencies (${GetIt.instance<Cipher>().flat_cipher_length})',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Material(
                  child: Builder(
                    builder: (context) {
                      final cipher_frequency = GetIt.instance<Cipher>().get_character_frequencies();

                      final sorted_cipher_frequency = SortedMap.from(cipher_frequency, const Ordering.byValue());

                      return Scrollbar(
                        thickness: 4,
                        controller: frequencyScrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          itemCount: sorted_cipher_frequency.keys.length,
                          itemBuilder: (context, index) {
                            final rune = sorted_cipher_frequency.keys.toList().reversed.elementAt(index);
                            String runeInEnglish = '';
                            try {
                              runeInEnglish = runeToEnglish[rune];
                            } catch (e) {
                              runeInEnglish = '';
                            }
                            final count = sorted_cipher_frequency.values.toList().reversed.elementAt(index).toString();
                            final count_percent = GetIt.instance<Cipher>().get_frequency_percent(int.parse(count));

                            return TextButton(
                              onPressed: () {
                                state.highlight_all_instances_of_rune(rune);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text('$rune | ${runeInEnglish}', style: const TextStyle(color: Colors.white)), Text('${count_percent.toStringAsFixed(1)}% | $count', style: const TextStyle(color: Colors.white))],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Material(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        showDialog(context: context, builder: (context) => FrequencyBarChart());
                      },
                      child: const Text(
                        'View Graph',
                        style: TextStyle(color: Colors.white),
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
  }
}
