import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

class Sequence {
  Sequence({this.sequence});

  final List<int> sequence;

  int sum() {
    return sequence.sum;
  }

  Sequence get unique_numbers => Sequence(sequence: sequence.toSet().toList());

  Sequence differences() {
    final List<int> differences = [];

    for (int i = 0; i < sequence.length; i++) {
      try {
        final int current = sequence[i];
        final int next = sequence[i + 1];

        differences.add(next - current);
      } catch (e) {
        // end of list
      }
    }

    return Sequence(sequence: differences);
  }
}
