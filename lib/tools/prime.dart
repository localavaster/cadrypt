import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../constants/runes.dart';
import '../constants/utils.dart';
import '../global/cipher.dart';

void toolPrimeAnalysis(BuildContext context) {
  // ngram size, count
  final results = <int, int>{};
  for (int i = 2; i < 32; i++) {
    final grams = GetIt.I<Cipher>().get_ngrams(i);

    results[i] ??= 0;
    for (final gram in grams) {
      final gramSplit = gram.gram.rune.split('');

      final sum = List<int>.generate(gramSplit.length, (index) => int.parse(runePrimes[gramSplit[index]])).sum;

      if (is_prime(sum)) {
        results[i]++;
      }
    }
  }

  results.forEach((key, value) {
    print('$key | $value');
  });
}
