import 'package:cicadrypt/constants/libertext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../../../global/cipher.dart';
import '../../../widgets/container_header.dart';
import '../analyze_state.dart';

class RepeatedGramsContainer extends StatefulWidget {
  const RepeatedGramsContainer({
    @required this.state,
  }) : super();

  final AnalyzeState state;

  @override
  _RepeatedGramsContainerState createState() => _RepeatedGramsContainerState();
}

class _RepeatedGramsContainerState extends State<RepeatedGramsContainer> {
  final ScrollController ngramScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.33,
        width: MediaQuery.of(context).size.width * 0.20,
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ContainerHeader(
              name: 'Repeated Grams (${GetIt.instance<Cipher>().repeated_ngrams.keys.length})',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Material(
                  child: Observer(
                    builder: (context) {
                      final grams = GetIt.instance<Cipher>().repeated_ngrams;

                      var sorted_grams = <LiberTextClass, int>{};

                      if (widget.state.repeatedGramsSortedBy == 'count') {
                        final sorted_entries = grams.entries.sortedBy<num>((element) => element.value);

                        sorted_grams = Map.fromEntries(sorted_entries);
                      } else if (widget.state.repeatedGramsSortedBy == 'largest') {
                        final sorted_entries = grams.entries.sortedBy<String>((element) => element.key.rune);

                        sorted_grams = Map.fromEntries(sorted_entries);
                      } else if (widget.state.repeatedGramsSortedBy == 'gramlength') {
                        final gram_keys = List<LiberTextClass>.from(grams.keys).sortedBy<num>((element) => element.rune.length);

                        for (final key in gram_keys) {
                          sorted_grams[key] = grams[key];
                        }
                      }

                      return Scrollbar(
                        thickness: 4,
                        controller: ngramScrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: sorted_grams.length,
                          itemBuilder: (context, index) {
                            final gram = sorted_grams.keys.toList().reversed.elementAt(index);
                            final count = sorted_grams[gram];

                            final bool specialGram = gram.rune.contains('ᚠ');

                            return Observer(builder: (_) {
                              return Material(
                                color: widget.state.selectedRepeatedGrams.contains(gram) ? Colors.cyan.withOpacity(0.22) : Theme.of(context).scaffoldBackgroundColor,
                                child: InkWell(
                                  onTap: () {
                                    if (widget.state.selectedRepeatedGrams.contains(gram)) {
                                      widget.state.selectedRepeatedGrams.remove(gram);
                                    } else {
                                      widget.state.selectedRepeatedGrams.add(gram);
                                    }
                                    widget.state.highlight_gram(gram.rune);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${gram.rune} | ${gram.english}', style: TextStyle(color: !specialGram ? Colors.white : Colors.green)),
                                        Text('$count', style: const TextStyle(color: Colors.white)),
                                      ],
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
                  Observer(builder: (_) {
                    return Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            isDense: true,
                            value: widget.state.repeatedGramsSortedBy,
                            items: const [
                              DropdownMenuItem(
                                value: 'count',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sorted by Frequency', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'largest',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sorted by Character', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'gramlength',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sorted by Gram Length', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                            onChanged: (value) => widget.state.changeGramSortedBy(value)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
