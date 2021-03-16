import 'package:cicadrypt/global/settings.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../constants/runes.dart';
import '../constants/utils.dart';
import '../constants/extensions.dart';

class CribMatch extends Equatable {
  CribMatch(this.original_word, this.cribbed_word, this.cribbed_word_split, this.shifts, this.matching_homophones)
      : shift_sum = shifts.sum,
        shift_word = List<String>.generate(shifts.length, (index) => GetIt.I<Settings>().get_alphabet(english: true)[shifts[index]].toUpperCase()).join(),
        shift_rune_word = List<String>.generate(shifts.length, (index) => runes[shifts[index]]).join() {
    final buffer = StringBuffer();

    for (final shift in shifts) {
      final letters = <String>[];

      for (int idx = 0; idx < gpPrimesMod29.length; idx++) {
        final value = gpPrimesMod29[idx];

        if (value == shift) {
          letters.add(runeEnglish[idx]);
        }
      }

      if (letters.isEmpty) {
        buffer.write('?${runeEnglish[shift]}?');
      } else if (letters.length == 1) {
        buffer.write(letters.first);
      } else if (letters.length != 1) {
        buffer.write('(${letters.join()})');
      }
    }

    shift_word_using_gp = buffer.toString().toUpperCase();

    crib_in_prime_form = List<int>.generate(cribbed_word_split.length, (index) {
      final element = cribbed_word_split[index];
      int idx = runeEnglish.indexOf(element);
      if (idx == -1) idx = altRuneEnglish.indexOf(element);

      if (idx == -1) {
        return -1;
      }

      return letterToPrime.values.elementAt(idx);
    });
  }

  final String original_word;
  final String cribbed_word;
  final List<String> cribbed_word_split;
  int matching_homophones;

  List<int> crib_in_prime_form;
  final List<int> shifts;
  final String shift_word;
  String shift_word_using_gp;
  final String shift_rune_word;
  final int shift_sum;

  int max_shift_sum() {
    return runes.length * shifts.length;
  }

  bool get is_far_shift => shift_sum >= (max_shift_sum() ~/ 2);

  bool get is_close_shift => shift_sum <= (max_shift_sum() ~/ 2);

  bool get odd_shifts => shifts.where((element) => element.isOdd).length == shifts.length;

  bool get even_shifts => shifts.where((element) => element.isEven).length == shifts.length;

  int calculate_amount_of_alphabets() {
    if (shifts.toSet().toList().length == 1) {
      return 1;
    }

    int alphabets = 0;

    for (final letter in shifts.toSet().toList()) {
      alphabets++;
    }

    return alphabets;
  }

  Map<String, List<int>> homophones() {
    final Map<String, List<int>> homophones = {};

    final splitEnglishWord = gematriaRegex.allMatches(cribbed_word.toLowerCase()).map((e) => e.group(0)).toList(); // slow

    splitEnglishWord.forEachIndexed((index, element) {
      final letter = element;
      final shift = shifts[index];

      homophones[letter] ??= [];

      homophones[letter].add(shift);
    });

    return homophones;
  }

  List<List<String>> get_shift_word_gp_possibilities() {
    final result = <List<String>>[];

    final reversed_map = {for (var e in runePrimes.entries) int.parse(e.value): e.key};

    for (final shift in shifts) {
      final gp_possibilities = get_gp_modulos(shift);

      final shift_p = <String>[];
      for (final p in gp_possibilities) {
        shift_p.add(runeToEnglish[reversed_map[p]]);
      }

      result.add(shift_p);
    }

    return result;
  }

  List<int> shift_differences() {
    final List<int> differences = [];

    if (shifts.length == 1) return shifts;

    for (int i = 0; i < shifts.length - 1; i++) {
      final current = shifts[i];
      final next = shifts[i + 1];

      differences.add((next - current).abs());
    }

    return differences;
  }

  int shift_difference_sum() {
    return shift_differences().sum;
  }

  String shiftToRuneForm() {
    return List<String>.generate(shifts.length, (index) => runes[shifts[index]]).join();
  }

  String runeWordToEnglishForm() {
    final split_rune_word = original_word.split('');

    return List<String>.generate(split_rune_word.length, (index) => runeToEnglish[split_rune_word[index]]).join();
  }

  String toConsoleString(List<String> outputSettings) {
    final buffer = StringBuffer();
    outputSettings.forEach((element) {
      switch (element) {
        case 'shiftsum':
          buffer.write('$shift_sum | ');
          break;

        case 'shiftdifferencessum':
          buffer.write('${shift_difference_sum()} | ');
          break;

        case 'cribword':
          buffer.write('$cribbed_word | ');
          break;

        case 'shiftlist':
          buffer.write('$shifts | ');
          break;

        case 'shiftdifferences':
          buffer.write('${shift_differences()} | ');
          break;

        case 'shiftsinwordform':
          buffer.write('$shift_word | ');
          break;

        case 'shiftsingpform':
          buffer.write('$shift_word_using_gp | ');
          break;

        case 'matchinghomophones':
          buffer.write('$matching_homophones | ');
          break;

        case 'shiftlistfacts':
          buffer.write('${shifts.get_sequence_facts()} | ');
          break;
      }
    });

    final result = buffer.toString();

    return result.trim().substring(0, result.length - 2); // - 2 to remove | (why)
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    //buffer.write('$crib | ${shiftToRuneForm()}');
    buffer.writeAll(['$shift_sum', ' | ', cribbed_word, ' | ', '$shifts', ' | ', (runeWordToEnglishForm()), ' | ', shift_word, ' | ', shift_word_using_gp, ' | ', '${get_shift_word_gp_possibilities()},']);

    return buffer.toString();
  }

  // equality props
  @override
  List<Object> get props => [original_word, shifts, shift_word];
}
