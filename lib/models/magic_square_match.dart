import '../constants/runes.dart';

class MagicSquareMatch {
  MagicSquareMatch(this.word, this.sum, this.values);

  final String word;
  final int sum;
  final List<int> values;

  @override
  String toString() {
    final runeBuffer = StringBuffer();
    final primeRuneMap = {for (var e in runePrimes.keys) int.parse(runePrimes[e]): e};

    for (final prime in values) {
      runeBuffer.write(primeRuneMap[prime]);
    }

    return '$sum | ${word.toLowerCase()} | ${runeBuffer.toString()} | $values';
  }
}
