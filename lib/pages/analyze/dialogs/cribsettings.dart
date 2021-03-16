import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../../../models/crib_settings.dart';
import '../analyze_state.dart';

Future<void> dialogCribSettings(BuildContext context, AnalyzeState state) {
  return showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Builder(
        builder: (context) {
          final startsWithController = TextEditingController(text: state.cribSettings.startsWith);
          final endsWithController = TextEditingController(text: state.cribSettings.endsWith);
          final patternController = TextEditingController(text: state.cribSettings.pattern);

          startsWithController.addListener(() {
            state.cribSettings.startsWith = startsWithController.text;
          });

          endsWithController.addListener(() {
            state.cribSettings.endsWith = endsWithController.text;
          });

          patternController.addListener(() {
            state.cribSettings.pattern = patternController.text;
          });

          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.80;
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              width: width,
              height: height,
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Theme.of(context).cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Crib Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.0)),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (_) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Material(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                        Center(
                                          child: Text(
                                            'Part of Speech',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField(
                                              onChanged: (CribPartOfSpeech value) {
                                                setState(() {
                                                  state.cribSettings.pos = value;
                                                });
                                              },
                                              value: state.cribSettings.pos,
                                              isDense: true,
                                              items: List<DropdownMenuItem<CribPartOfSpeech>>.generate(
                                                CribPartOfSpeech.values.length,
                                                (index) => DropdownMenuItem(
                                                  value: CribPartOfSpeech.values[index],
                                                  child: Text(CribPartOfSpeech.values.elementAt(index).toString().allAfter('.')),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Wrap(
                                        children: List<Widget>.generate(
                                          cribWordFilters.length,
                                          (index) {
                                            final filter = cribWordFilters[index];
                                            return Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: FilterChip(
                                                showCheckmark: false,
                                                selectedColor: Colors.cyan.withOpacity(0.20),
                                                selected: state.cribSettings.wordFilters.contains(filter.value),
                                                label: Text(filter.text),
                                                onSelected: (bool value) {
                                                  setState(() {
                                                    if (value) {
                                                      state.cribSettings.wordFilters.add(filter.value);
                                                    } else {
                                                      state.cribSettings.wordFilters.removeWhere(
                                                        (String value) {
                                                          return value == filter.value;
                                                        },
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                            child: Container(height: 2, width: double.infinity, color: Theme.of(context).cardColor),
                                          ))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                        Center(
                                          child: Text(
                                            'Filters',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                    Column(
                                      children: [
                                        Wrap(
                                          children: List<Widget>.generate(
                                            cribFilters.length,
                                            (index) {
                                              final filter = cribFilters[index];
                                              return Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: FilterChip(
                                                  showCheckmark: false,
                                                  selectedColor: Colors.cyan.withOpacity(0.20),
                                                  selected: state.cribSettings.filters.contains(filter.value),
                                                  label: Text(filter.text),
                                                  onSelected: (bool value) {
                                                    setState(() {
                                                      if (value) {
                                                        state.cribSettings.filters.add(filter.value);
                                                      } else {
                                                        state.cribSettings.filters.removeWhere(
                                                          (String value) {
                                                            return value == filter.value;
                                                          },
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: startsWithController,
                                            decoration: const InputDecoration().copyWith(labelText: 'Starts With', hintText: 'English Only', isDense: true),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: patternController,
                                            decoration: const InputDecoration().copyWith(labelText: 'RegExp Pattern', hintText: '..ot..', isDense: true),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: endsWithController,
                                            decoration: const InputDecoration().copyWith(labelText: 'Ends With', hintText: 'English Only', isDense: true),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                            child: Container(height: 2, width: double.infinity, color: Theme.of(context).cardColor),
                                          ))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                        Center(
                                          child: Text(
                                            'Output',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32),
                                      child: Material(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                  isDense: true,
                                                  value: state.cribSettings.outputSortedBy,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'shiftsum',
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Text('Sorted by Shift Sum', style: TextStyle(fontSize: 14)),
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'shiftdifferencessum',
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Text('Sorted by Shift Differences Sum', style: TextStyle(fontSize: 14)),
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'matchinghomophones',
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Text('Sorted by Matching Homophones', style: TextStyle(fontSize: 14)),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (value) => setState(() {
                                                        state.cribSettings.outputSortedBy = value;
                                                      })),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Wrap(
                                          children: List<Widget>.generate(
                                            cribOutputSelection.length,
                                            (index) {
                                              final filter = cribOutputSelection[index];
                                              return Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: FilterChip(
                                                  showCheckmark: false,
                                                  selectedColor: Colors.cyan.withOpacity(0.20),
                                                  selected: state.cribSettings.outputFillers.contains(filter.value),
                                                  label: Text(filter.text),
                                                  onSelected: (bool value) {
                                                    setState(() {
                                                      if (value) {
                                                        state.cribSettings.outputFillers.add(filter.value);
                                                      } else {
                                                        state.cribSettings.outputFillers.removeWhere(
                                                          (String value) {
                                                            return value == filter.value;
                                                          },
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                            child: Container(height: 2, width: double.infinity, color: Theme.of(context).cardColor),
                                          ))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                        Center(
                                          child: Text(
                                            'Interruptors',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                    Column(
                                      children: [
                                        Wrap(
                                          children: List<Widget>.generate(
                                            cribInterruptorFilters.length,
                                            (index) {
                                              final filter = cribInterruptorFilters[index];
                                              return Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: FilterChip(
                                                  showCheckmark: false,
                                                  selectedColor: Colors.cyan.withOpacity(0.20),
                                                  selected: state.cribSettings.interruptors.contains(filter.value),
                                                  label: Text(filter.text),
                                                  onSelected: (bool value) {
                                                    setState(() {
                                                      if (value) {
                                                        state.cribSettings.interruptors.add(filter.value);
                                                      } else {
                                                        state.cribSettings.interruptors.removeWhere(
                                                          (String value) {
                                                            return value == filter.value;
                                                          },
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Theme.of(context).cardColor,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        },
      ),
    ),
  );
}
