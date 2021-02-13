import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/widgets/container_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:sortedmap/sortedmap.dart';

import '../analyze_state.dart';

class RepeatedGramsContainer extends StatefulWidget {
  RepeatedGramsContainer({
    Key key,
    @required this.ngramScrollController,
    @required this.state,
  }) : super(key: key);

  final ScrollController ngramScrollController;
  final AnalyzeState state;

  @override
  _RepeatedGramsContainerState createState() => _RepeatedGramsContainerState();
}

class _RepeatedGramsContainerState extends State<RepeatedGramsContainer> {
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
                      final grams = GetIt.instance<Cipher>().get_repeated_grams();

                      SortedMap<String, int> sorted_grams;

                      if (widget.state.repeatedGramsSortedBy == 'count') {
                        sorted_grams = SortedMap.from(grams, const Ordering.byValue());
                      } else if (widget.state.repeatedGramsSortedBy == 'largest') {
                        sorted_grams = SortedMap.from(grams, const Ordering.byKey());
                      }

                      return Scrollbar(
                        thickness: 4,
                        controller: widget.ngramScrollController,
                        isAlwaysShown: true,
                        child: ListView.builder(
                          itemCount: sorted_grams.length,
                          itemBuilder: (context, index) {
                            final gram = sorted_grams.keys.toList().reversed.elementAt(index);
                            final count = sorted_grams[gram];

                            return TextButton(
                              onPressed: () {
                                widget.state.highlight_gram(gram);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text(gram, style: const TextStyle(color: Colors.white)), Text('$count', style: const TextStyle(color: Colors.white))],
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
                  Observer(builder: (_) {
                    return Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            isDense: true,
                            value: widget.state.repeatedGramsSortedBy,
                            items: [
                              const DropdownMenuItem(
                                value: 'count',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sorted by Frequency', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              const DropdownMenuItem(
                                value: 'largest',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('Sorted by Character', style: TextStyle(fontSize: 14)),
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
