import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/libertext.dart';
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
        height: MediaQuery.of(context).size.height * 0.4125,
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

                      var sortedGrams = <LiberTextClass, int>{};

                      if (widget.state.repeatedGramsSortedBy == 'count') {
                        final sortedEntries = grams.entries.sortedBy<num>((element) => element.value);

                        sortedGrams = Map.fromEntries(sortedEntries);
                      } else if (widget.state.repeatedGramsSortedBy == 'largest') {
                        final sortedEntries = grams.entries.sortedBy<String>((element) => element.key.rune);

                        sortedGrams = Map.fromEntries(sortedEntries);
                      } else if (widget.state.repeatedGramsSortedBy == 'gramlength') {
                        final gramKeys = List<LiberTextClass>.from(grams.keys).sortedBy<num>((element) => element.rune.length);

                        for (final key in gramKeys) {
                          sortedGrams[key] = grams[key];
                        }
                      }

                      return Scrollbar(
                        thickness: 4,
                        controller: ngramScrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          controller: ngramScrollController,
                          padding: EdgeInsets.zero,
                          itemCount: sortedGrams.length,
                          itemBuilder: (context, index) {
                            final gram = sortedGrams.keys.toList().reversed.elementAt(index);
                            final count = sortedGrams[gram];

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
                                    widget.state.highlight_gram(gram.text);
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
                                  child: Text('Sort by Frequency', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'largest',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sort by Character', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'gramlength',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sort by Gram Length', style: TextStyle(fontSize: 12)),
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
