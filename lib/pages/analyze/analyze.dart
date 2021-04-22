import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import './widgets/cipher_grid_container.dart';
import './widgets/console_container.dart';
import './widgets/frequency_container.dart';
import './widgets/highlight_container.dart';
import './widgets/repeated_ngram_container.dart';
import './widgets/selection_container.dart';
import './widgets/statistics_container.dart';

import 'analyze_state.dart';
import 'widgets/similar_ngram_container.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({Key key}) : super(key: key);

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final mainScrollController = ScrollController();

  final AnalyzeState state = GetIt.I<AnalyzeState>();

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
        controller: mainScrollController,
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
                  FrequencyContainer(state: state),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  // ignore: prefer_const_constructors
                  StatisticsContainer(),
                  const SizedBox(
                    width: 8,
                  ),
                  HighlightContainer(state: state),
                  const SizedBox(
                    width: 8,
                  ),
                  SimilarGramsContainer(state: state),
                  const SizedBox(
                    width: 8,
                  ),
                  RepeatedGramsContainer(state: state),
                ],
              ),
            ),
            const ConsoleContainer(),
          ],
        ),
      ),
    );
  }
}
