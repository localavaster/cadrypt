import 'dart:io';

// A class containing functions relating to https://www.oeis.org
class OEISParser {
  OEISParser() {
    sequenceFile = File('${Directory.current.path}/raw_oeis_sequences');
    if (!sequenceFile.existsSync()) {
      assert(true, 'No sequence file exists');
    }

    modifiedSequenceFile = File('${Directory.current.path}/mod29_oeis_sequences.txt');
    if (!modifiedSequenceFile.existsSync()) {
      modifiedSequenceFile.createSync();
    }
  }

  static const currentAmountOfSequences = 340699;

  File sequenceFile;
  File modifiedSequenceFile;

  void write_invalid_sequence(int index) {
    modifiedSequenceFile.writeAsStringSync('$index 0,0,0\n', mode: FileMode.append);
  }

  void write_sequence_to_file(int index, List<int> sequence) {
    modifiedSequenceFile.writeAsStringSync('$index ${sequence.join(',')}\n', mode: FileMode.append);
  }

  Future<void> parse_sequences() async {
    final timeStarted = DateTime.now();
    final sequences = sequenceFile.readAsLinesSync();

    int i = 1;
    for (final sequence in sequences) {
      final split = sequence.split(' ,');

      //final sequence_identifier = split.first;
      final sequenceList = split.last.split(',')..removeLast();

      try {
        write_sequence_to_file(i, List<int>.generate(sequenceList.length, (index) => int.parse(sequenceList[index]) % 29));
      } on FormatException catch (e) {
        write_invalid_sequence(i);
      }

      i++;
    }
    final timeEnded = DateTime.now();

    print('Finished parsing sequences, time took in MS: ${timeEnded.millisecondsSinceEpoch - timeStarted.millisecondsSinceEpoch}');
  }
}
