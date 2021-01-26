import 'package:cicadrypt/constants/runes.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class CribMatch {
  final String word;
  final List<int> shifts;
  final int shift_sum;

  bool shiftSequenceInOEIS;

  CribMatch(this.word, this.shifts, {this.shiftSequenceInOEIS = null})
      : shift_sum = shifts.sum() {}

  List<int> shift_difference() {
    if (shifts.length == 1) {
      return [shift_sum];
    }

    final List<int> differences = [];
    for (int i = 0; i < shifts.length; i++) {
      try {
        final int a = shifts[i];
        final int b = shifts[i + 1];

        differences.add((a - b).abs());
      } catch (e) {
        continue;
      }
    }

    return differences;
  }

  String get_output() {
    final StringBuffer charBuffer = StringBuffer();
    shifts.forEach((element) {
      charBuffer.write(rune_english[element].toUpperCase());
    });

    final buffer = StringBuffer();

    buffer.writeAll([
      '$shift_sum',
      ' | ',
      word,
      ' | ',
      '$shifts',
      ' | ',
      (charBuffer.toString()),
      ' | ',
      (charBuffer.toString().reverse),
      ' | ',
      shift_difference().toString(),
      if (shiftSequenceInOEIS != null) ...[
        ' | ',
        shiftSequenceInOEIS,
      ]
    ]);

    return buffer.toString();
  }

  @override
  String toString() {
    return '$shift_sum | $word | $shifts';
  }
}
