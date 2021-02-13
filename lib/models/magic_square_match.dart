import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../constants/runes.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class MagicSquareMatch {
  final String word;
  final int sum;
  final List<int> values;

  MagicSquareMatch(this.word, this.sum, this.values);

  @override
  String toString() {
    final runeBuffer = StringBuffer();
    final primeRuneMap = Map.fromIterable(runePrimes.keys, key: (k) => int.parse(runePrimes[k]), value: (v) => (v));

    for (final prime in values) {
      runeBuffer.write(primeRuneMap[prime]);
    }

    return '$sum | ${word.toLowerCase()} | ${runeBuffer.toString()} | $values';
  }
}
