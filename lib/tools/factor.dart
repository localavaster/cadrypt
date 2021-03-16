import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../constants/extensions.dart';
import '../global/cipher.dart';

void toolFactorAnalysis(BuildContext context) {
  final factors = GetIt.I<Cipher>().get_common_factors_of_repeats();

  final sortedKeys = factors.keys.toList().sortedBy<num>((element) => element);

  sortedKeys.forEach((element) {
    print('F: $element | C: ${factors[element]}');
  });

  final allFactors = factors.keys.toList();

  final oddFactors = allFactors.where((element) => element.isOdd);
  final evenFactors = allFactors.where((element) => element.isEven);

  print('Even Factors: ${evenFactors.length}');
  print('Odd Factors: ${oddFactors.length}');

  final Map<int, List<int>> common_factors = {};

  allFactors.forEach((element) {
    final count = factors[element];

    if (count < 3) return;

    final factorsExceptSelf = allFactors.where((f) => f != element);

    final elementFactors = element.factors();

    common_factors[element] ??= [];

    elementFactors.forEach((eFactor) {
      if (factorsExceptSelf.contains(eFactor)) {
        common_factors[element].add(eFactor);
      }
    });
  });

  print('Chained Factors');

  common_factors.forEach((key, value) {
    if (value.isNotEmpty) {
      print('$key - $value');
    }
  });
}
