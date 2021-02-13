import 'package:flutter/material.dart';

import '../../models/crib_settings.dart';
import './widgets/cipher_grid_container.dart';
import './widgets/console_container.dart';
import './widgets/frequency_container.dart';
import './widgets/highlight_container.dart';
import './widgets/repeated_ngram_container.dart';
import './widgets/selection_container.dart';
import './widgets/statistics_container.dart';

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
                  SelectionContainer(state: state),
                  const SizedBox(width: 8),
                  FrequencyContainer(frequencyScrollController: frequencyScrollController, state: state),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  StatisticsContainer(),
                  const SizedBox(
                    width: 8,
                  ),
                  HighlightContainer(state: state),
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
                  RepeatedGramsContainer(ngramScrollController: ngramScrollController, state: state),
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
