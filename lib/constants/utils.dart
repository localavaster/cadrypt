import 'dart:math';

import 'package:flutter/material.dart';

import 'runes.dart';

final rng = Random.secure();

List<int> prime_sieve(int max) {
  final List<bool> primes = List<bool>.filled(max + 1, true);

  for (int p = 2; p * p <= max; p++) {
    // If prime[p] is not changed,
    // then it is a prime
    if (primes[p] == true) {
      // Update all multiples
      // of p greater than or
      // equal to the square of it
      // numbers which are multiple
      // of p and are less than p^2
      // are already been marked.
      for (int i = p * p; i <= max; i += p) {
        primes[i] = false;
      }
    }
  }

  final List<int> sieved = [];

  for (int i = 0; i < primes.length; i++) {
    if (primes[i] == true) {
      sieved.add(i);
    }
  }

  return sieved;
}

bool is_prime(int number) {
  if (number == 1) return false;

  int i = 2;

  while (i * i <= number) {
    if (number % i == 0) {
      return false;
    }

    i++;
  }

  return true;
}

bool is_emirp(int number) {
  if (is_prime(number) == false) return false;

  final reversedNumber = int.parse(number.toString().split('').reversed.toList().join());

  if (number == reversedNumber) return false;

  return is_prime(reversedNumber);
}

bool is_palindromic_prime(int number) {
  if (is_prime(number) == false) return false;

  final reversedNumber = int.parse(number.toString().split('').reversed.toList().join());

  if (number == reversedNumber) return true;

  return false;
}

bool is_cousin_prime(int number) {
  if (is_prime(number) == false) return false;
  if (is_prime(number + 4) == false) return false;

  return true;
}

bool is_special_prime(int number) {
  if ([3301, 1033, 763].contains(number)) return true;

  return false;
}

bool is_chen_prime(int number) {
  final chenNumber = number + 2;

  if (is_prime(chenNumber) || is_semi_prime(number)) return true;

  return false;
}

bool is_semi_prime(int number) {
  int cnt = 0;

  for (int i = 2; cnt < 2 && i * i <= number; ++i) {
    while (number % i == 0) {
      // ignore: parameter_assignments
      number ~/= i;
      cnt++;
    }
  }

  if (number > 1) cnt++;

  return cnt == 2;
}

List<String> get_prime_types(int number) {
  if (is_prime(number) == false) return [];

  final List<String> types = [];

  if (is_emirp(number)) types.add('emirp');
  if (is_palindromic_prime(number)) types.add('palindromic');
  //if (is_cousin_prime(number)) types.add('cousin');
  if (is_special_prime(number)) types.add('cicada');

  return types;
}

Color get_prime_color(int number) {
  if (is_prime(number) == false) return Colors.red;

  final List<String> types = get_prime_types(number);

  final greenShades = [100, 200, 300, 400, 500, 600, 700, 800, 900]..shuffle();
  if (types.isEmpty) return Colors.green[greenShades.first];

  Color col;

  if (types.length == 1) {
    switch (types[0]) {
      case 'emirp':
        {
          col = Colors.purple;
        }
        break;

      case 'palindromic':
        {
          col = Colors.blue;
        }
        break;

      case 'cousin':
        {
          col = Colors.red;
        }
        break;

      case 'cicada':
        {
          col = Colors.pinkAccent;
        }
        break;
    }
  } else {
    // special number, not covering all case
    col = Colors.grey;
  }

  return col;
}

int round_to_whole(int number, int wholeNumber) {
  return number + ((number % wholeNumber) - wholeNumber).abs();
}

Color randomColor() {
  return Color.fromARGB(255, round_to_whole(rng.nextInt(255), 17), round_to_whole(rng.nextInt(255), 17), round_to_whole(rng.nextInt(255), 17));
}

// not p

List<int> get_gp_modulos(int gpValue) {
  final List<int> results = [];

  for (int i = 0; i < 29; i++) {
    final rune = runes[i];
    final runeValue = int.parse(runePrimes[rune]);

    if (runeValue % 29 == gpValue) results.add(runeValue);
  }

  return results;
}
