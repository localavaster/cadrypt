import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:collection/collection.dart';

import '../../../constants/runes.dart';
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
                      final cipher_frequency = GetIt.instance<Cipher>().frequencies;

                      final sorted_entries = cipher_frequency.entries.sortedBy<num>((element) => element.value);

                      final sorted_cipher_frequency = Map.fromEntries(sorted_entries);

                      return Scrollbar(
                        thickness: 4,
                        controller: frequencyScrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: sorted_cipher_frequency.keys.length,
                          itemBuilder: (context, index) {
                            final text = sorted_cipher_frequency.keys.toList().reversed.elementAt(index);

                            final count = sorted_cipher_frequency.values.toList().reversed.elementAt(index).toString();
                            final count_percent = GetIt.instance<Cipher>().get_frequency_percent(int.parse(count));

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
                                      children: [Text('${text.rune} | ${text.english}', style: const TextStyle(color: Colors.white)), Text('${count_percent.toStringAsFixed(1)}% | $count', style: const TextStyle(color: Colors.white))],
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
