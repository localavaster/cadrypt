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

  void write_invalid_sequence() {
    modifiedSequenceFile.writeAsStringSync('0,0,0,\n', mode: FileMode.append);
  }

  void write_sequence_to_file(List<int> sequence) {
    modifiedSequenceFile.writeAsStringSync('${sequence.join(',')}\n', mode: FileMode.append);
  }

  Future<void> parse_sequences() async {
    final timeStarted = DateTime.now();
    final sequences = sequenceFile.readAsLinesSync();
    for (final sequence in sequences) {
      final split = sequence.split(' ,');

      //final sequence_identifier = split.first;
      final sequence_list = split.last.split(',')..removeLast();

      try {
        write_sequence_to_file(List<int>.generate(sequence_list.length, (index) => int.parse(sequence_list[index]) % 29));
      } on FormatException catch (e) {
        write_invalid_sequence();
      }
    }
    final timeEnded = DateTime.now();

    print('Finished parsing sequences, time took in MS: ${timeEnded.millisecondsSinceEpoch - timeStarted.millisecondsSinceEpoch}');
  }
}
