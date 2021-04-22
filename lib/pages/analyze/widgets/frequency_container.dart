import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:collection/collection.dart';

import '../../../global/cipher.dart';
import '../../../widgets/container_header.dart';
import '../analyze_state.dart';
import 'frequency_bar_chart.dart';

class FrequencyContainer extends StatelessWidget {
  FrequencyContainer({
    @required this.state,
  }) : super();

  final ScrollController frequencyScrollController = ScrollController();
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
                      final cipherFrequency = GetIt.instance<Cipher>().frequencies;

                      final sortedEntries = cipherFrequency.entries.sortedBy<num>((element) => element.value);

                      final sortedCipherFrequency = Map.fromEntries(sortedEntries);

                      return Scrollbar(
                        thickness: 4,
                        controller: frequencyScrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          controller: frequencyScrollController,
                          padding: EdgeInsets.zero,
                          itemCount: sortedCipherFrequency.keys.length,
                          itemBuilder: (context, index) {
                            final text = sortedCipherFrequency.keys.toList().reversed.elementAt(index);

                            final count = sortedCipherFrequency.values.toList().reversed.elementAt(index).toString();
                            final countPercent = GetIt.instance<Cipher>().get_frequency_percent(int.parse(count));

                            return Observer(builder: (_) {
                              return Material(
                                color: state.selectedFrequencies.contains(text) ? Colors.cyan.withOpacity(0.22) : Theme.of(context).scaffoldBackgroundColor,
                                child: InkWell(
                                  onTap: () {
                                    if (state.selectedFrequencies.contains(text)) {
                                      state.selectedFrequencies.remove(text);
                                    } else {
                                      state.selectedFrequencies.add(text);
                                    }

                                    state.highlight_all_instances_of_rune(text.rune);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text('${text.rune} | ${text.english}', style: const TextStyle(color: Colors.white)), Text('${countPercent.toStringAsFixed(1)}% | $count', style: const TextStyle(color: Colors.white))],
                                    ),
                                  ),
                                ),
                              );
                            });
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
                        showDialog(context: context, builder: (context) => const FrequencyBarChart());
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
