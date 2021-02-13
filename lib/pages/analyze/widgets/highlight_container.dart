import 'package:cicadrypt/widgets/container_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../analyze_state.dart';

class HighlightContainer extends StatelessWidget {
  const HighlightContainer({
    Key key,
    @required this.state,
  }) : super(key: key);

  final AnalyzeState state;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.33,
        child: Material(
          elevation: 2,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              const ContainerHeader(
                name: 'Highlight',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Observer(
                      builder: (_) {
                        return Expanded(
                          child: Material(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  isDense: true,
                                  value: state.highlightDropdownValue,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'f',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('F', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'doubleletters',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Double Letters', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'doubleletterrunes',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Double Letter Runes', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'smallwords',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Small Words', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'repeatwords',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Repeated words', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'allvowels',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Vowels (AEIOU, AE, IO)', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'vowels',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Vowels (AEIOU)', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: '-',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('------', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'rows',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Rows', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'columns',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Columns', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'checkerboard',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('Checkers', style: TextStyle(fontSize: 14)),
                                      ),
                                    )
                                  ],
                                  onChanged: (value) => state.changeHighlightDropdownValue(value)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Material(
                        child: InkWell(
                          onTap: state.onHighlightDonePressed,
                          child: const Icon(
                            Icons.done,
                            size: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(child: Container()), // empty space to so that elements below are on bottom
              Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          state.highlighedRunes.clear();
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
