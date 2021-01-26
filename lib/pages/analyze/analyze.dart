import 'package:cicadrypt/models/console_state.dart';
import 'package:cicadrypt/models/crib_match.dart';
import 'package:cicadrypt/models/crib_settings.dart';
import 'package:cicadrypt/services/crib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

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
  final mainScrollController = ScrollController();
  final frequencyScrollController = ScrollController();
  final ngramScrollController = ScrollController();

  final AnalyzeState state = AnalyzeState();
  final CribSettings cribSettings = CribSettings();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      isAlwaysShown: true,
      thickness: 2,
      controller: mainScrollController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CipherContainer(state: state),
                  const SizedBox(width: 8),
                  SelectionContainer(state: state, cribSettings: cribSettings),
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
                          Text(
                              'Frequencies (${GetIt.instance<Cipher>().flat_cipher_length})'),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Material(
                                child: Builder(
                                  builder: (context) {
                                    final cipher_frequency =
                                        GetIt.instance<Cipher>()
                                            .get_character_frequencies();

                                    final sorted_cipher_frequency =
                                        SortedMap.from(cipher_frequency,
                                            const Ordering.byValue());

                                    return Scrollbar(
                                      thickness: 4,
                                      controller: frequencyScrollController,
                                      isAlwaysShown: true,
                                      child: ListView.builder(
                                        itemCount:
                                            sorted_cipher_frequency.keys.length,
                                        itemBuilder: (context, index) {
                                          final rune = sorted_cipher_frequency
                                              .keys
                                              .toList()
                                              .reversed
                                              .elementAt(index);
                                          final count = sorted_cipher_frequency
                                              .values
                                              .toList()
                                              .reversed
                                              .elementAt(index)
                                              .toString();
                                          final count_percent =
                                              GetIt.instance<Cipher>()
                                                  .get_frequency_percent(
                                                      int.parse(count));

                                          return TextButton(
                                            onPressed: () {
                                              state
                                                  .highlight_all_instances_of_rune(
                                                      rune);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(rune,
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                  Text(
                                                      '${count_percent.toStringAsFixed(1)}% | $count',
                                                      style: const TextStyle(
                                                          color: Colors.white))
                                                ],
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
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
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
                                value: GetIt.I<Cipher>()
                                    .get_index_of_coincidence()
                                    .toStringAsFixed(6),
                              ),
                              ContainerItem(
                                name: 'Entropy',
                                value: GetIt.I<Cipher>()
                                    .get_entropy()
                                    .toStringAsFixed(6),
                              ),
                              ContainerItem(
                                  name: 'n. Bigrams',
                                  value: GetIt.I<Cipher>()
                                      .get_normalized_bigram_repeats()
                                      .toStringAsFixed(6)),
                              ContainerItem(
                                  name: 'Avg. Rune Repeat Dist.',
                                  value: GetIt.I<Cipher>()
                                      .get_average_distance_until_letter_repeat()
                                      .toStringAsFixed(1)),
                              ContainerItem(
                                  name: 'Unused Runes',
                                  value: GetIt.I<Cipher>()
                                      .get_characters_not_used()
                                      .length
                                      .toString()),
                              Expanded(child: SizedBox()),
                              const Text('Dimensions'),
                              ContainerItem(
                                  name: 'Length',
                                  value: GetIt.I<Cipher>()
                                      .flat_cipher_length
                                      .toString()),
                              ContainerItem(
                                  name: 'Width',
                                  value: GetIt.I<Cipher>()
                                      .raw_cipher[0]
                                      .length
                                      .toString()),
                              ContainerItem(
                                  name: 'Height',
                                  value: GetIt.I<Cipher>()
                                      .raw_cipher
                                      .length
                                      .toString()),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                children: [
                                  Observer(
                                    builder: (_) {
                                      return Expanded(
                                        child: Material(
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                                isDense: true,
                                                value: state
                                                    .highlightDropdownValue,
                                                items: [
                                                  const DropdownMenuItem(
                                                    value: 'f',
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      child: Text('F',
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                  const DropdownMenuItem(
                                                    value: 'doubleletters',
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      child: Text(
                                                          'Double Letters',
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                  const DropdownMenuItem(
                                                    value: 'doubleletterrunes',
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      child: Text(
                                                          'Double Letter Runes',
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                  const DropdownMenuItem(
                                                    value: 'smallwords',
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      child: Text('Small Words',
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                  const DropdownMenuItem(
                                                    value: 'knownwords',
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      child: Text(
                                                          'Possible Repeat Words',
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (value) => state
                                                    .changeHighlightDropdownValue(
                                                        value)),
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
                            Expanded(
                                child:
                                    Container()), // empty space to so that elements below are on bottom
                            Material(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        state.highlighedRunes.clear();
                                      },
                                      child: const Text('Clear',
                                          style:
                                              TextStyle(color: Colors.white)),
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
                          Text(
                              'Repeated Grams (${GetIt.instance<Cipher>().repeated_ngrams.keys.length})'),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Material(
                                child: Builder(
                                  builder: (context) {
                                    final grams = GetIt.instance<Cipher>()
                                        .get_repeated_grams();

                                    final sorted_grams = SortedMap.from(
                                        grams, const Ordering.byValue());

                                    return Scrollbar(
                                      thickness: 4,
                                      controller: ngramScrollController,
                                      isAlwaysShown: true,
                                      child: ListView.builder(
                                        itemCount: sorted_grams.length,
                                        itemBuilder: (context, index) {
                                          final gram = sorted_grams.keys
                                              .toList()
                                              .reversed
                                              .elementAt(index);
                                          final count = sorted_grams[gram];

                                          return TextButton(
                                            onPressed: () {
                                              state.highlight_gram(gram);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(gram,
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                  Text('$count',
                                                      style: const TextStyle(
                                                          color: Colors.white))
                                                ],
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
            ConsoleContainer(),
          ],
        ),
      ),
    );
  }
}

class ConsoleContainer extends StatefulWidget {
  const ConsoleContainer({
    Key key,
    this.name,
  }) : super(key: key);

  final String name;

  @override
  _ConsoleContainerState createState() => _ConsoleContainerState();
}

class _ConsoleContainerState extends State<ConsoleContainer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ConsoleState get_console_state() {
    return GetIt.I.get<ConsoleState>(instanceName: 'analyze');
  }

  @override
  void initState() {
    GetIt.I.registerSingleton(ConsoleState(), instanceName: 'analyze');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.66,
              child: Material(
                elevation: 2,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration().copyWith(
                            filled: true,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            labelText: 'Console Output',
                            labelStyle:
                                const TextStyle(height: 1.0, fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                          ),
                          style: TextStyle(fontSize: 12),
                          textAlignVertical: TextAlignVertical.top,
                          cursorWidth: 1,
                          cursorColor: Colors.cyan,
                          maxLines: null,
                          expands: true,
                          controller: get_console_state().controller,
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Material(
                            child: TextButton(
                                onPressed: () {
                                  get_console_state().clear_console();
                                },
                                child: const Text('Clear',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            child: TextButton(
                                onPressed: () {
                                  get_console_state()
                                      .copy_buffer_to_clipboard();
                                },
                                child: const Text('Copy to Clipboard',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CipherContainer extends StatefulWidget {
  const CipherContainer({
    Key key,
    @required this.state,
  }) : super(key: key);

  final AnalyzeState state;

  @override
  _CipherContainerState createState() => _CipherContainerState();
}

class _CipherContainerState extends State<CipherContainer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                                  widget.state.select_cipher_mode('regular');
                                  break;

                                case 1:
                                  widget.state.select_cipher_mode('flat');
                                  break;

                                case 2:
                                  widget.state.select_cipher_mode('true');
                                  break;

                                case 3:
                                  widget.state.select_cipher_mode('3x3');
                                  break;
                                case 4:
                                  widget.state.select_cipher_mode('5x5');
                                  break;
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<int>>[
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
                            const PopupMenuDivider(),
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('3x3'),
                            ),
                            const PopupMenuItem<int>(
                              value: 4,
                              child: Text('5x5'),
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
                      final cipher = widget.state.get_grid_cipher();

                      return GridView.count(
                        crossAxisCount: widget.state.get_grid_x_axis_count(),
                        children: List.generate(
                            cipher.length,
                            (index) => RuneContainer(widget.state, index,
                                cipher.characters.elementAt(index))),
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
                            widget.state.select_reading_mode('rune');
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
                            widget.state.select_reading_mode('english');
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
                            widget.state.select_reading_mode('value');
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
                            widget.state.select_reading_mode('prime');
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
                            widget.state.select_reading_mode('index');
                          },
                          child: const Text(
                            'Index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('color');
                          },
                          child: const Text(
                            'Color',
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
    );
  }
}

class SelectionContainer extends StatefulWidget {
  const SelectionContainer({
    Key key,
    @required this.state,
    @required this.cribSettings,
  }) : super(key: key);

  final AnalyzeState state;
  final CribSettings cribSettings;

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
            const Text('Selection'),

            Observer(builder: (_) {
              if (widget.state.selectedRunes.isEmpty) return Container();

              final mouseSelectedRunes = widget.state.selectedRunes
                  .where((element) => element.type == 'mouse')
                  .toList();

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
                                          widget.state.selectedRunes
                                              .removeWhere((element) =>
                                                  element == selection);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(selection.rune,
                                              style: const TextStyle(
                                                  color: Colors.white)),
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
                        ContainerItem(
                            name: 'Selected',
                            value: mouseSelectedRunes.length.toString()),
                        ContainerItem(
                            name: 'Indexes',
                            value: List<int>.generate(mouseSelectedRunes.length,
                                    (index) => mouseSelectedRunes[index].index)
                                .toString()),
                        ContainerItem(
                          name: 'Total Freq.',
                          value: GetIt.I<Cipher>()
                              .get_total_frequency(
                                List<String>.generate(mouseSelectedRunes.length,
                                    (index) => mouseSelectedRunes[index].rune),
                              )
                              .toString(),
                        ),
                        ContainerItem(
                          name: 'Group Freq.',
                          value: GetIt.I<Cipher>()
                              .get_regex_frequency(
                                List<String>.generate(
                                    mouseSelectedRunes.length,
                                    (index) =>
                                        mouseSelectedRunes[index].rune).join(),
                              )
                              .toString(),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }),
            Expanded(
                child:
                    Container()), // empty space to so that elements below are on bottom

            Observer(builder: (context) {
              if (widget.state.selectedRunes.isEmpty ||
                  widget.state.selectedRunes.length != 2) return Container();

              return Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          widget.state.get_distance_between_selected_runes();
                        },
                        child: const Text('Distance',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            }),

            Observer(builder: (context) {
              if (widget.state.selectedRunes.isEmpty) return Container();

              final List<String> letters = List<String>.generate(
                  widget.state.selectedRunes.length,
                  (index) => widget.state.selectedRunes[index].rune);

              if (letters.contains(' ')) return Container();

              return Material(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final console = GetIt.I
                              .get<ConsoleState>(instanceName: 'analyze');
                          final runeSelection = List<String>.generate(
                                  widget.state.selectedRunes.length,
                                  (index) =>
                                      widget.state.selectedRunes[index].rune)
                              .join();
                          final cribber =
                              Crib(widget.cribSettings, runeSelection);

                          try {
                            console.write_to_console(
                                '=== Cribbing $runeSelection with...');
                            widget.cribSettings.toString().split('\n').forEach(
                                (element) => console.write_to_console(element));

                            final results = await cribber.crib();

                            console.write_to_console(
                                '=== Found ${results.length} possible matches');

                            results.forEach((element) {
                              console.write_to_console(element.get_output());
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text('Crib',
                            style: TextStyle(color: Colors.white)),
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
                                      final width =
                                          MediaQuery.of(context).size.width *
                                              0.70;
                                      final height =
                                          MediaQuery.of(context).size.height *
                                              0.60;
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return Container(
                                          width: width,
                                          height: height,
                                          child: Material(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Material(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8.0),
                                                        child: Text(
                                                            'Crib Settings',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                height: 1.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Builder(
                                                  builder: (_) {
                                                    return Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Material(
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          8.0),
                                                                  child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: const [
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            'Crib File (wordlist)',
                                                                            style:
                                                                                TextStyle(
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
                                                                      child: RadioListTile<
                                                                          CribFileMethod>(
                                                                        value: CribFileMethod
                                                                            .popular,
                                                                        groupValue: widget
                                                                            .cribSettings
                                                                            .cribMethod,
                                                                        onChanged:
                                                                            (CribFileMethod
                                                                                val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.cribMethod =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'Popular Words',
                                                                            style:
                                                                                TextStyle(height: 1.0)),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: RadioListTile<
                                                                          CribFileMethod>(
                                                                        value: CribFileMethod
                                                                            .mortlach,
                                                                        groupValue: widget
                                                                            .cribSettings
                                                                            .cribMethod,
                                                                        onChanged:
                                                                            (CribFileMethod
                                                                                val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.cribMethod =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'Mortlach nGrams (WIP)',
                                                                            style:
                                                                                TextStyle(height: 1.0)),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: RadioListTile<
                                                                          CribFileMethod>(
                                                                        value: CribFileMethod
                                                                            .cicada,
                                                                        groupValue: widget
                                                                            .cribSettings
                                                                            .cribMethod,
                                                                        onChanged:
                                                                            (CribFileMethod
                                                                                val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.cribMethod =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'Cicada',
                                                                            style:
                                                                                TextStyle(height: 1.0)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 64.0),
                                                                        child: Container(
                                                                            height:
                                                                                1,
                                                                            width:
                                                                                double.infinity,
                                                                            color: Theme.of(context).cardColor),
                                                                      ))
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          8.0),
                                                                  child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: const [
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            'Detection',
                                                                            style:
                                                                                TextStyle(
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
                                                                      child:
                                                                          SwitchListTile(
                                                                        value: widget
                                                                            .cribSettings
                                                                            .blacklistCipherLetters,
                                                                        onChanged:
                                                                            (val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.blacklistCipherLetters =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'Blacklist Letters In Cipher',
                                                                            style:
                                                                                TextStyle(height: 1.0)),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          SwitchListTile(
                                                                        value: widget
                                                                            .cribSettings
                                                                            .blacklistDoubleLetters,
                                                                        onChanged:
                                                                            (val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.blacklistDoubleLetters =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'Blacklist Double Letters'),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          SwitchListTile(
                                                                        value: widget
                                                                            .cribSettings
                                                                            .blacklistDoubleLetters,
                                                                        onChanged:
                                                                            (val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.blacklistDoubleLetters =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'Include 1 letter variations'),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 64.0),
                                                                        child: Container(
                                                                            height:
                                                                                1,
                                                                            width:
                                                                                double.infinity,
                                                                            color: Theme.of(context).cardColor),
                                                                      ))
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          8.0),
                                                                  child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: const [
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            'Miscellaneous',
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ]),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          SwitchListTile(
                                                                        value: widget
                                                                            .cribSettings
                                                                            .oeisLookUp,
                                                                        onChanged:
                                                                            (bool
                                                                                val) {
                                                                          setState(
                                                                              () {
                                                                            widget.cribSettings.oeisLookUp =
                                                                                val;
                                                                          });
                                                                        },
                                                                        title: const Text(
                                                                            'OEIS Look Up',
                                                                            style:
                                                                                TextStyle(height: 1.0)),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Text(
                                                              'Close',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
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

            Material(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.state.copy_selected_runes();
                      },
                      child: const Text('Copy',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.state.clear_selected_runes();
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.white)),
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
