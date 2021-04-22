import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../global/cipher.dart';
import '../../../models/gram.dart';
import '../../../widgets/container_header.dart';
import '../analyze_state.dart';

class SimilarGramsContainer extends StatefulWidget {
  const SimilarGramsContainer({
    @required this.state,
  }) : super();

  final AnalyzeState state;

  @override
  _SimilarGramsContainerState createState() => _SimilarGramsContainerState();
}

class _SimilarGramsContainerState extends State<SimilarGramsContainer> {
  final ScrollController similar_ngram_scroll_controller = ScrollController();

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
              name: 'Similar Grams (${GetIt.instance<Cipher>().similar_ngrams.keys.length})',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Material(
                  child: Observer(
                    builder: (context) {
                      final Map<NGram, List<NGram>> grams = GetIt.instance<Cipher>().similar_ngrams;

                      final Map<NGram, List<NGram>> sortedGrams = {};
                      List<NGram> sortedKeys = List<NGram>.from(grams.keys);

                      if (widget.state.similarGramsSortedBy == 'count') {
                        sortedKeys = sortedKeys.sortedBy<num>((element) => grams[element].length);
                      } else if (widget.state.similarGramsSortedBy == 'gramlength') {
                        sortedKeys = sortedKeys.sortedBy<num>((element) => element.length);
                      } else if (widget.state.similarGramsSortedBy == 'largest') {
                        sortedKeys = sortedKeys.sortedBy<String>((element) => element.gram.rune);
                      } else if (widget.state.similarGramsSortedBy == 'indexofoccurence') {
                        sortedKeys = sortedKeys.sortedBy<num>((element) => element.startIndex);
                      }

                      for (final key in sortedKeys) {
                        sortedGrams[key] = grams[key];
                      }

                      return Scrollbar(
                        thickness: 4,
                        controller: similar_ngram_scroll_controller,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          controller: similar_ngram_scroll_controller,
                          padding: EdgeInsets.zero,
                          itemCount: sortedGrams.length,
                          itemBuilder: (context, index) {
                            final gram = sortedGrams.keys.toList().reversed.elementAt(index);
                            final count = sortedGrams[gram].length;

                            final bool specialGram = gram.gram.rune.contains(RegExp('[ᛗᚠ]'));

                            return Observer(builder: (_) {
                              return Material(
                                color: widget.state.selectedSimilarGrams.contains(gram.gram) ? Colors.cyan.withOpacity(0.22) : Theme.of(context).scaffoldBackgroundColor,
                                child: InkWell(
                                  onTap: () {
                                    if (widget.state.selectedSimilarGrams.contains(gram.gram)) {
                                      widget.state.selectedSimilarGrams.remove(gram.gram);
                                    } else {
                                      widget.state.selectedSimilarGrams.add(gram.gram);
                                    }
                                    widget.state.highlight_gram(gram.gram.rune, color: Colors.green);

                                    for (final similar_gram in sortedGrams[gram]) {
                                      widget.state.highlight_gram(similar_gram.gram.text);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${gram.gram.rune} | ${gram.gram.english}', style: TextStyle(color: !specialGram ? Colors.white : Colors.green)),
                                        Text(count.toString(), style: const TextStyle(color: Colors.white)),
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
                            value: widget.state.similarGramsSortedBy,
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
                              DropdownMenuItem(
                                value: 'indexofoccurence',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sort by Index', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                            onChanged: (value) => widget.state.changeSimilarGramSortedBy(value)),
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
