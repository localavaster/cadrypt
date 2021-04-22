import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../widgets/container_header.dart';
import '../analyze_state.dart';

class HighlightContainer extends StatelessWidget {
  HighlightContainer({
    @required this.state,
  }) : super();

  final AnalyzeState state;

  final highlightWordTextController = TextEditingController();
  final highlightEveryNController = TextEditingController();
  final highlightSimplePatternController = TextEditingController();
  final highlightWordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4125,
        child: Material(
          elevation: 2,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              const ContainerHeader(
                name: 'Highlight',
              ),
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                children: [
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
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'f',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('F', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'i',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('I', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'repeatedpatterns',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Repeated Patterns', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'doubleletters',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Double Letters', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'neardoubleletters',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Near Double Letters', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'near2doubleletters',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Near (2) Dbl Letters', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'doubleletterrunes',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Double Letter Runes', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'singleletterrunes',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Single Letter Runes', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'smallwords',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Small Words', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'repeatwords',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Repeated words', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'allvowels',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Vowels (AEIOU, AE, IO)', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'vowels',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Vowels (AEIOU)', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'englishtrigrams',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('English Trigrams', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'rows',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Rows', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'columns',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Columns', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'checkerboard',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Checkers', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'samegpwords',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Same GP Sum Words', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                      ],
                                      onChanged: state.changeHighlightDropdownValue),
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
                                      value: state.primeHighlightDropdownValue,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'primepairs',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Pairs', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primetriads',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Triads', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primequartet',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Quartet', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primefives',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Fives', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'specialprimerun',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Special Prime Run', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primewordrun',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Word Run', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primesentencerun',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Sentence Run', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primestoprun',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Stop Run', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'primerun',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Prime Run', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'reverseprimerun',
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text('Reverse Prime Run', style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                      ],
                                      onChanged: state.changePrimeHighlightDropdownValue),
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
                              onTap: state.onPrimeHighlightDonePressed,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 24,
                            child: TextField(
                              decoration: const InputDecoration().copyWith(
                                labelStyle: const TextStyle(fontSize: 12),
                                labelText: 'Highlight Regex',
                                isDense: true,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                              ),
                              cursorHeight: 12,
                              controller: highlightWordTextController,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

                                state.onHighlightRegexDonePressed(highlightWordTextController.text);
                              },
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 24,
                            child: TextField(
                              decoration: const InputDecoration().copyWith(
                                labelStyle: const TextStyle(fontSize: 12),
                                labelText: 'Highlight every nTh character',
                                isDense: true,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                              ),
                              cursorHeight: 12,
                              controller: highlightEveryNController,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

                                state.onHighlightEveryNthCharacterDonePressed(highlightEveryNController.text);
                              },
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 24,
                            child: TextField(
                              decoration: const InputDecoration().copyWith(
                                labelStyle: const TextStyle(fontSize: 12),
                                labelText: 'Highlight Simple Pattern',
                                hintText: 'X XoXooX (highlights X)',
                                isDense: true,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.transparent)),
                              ),
                              cursorHeight: 12,
                              controller: highlightSimplePatternController,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

                                state.onHighlightSimplePatternDonePressed(highlightSimplePatternController.text);
                              },
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
                ],
              )),
              SizedBox(height: 4),
              //Expanded(child: Container()), // empty space to so that elements below are on bottom
              Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          state.select_non_highlighted_runes();
                        },
                        child: const Text('Select Non-Highlighted', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          state.select_highlighted_runes();
                        },
                        child: const Text('Select Highlighted', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
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
