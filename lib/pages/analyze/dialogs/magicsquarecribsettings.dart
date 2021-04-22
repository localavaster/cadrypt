import 'package:flutter/material.dart';

import '../../../models/magic_square_settings.dart';
import '../analyze_state.dart';

Future<void> dialogMSCribSettings(BuildContext context, AnalyzeState state) async {
  await showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.60;
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
                            child: Text('Magic Square Crib Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.0)),
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
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                        Center(
                                          child: Text(
                                            'Validations',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                    Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Maximum Word Length'),
                                        ),
                                        Expanded(
                                          child: DropdownButtonFormField<int>(
                                            value: state.magicSquareCribSettings.maximumLength,
                                            onChanged: (value) {
                                              setState(() {
                                                state.magicSquareCribSettings.maximumLength = value;
                                              });
                                            },
                                            items: List.generate(
                                              16,
                                              (index) => DropdownMenuItem(
                                                value: index,
                                                child: Text(
                                                  index.toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 64.0),
                                            child: Container(height: 1, width: double.infinity, color: Theme.of(context).cardColor),
                                          ))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                        Center(
                                          child: Text(
                                            'Generation',
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
                                        Wrap(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: FilterChip(
                                              showCheckmark: false,
                                              selectedColor: Colors.cyan.withOpacity(0.20),
                                              selected: state.magicSquareCribSettings.bruteforce,
                                              label: const Text('Bruteforce Words'),
                                              onSelected: (bool value) {
                                                setState(() {
                                                  state.magicSquareCribSettings.bruteforce = value;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: FilterChip(
                                              showCheckmark: false,
                                              selectedColor: Colors.cyan.withOpacity(0.20),
                                              selected: state.magicSquareCribSettings.bruteforce_pad,
                                              label: const Text('Bruteforce Pad'),
                                              onSelected: (bool value) {
                                                setState(() {
                                                  state.magicSquareCribSettings.bruteforce_pad = value;
                                                });
                                              },
                                            ),
                                          )
                                        ]),
                                      ],
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
                                                  selected: state.magicSquareCribSettings.filters.contains(filter.value),
                                                  label: Text(filter.text),
                                                  onSelected: (bool value) {
                                                    setState(() {
                                                      if (value) {
                                                        state.magicSquareCribSettings.filters.add(filter.value);
                                                        print(filter.value);
                                                      } else {
                                                        state.magicSquareCribSettings.filters.removeWhere(
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
                                              child: DropdownButtonFormField<MagicSquareCribOutputSorting>(
                                                  value: state.magicSquareCribSettings.sorting,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: MagicSquareCribOutputSorting.length,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Text('Sorted by Word Length', style: TextStyle(fontSize: 14)),
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: MagicSquareCribOutputSorting.prime,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Text('Sorted by Order Of Prime', style: TextStyle(fontSize: 14)),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (value) => setState(() {
                                                        state.magicSquareCribSettings.sorting = value;
                                                      })),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
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
