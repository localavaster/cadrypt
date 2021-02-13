import 'dart:io';

import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/models/console_state.dart';
import 'package:cicadrypt/models/crib_settings.dart';
import 'package:cicadrypt/models/magic_square_settings.dart';
import 'package:cicadrypt/services/crib.dart';
import 'package:cicadrypt/services/crib_cache.dart';
import 'package:cicadrypt/services/magic_square.dart';
import 'package:cicadrypt/widgets/container_header.dart';
import 'package:cicadrypt/widgets/container_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../analyze_state.dart';

class SelectionContainer extends StatefulWidget {
  const SelectionContainer({
    Key key,
    @required this.state,
  }) : super(key: key);

  final AnalyzeState state;

  @override
  _SelectionContainerState createState() => _SelectionContainerState();
}

class _SelectionContainerState extends State<SelectionContainer> {
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
            const ContainerHeader(
              name: 'Selection',
            ),

            Observer(builder: (_) {
              if (widget.state.selectedRunes.isEmpty) return Container();

              final mouseSelectedRunes = widget.state.selectedRunes.where((element) => element.type == 'mouse').toList();

              if (mouseSelectedRunes.isEmpty) return Container();

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.state.selectedRunes.isNotEmpty) ...[
                        SizedBox(
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: mouseSelectedRunes.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final selection = mouseSelectedRunes[index];

                                  return Material(
                                    child: InkWell(
                                      onTap: () {
                                        widget.state.selectedRunes.removeWhere((element) => element == selection);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text(selection.rune, style: const TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        /*Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Center(
                              child: Material(
                                  child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(state.selectedRunes.keys.join()),
                          ))),
                        ),*/
                        ContainerItem(name: 'Selected', value: mouseSelectedRunes.length.toString()),
                        ContainerItem(name: 'Indexes', value: List<int>.generate(mouseSelectedRunes.length, (index) => mouseSelectedRunes[index].index).toString()),
                        ContainerItem(
                          name: 'Total Freq.',
                          value: GetIt.I<Cipher>()
                              .get_total_frequency(
                                List<String>.generate(mouseSelectedRunes.length, (index) => mouseSelectedRunes[index].rune),
                              )
                              .toString(),
                        ),
                        ContainerItem(
                          name: 'Group Freq.',
                          value: GetIt.I<Cipher>()
                              .get_regex_frequency(
                                List<String>.generate(mouseSelectedRunes.length, (index) => mouseSelectedRunes[index].rune).join(),
                              )
                              .toString(),
                        ),
                        ContainerItem(
                          name: 'IoC',
                          value: GetIt.I<Cipher>().get_index_of_coincidence(text: List<String>.generate(mouseSelectedRunes.length, (index) => mouseSelectedRunes[index].rune).join()).toStringAsFixed(8),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }),
            Expanded(child: Container()), // empty space to so that elements below are on bottom

            Observer(builder: (context) {
              if (widget.state.selectedRunes.isEmpty || widget.state.selectedRunes.length != 2) return Container();

              return Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          widget.state.get_distance_between_selected_runes();
                        },
                        child: const Text('Distance', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            }),

            Observer(builder: (context) {
              if (widget.state.selectedRunes.isEmpty) return Container();

              final List<String> letters = List<String>.generate(widget.state.selectedRunes.length, (index) => widget.state.selectedRunes[index].rune);

              if (letters.contains(' ')) return Container();

              bool containsLetter = false;
              for (final letter in letters) {
                if (!['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(letter)) {
                  containsLetter = true;
                  break;
                }
              }
              if (containsLetter) return Container();

              return Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');
                          final runeSelection = List<String>.generate(widget.state.selectedRunes.length, (index) => widget.state.selectedRunes[index].rune).join();
                          final cribber = MagicSquareCrib(MagicSquareCribSettings(), runeSelection);

                          try {
                            console.write_to_console('=== Finding words with prime sum of $runeSelection');

                            await cribber.start_crib();

                            console.write_to_console('=== Found ${cribber.matches.length} possible matches');

                            console.write_to_console('prime_sum | word | word_primes');
                            cribber.matches.forEach((element) {
                              console.write_to_console(element.toString());
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text('Magic Square Crib', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Container(
                      width: 25,
                      height: 25,
                      child: Material(
                        color: Theme.of(context).cardColor,
                        child: InkWell(
                            onTap: () {
                              showDialog<void>(
                                barrierColor: Colors.black.withOpacity(0.30),
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Builder(
                                    builder: (context) {
                                      final width = MediaQuery.of(context).size.width * 0.70;
                                      final height = MediaQuery.of(context).size.height * 0.60;
                                      return StatefulBuilder(builder: (context, setState) {
                                        return Container(
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
                                                                    Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Text('Maximum Word Length'),
                                                                    ),
                                                                    Expanded(
                                                                      child: DropdownButtonFormField<int>(
                                                                        value: widget.state.magicSquareCribSettings.maximumLength,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            widget.state.magicSquareCribSettings.maximumLength = value;
                                                                          });
                                                                        },
                                                                        items: List.generate(
                                                                          16,
                                                                          (index) => DropdownMenuItem(
                                                                            child: Text(
                                                                              index.toString(),
                                                                            ),
                                                                            value: index,
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
                            },
                            child: const Icon(Icons.settings_sharp, size: 16)),
                      ),
                    )
                  ],
                ),
              );
            }),

            Observer(builder: (context) {
              if (widget.state.selectedRunes.isEmpty) return Container();

              final List<String> letters = List<String>.generate(widget.state.selectedRunes.length, (index) => widget.state.selectedRunes[index].rune);

              if (letters.contains(' ')) return Container();

              bool containsNumber = false;
              for (final letter in letters) {
                if (['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(letter)) {
                  containsNumber = true;
                  break;
                }
              }
              if (containsNumber) return Container();

              return Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final crib_cache = GetIt.I<CribCache>();
                          final console = GetIt.I.get<ConsoleState>(instanceName: 'analyze');
                          final runeSelection = List<String>.generate(widget.state.selectedRunes.length, (index) => widget.state.selectedRunes[index].rune).join();
                          final cribber = Crib(widget.state.cribSettings, runeSelection);

                          try {
                            console.write_to_console('=== Cribbing $runeSelection with filters...');
                            widget.state.cribSettings.filters.forEach((element) {
                              console.write_to_console(element);
                            });

                            console.write_to_console('=== Finding cribs... (this may take awhile depending on settings)');
                            await cribber.start_crib();

                            console.write_to_console('=== Found ${cribber.matches.length} possible matches');

                            console.write_to_console('shift_sum | word | shifts | shifts_in_text');
                            cribber.matches.forEach((element) {
                              crib_cache.add(element);

                              console.write_to_console(element.toString());
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text('Crib', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Container(
                      width: 25,
                      height: 25,
                      child: Material(
                        color: Theme.of(context).cardColor,
                        child: InkWell(
                            onTap: () {
                              showDialog<void>(
                                barrierColor: Colors.black.withOpacity(0.30),
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Builder(
                                    builder: (context) {
                                      final width = MediaQuery.of(context).size.width * 0.70;
                                      final height = MediaQuery.of(context).size.height * 0.80;
                                      return StatefulBuilder(builder: (context, setState) {
                                        return Container(
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
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: DropdownButtonFormField(
                                                                        onChanged: (CribPartOfSpeech value) {
                                                                          setState(() {
                                                                            widget.state.cribSettings.pos = value;
                                                                          });
                                                                        },
                                                                        value: widget.state.cribSettings.pos,
                                                                        isDense: true,
                                                                        items: List<DropdownMenuItem<CribPartOfSpeech>>.generate(
                                                                          CribPartOfSpeech.values.length,
                                                                          (index) => DropdownMenuItem(
                                                                            child: Text(CribPartOfSpeech.values.elementAt(index).toString().allAfter('.')),
                                                                            value: CribPartOfSpeech.values[index],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                                            selected: widget.state.cribSettings.wordFilters.contains(filter.value),
                                                                            label: Text(filter.text),
                                                                            onSelected: (bool value) {
                                                                              setState(() {
                                                                                if (value) {
                                                                                  widget.state.cribSettings.wordFilters.add(filter.value);
                                                                                } else {
                                                                                  widget.state.cribSettings.wordFilters.removeWhere(
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
                                                                              selected: widget.state.cribSettings.filters.contains(filter.value),
                                                                              label: Text(filter.text),
                                                                              onSelected: (bool value) {
                                                                                setState(() {
                                                                                  if (value) {
                                                                                    widget.state.cribSettings.filters.add(filter.value);
                                                                                  } else {
                                                                                    widget.state.cribSettings.filters.removeWhere(
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
                                                                              selected: widget.state.cribSettings.interruptors.contains(filter.value),
                                                                              label: Text(filter.text),
                                                                              onSelected: (bool value) {
                                                                                setState(() {
                                                                                  if (value) {
                                                                                    widget.state.cribSettings.interruptors.add(filter.value);
                                                                                  } else {
                                                                                    widget.state.cribSettings.interruptors.removeWhere(
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
                            },
                            child: const Icon(Icons.settings_sharp, size: 16)),
                      ),
                    )
                  ],
                ),
              );
            }),

            Observer(builder: (context) {
              if (widget.state.selectedRunes.isEmpty) return Container();

              return Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          widget.state.get_selected_runes_information();
                        },
                        child: const Text('Information', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            }),

            Material(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.state.copy_selected_runes();
                      },
                      child: const Text('Copy', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.state.clear_selected_runes();
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
    );
  }
}
