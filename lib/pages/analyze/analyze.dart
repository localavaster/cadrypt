import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:sortedmap/sortedmap.dart';

import '../../global/cipher.dart';
import '../../widgets/container_item.dart';
import '../../widgets/rune_container.dart';
import 'analyze_state.dart';

class AnalyzePage extends StatefulWidget {
  AnalyzePage({Key key}) : super(key: key);

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final frequencyScrollController = ScrollController();
  final ngramScrollController = ScrollController();

  AnalyzeState state;
  @override
  void initState() {
    state = AnalyzeState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.50,
                        color: Theme.of(context).cardColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Cipher'),
                                  Center(
                                    child: PopupMenuButton<int>(
                                      onSelected: (int result) {
                                        setState(() {
                                          switch (result) {
                                            case 0:
                                              state.select_cipher_mode('regular');
                                              break;

                                            case 1:
                                              state.select_cipher_mode('flat');
                                              break;

                                            case 2:
                                              state.select_cipher_mode('true');
                                              break;
                                          }
                                        });
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                                        const PopupMenuItem<int>(
                                          value: 0,
                                          child: Text('Regular'),
                                        ),
                                        const PopupMenuItem<int>(
                                          value: 1,
                                          child: Text('Flat'),
                                        ),
                                        const PopupMenuItem<int>(
                                          value: 2,
                                          child: Text('True'),
                                        ),
                                      ],
                                      child: const Icon(
                                        Icons.visibility,
                                        size: 16,
                                        semanticLabel: 'Cipher settings',
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Observer(builder: (_) {
                                  final cipher = state.get_grid_cipher();

                                  return GridView.count(
                                    crossAxisCount: state.get_grid_x_axis_count(),
                                    children: List.generate(cipher.length, (index) => RuneContainer(state, index, cipher.characters.elementAt(index))),
                                  );
                                }),
                              ),
                            ),
                            Material(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        state.select_reading_mode('rune');
                                      },
                                      child: const Text(
                                        'Runes',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        state.select_reading_mode('english');
                                      },
                                      child: const Text(
                                        'English',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        state.select_reading_mode('value');
                                      },
                                      child: const Text(
                                        'Value',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        state.select_reading_mode('prime');
                                      },
                                      child: const Text(
                                        'Prime',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        state.select_reading_mode('index');
                                      },
                                      child: const Text(
                                        'Index',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  elevation: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    width: MediaQuery.of(context).size.width * 0.20,
                    color: Theme.of(context).cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Selection'),

                        Observer(builder: (_) {
                          if (state.selectedRunes.isEmpty) return Container();

                          final mouseSelectedRunes = state.selectedRunes.where((element) => element.type == 'mouse').toList();

                          if (mouseSelectedRunes.isEmpty) return Container();

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (state.selectedRunes.isNotEmpty) ...[
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
                                                      state.selectedRunes.removeWhere((element) => element == selection);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      child: Text(selection.rune, style: const TextStyle(color: Colors.white)),
                                                    ),
                                                  ),
                                                );
                                              }),
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
                                  ]
                                ],
                              ),
                            ),
                          );
                        }),
                        Expanded(child: Container()), // empty space to so that elements below are on bottom
                        Observer(builder: (context) {
                          if (state.selectedRunes.isEmpty || state.selectedRunes.length != 2) return Container();

                          return Material(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      state.get_distance_between_selected_runes();
                                    },
                                    child: const Text('Distance', style: TextStyle(color: Colors.white)),
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
                                    state.copy_selected_runes();
                                  },
                                  child: const Text('Copy', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    state.clear_selected_runes();
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
                const SizedBox(width: 8),
                Material(
                  elevation: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    width: MediaQuery.of(context).size.width * 0.20,
                    color: Theme.of(context).cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Frequencies (${GetIt.instance<Cipher>().flat_cipher_length})'),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Material(
                              child: Builder(
                                builder: (context) {
                                  final cipher_frequency = GetIt.instance<Cipher>().get_character_frequencies();

                                  final sorted_cipher_frequency = SortedMap.from(cipher_frequency, const Ordering.byValue());

                                  return Scrollbar(
                                    thickness: 4,
                                    controller: frequencyScrollController,
                                    isAlwaysShown: true,
                                    child: ListView.builder(
                                      itemCount: sorted_cipher_frequency.keys.length,
                                      itemBuilder: (context, index) {
                                        final rune = sorted_cipher_frequency.keys.toList().reversed.elementAt(index);
                                        final count = sorted_cipher_frequency.values.toList().reversed.elementAt(index).toString();
                                        final count_percent = GetIt.instance<Cipher>().get_frequency_percent(int.parse(count));

                                        return TextButton(
                                          onPressed: () {
                                            state.highlight_all_instances_of_rune(rune);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [Text(rune, style: const TextStyle(color: Colors.white)), Text('${count_percent.toStringAsFixed(1)}% | $count', style: const TextStyle(color: Colors.white))],
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
                              Expanded(
                                child: TextButton(
                                  onPressed: () {},
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.33,
                    child: Material(
                      elevation: 2,
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          children: [
                            const Text('Statistics'),
                            ContainerItem(
                              name: 'IoC',
                              value: GetIt.I<Cipher>().get_index_of_coincidence().toStringAsFixed(6),
                            ),
                            ContainerItem(
                              name: 'Entropy',
                              value: GetIt.I<Cipher>().get_entropy().toStringAsFixed(6),
                            ),
                            ContainerItem(
                              name: 'Unigrams',
                              value: GetIt.I<Cipher>().flat_cipher_length.toString(),
                            ),
                            ContainerItem(name: 'Unused Runes', value: GetIt.I<Cipher>().get_characters_not_used().join(',')),
                            const Text('Dimensions'),
                            ContainerItem(name: 'Length', value: GetIt.I<Cipher>().flat_cipher_length.toString()),
                            ContainerItem(name: 'Width', value: GetIt.I<Cipher>().raw_cipher[0].length.toString()),
                            ContainerItem(name: 'Height', value: GetIt.I<Cipher>().raw_cipher.length.toString()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.33,
                    child: Material(
                      elevation: 2,
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          const Text('Highlight'),
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
                                                  value: 'smallwords',
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                    child: Text('Small Words', style: TextStyle(fontSize: 14)),
                                                  ),
                                                ),
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
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.33,
                    child: Material(
                      elevation: 2,
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: const [
                          Text('Misc'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Material(
                  elevation: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.33,
                    width: MediaQuery.of(context).size.width * 0.20,
                    color: Theme.of(context).cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Repeated Grams (${GetIt.instance<Cipher>().repeated_ngrams.keys.length})'),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Material(
                              child: Builder(
                                builder: (context) {
                                  final grams = GetIt.instance<Cipher>().get_repeated_grams();

                                  final sorted_grams = SortedMap.from(grams, const Ordering.byValue());

                                  return Scrollbar(
                                    thickness: 4,
                                    controller: ngramScrollController,
                                    isAlwaysShown: true,
                                    child: ListView.builder(
                                      itemCount: sorted_grams.length,
                                      itemBuilder: (context, index) {
                                        final gram = sorted_grams.keys.toList().reversed.elementAt(index);
                                        final count = sorted_grams[gram];

                                        return TextButton(
                                          onPressed: () {
                                            print(gram);
                                            state.highlight_gram(gram);
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
