import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/runes.dart';

class SequenceResult {
  final String original_sequence;
  final String modified_sequence;
  final int shift;
  final int oeisIndex;

  SequenceResult(
      {this.original_sequence,
      this.modified_sequence,
      this.shift,
      this.oeisIndex});
}

void toolSequenceFinder(BuildContext context) {
  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          // ignore: strict_raw_type

          final sequenceTextController = TextEditingController();

          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.20;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: sequenceTextController,
                          decoration: const InputDecoration().copyWith(
                              labelText: 'Sequence',
                              hintText:
                                  'Sequence separated by commas (1,2,3,4)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).backgroundColor)),
                            onPressed: () {
                              // results are {sequence, line numbers}
                              final results = <String, List<SequenceResult>>{};
                              final sequence = sequenceTextController.text
                                  .replaceAll(' ', '')
                                  .trim()
                                  .split(',');
                              final numerical = List<int>.generate(
                                  sequence.length,
                                  (index) => int.tryParse(sequence[index]));

                              print(numerical);

                              final oeisDb = File(
                                      '${Directory.current.path}/mod29_oeis_sequences.txt')
                                  .readAsLinesSync();

                              for (int i = 0; i < oeisDb.length; i++) {
                                final oeisSequence = oeisDb[i];

                                for (int shift = 0;
                                    shift < runes.length;
                                    shift++) {
                                  final addSequence =
                                      '${List<int>.generate(numerical.length, (index) => (numerical[index] + shift) % runes.length).join(',')},';

                                  results[addSequence] ??= [];

                                  //final mul_sequence = List<int>.generate(numerical.length, (index) => (numerical[index] * shift) % runes.length).join(',') + ',';

                                  //results[mul_sequence] ??= [];

                                  if (oeisSequence.contains(addSequence)) {
                                    results[addSequence].add(SequenceResult(
                                      original_sequence: sequence.join(','),
                                      modified_sequence: addSequence,
                                      shift: shift,
                                      oeisIndex: i + 1,
                                    ));
                                  }

                                  //if (oeis_sequence.contains(mul_sequence)) results[mul_sequence].add(i);
                                }
                              }

                              results.forEach((key, value) {
                                if (value.isNotEmpty) {
                                  print('==$key');
                                  print('==shift: ${value.first.shift}');
                                  value.forEach((result) {
                                    print(
                                        '- https://oeis.org/A${result.oeisIndex.toString().padLeft(6, '0')}');
                                  });
                                }
                              });
                            },
                            child: const Text('Search'),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      ),
    ),
  );
}
