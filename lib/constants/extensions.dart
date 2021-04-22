import 'package:collection/collection.dart';

import 'utils.dart';

extension CryptoUtils on int {
  List<int> factors({bool skipOne = false}) {
    final List<int> factors = [];

    final int start = !skipOne ? 1 : 2;

    for (int i = start; i <= this; i++) {
      if (this % i == 0) factors.add(i);
    }

    return factors;
  }

  int fermat_inverse_modulo(int modulo) {
    final gcd = this.gcd(modulo);
    if (gcd != -1) {
      return -1;
    }

    return modPow(modulo - 2, modulo);
  }
}

const listIntEquals = ListEquality<int>();

extension CryptoListExtensions on List<int> {
  List<int> intersecting(List<int> other) {
    return List<int>.generate(length, (index) {
      if (this[index] == other[index]) {
        return this[index];
      } else {
        return -1;
      }
    });
  }

  bool is_incremental() {
    final sortedByNumber = sortedBy<num>((element) => element);

    return listIntEquals.equals(this, sortedByNumber) == true;
  }

  bool is_decremental() {
    final sortedByNumber = sortedBy<num>((element) => element).reversed.toList();

    return listIntEquals.equals(this, sortedByNumber) == true;
  }

  bool is_odd() {
    return where((element) => element.isOdd).length == length;
  }

  bool is_even() {
    return where((element) => element.isEven).length == length;
  }

  // Only one number present in list
  bool is_all_different() {
    return toSet().toList().length == length;
  }

  bool has_repeats() {
    return toSet().toList().length != length;
  }

  bool all_primes() {
    return where(is_prime).length == length;
  }

  List<int> differences() {
    return List<int>.generate(length - 1, (index) {
      try {
        return (this[index] - this[index + 1]).abs();
      } catch (e) {
        return first;
      }
    });
  }

  List<String> get_sequence_facts() {
    final facts = <String>[];

    if (is_incremental()) facts.add('incremental');
    if (is_decremental()) facts.add('decremental');
    if (is_odd()) facts.add('is_odd');
    if (is_even()) facts.add('is_even');
    if (is_all_different()) facts.add('ad');
    if (has_repeats()) facts.add('hr');
    if (all_primes()) facts.add('all_primes');

    // difference facts
    final diffs = differences();

    if (diffs.is_incremental()) facts.add('diffs_incremental');
    if (diffs.is_decremental()) facts.add('diffs_decremental');
    if (diffs.is_odd()) facts.add('diffs_is_odd');
    if (diffs.is_even()) facts.add('diffs_is_even');
    if (diffs.is_all_different()) facts.add('dad');
    if (diffs.has_repeats()) facts.add('dhr');
    if (diffs.all_primes()) facts.add('diffs_all_prime');

    return facts;
  }
}
