import 'package:cicadrypt/global/settings.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../constants/runes.dart';
import '../constants/utils.dart';
import '../models/crib_match.dart';
import '../models/crib_settings.dart';
import 'crib_cache.dart';
import 'oeis_search.dart';

class Crib {
  Crib(this.settings, this.runeWord) : splitRuneWord = runeWord.split('') {
    if (GetIt.I<Settings>().is_cicada_mode()) {
      try {
        splitRuneWordEnglish = List<String>.generate(runeWord.split('').length, (index) => runeToEnglish[runeWord.split('')[index]].toLowerCase());
      } catch (e) {
        print('crib.dart:19 -> $e');
      }
    } else {
      try {
        splitRuneWordEnglish = splitRuneWord;
      } catch (e) {
        print('crib.dart:19 -> $e');
      }
    }
  }

  final CribSettings settings;

  final String runeWord;

  List<String> splitRuneWordEnglish;
  final List<String> splitRuneWord;

  List<CribMatch> matches = [];

  List<int> shifts_to_get_word(List<String> splitEnglishWord) {
    final List<int> shifts = [];

    splitRuneWord.forEachIndexed((index, rune) {
      if (splitRuneWord.length == 1 && splitEnglishWord.length != 1) return;

      if (splitRuneWord.length == splitEnglishWord.length) {
        final runeIndex = GetIt.I<Settings>().get_alphabet().indexOf(rune);

        int englishIndex = GetIt.I<Settings>().get_alphabet().indexOf(splitEnglishWord.elementAt(index));

        if (GetIt.I<Settings>().is_cicada_mode()) {
          englishIndex = runeEnglish.indexOf(splitEnglishWord.elementAt(index));

          if (englishIndex == -1) {
            englishIndex = altRuneEnglish.indexOf(splitEnglishWord.elementAt(index));
          }
        }

        if (englishIndex == -1) {
          print('Word List Error: cannot find ${splitEnglishWord[index]} in ${splitEnglishWord.join()}');
        }

        final difference = (runeIndex - englishIndex) % GetIt.I<Settings>().get_alphabet().length;

        shifts.add(difference);
      }
    });

    return shifts;
    // shifts
  }

  Future<List<CribMatch>> wordCrib({List<String> onlyIncludeWords}) async {
    final program_settings = GetIt.I<Settings>();

    final runeWordLength = runeWord.length;
    final possibleWords = settings.get_crib_words(minimumLength: runeWordLength, maximumLengthOffset: 3, onlyIncludeWords: onlyIncludeWords);

    OEISLookUp oeis;
    if (settings.filters.contains('shiftisinoeis')) {
      oeis = OEISLookUp(localLookUp: true);
    }

    Map<String, List<String>> homophones = {};
    if (settings.wordFilters.contains('usecribcachehomophones')) {
      homophones = GetIt.I<CribCache>().calculate_homophones();
    }

    wordLoop:
    for (final word in possibleWords) {
      List<String> splitEnglishWord = [];

      if (program_settings.is_cicada_mode()) {
        splitEnglishWord = gematriaRegex.allMatches(word.toLowerCase()).map((e) => e.group(0)).toList(); // slow
      } else {
        splitEnglishWord = word.toLowerCase().split('');
      }

      if (splitEnglishWord.length != splitRuneWord.length) continue;

      if (settings.wordFilters.contains('onlymagicsquaresums')) {
        final primeListOfWord = <int>[];
        for (final splitLetter in splitEnglishWord) {
          int prime = letterToPrime[splitLetter.toUpperCase()];
          prime ??= altLetterToPrime[splitLetter.toUpperCase()];

          if (prime == null) continue wordLoop;

          primeListOfWord.add(prime);
        }

        final int sum = primeListOfWord.sum;

        if (!square_sums.contains(sum)) continue wordLoop;
      }

      int matching_homophones = 0;
      if (settings.wordFilters.contains('usecribcachehomophones')) {
        for (int i = 0; i < runeWord.length; i++) {
          final original_rune_letter = runeWord.split('')[i];
          final hps = homophones[original_rune_letter];
          if (hps.isEmpty) continue;

          final crib_english_letter = splitEnglishWord[i];

          if (hps.contains(crib_english_letter)) matching_homophones++;
        }

        if (matching_homophones == 0) continue wordLoop;
      }

      if (settings.filters.contains('noplaintext')) {
        int same_letters = 0;
        splitEnglishWord.forEachIndexed((index, wordLetter) {
          final runeLetter = splitRuneWordEnglish[index].toLowerCase();

          if (wordLetter.toLowerCase() == runeLetter) same_letters++;
        });

        if (same_letters != 0) continue wordLoop;
      }

      if (settings.filters.contains('nodoubleletters')) {
        for (final letter in splitEnglishWord) {
          if (letter.length == 2) continue wordLoop;
        }
      }

      final List<int> shifts = shifts_to_get_word(splitEnglishWord);

      if (settings.filters.contains('onlyincshifts')) {
        for (int i = 0; i < (shifts.length - 1); i++) {
          final current = shifts[i];
          final next = shifts[i + 1];

          if (next < current) continue wordLoop;
        }
      }

      if (settings.filters.contains('onlydecshifts')) {
        for (int i = 0; i < (shifts.length - 1); i++) {
          final current = shifts[i];
          final next = shifts[i + 1];

          if (current < next) continue wordLoop;
        }
      }

      if (settings.filters.contains('onlyunique')) {
        if (shifts.toSet().length != shifts.length) continue wordLoop;
      }

      if (settings.filters.contains('onlysimilar')) {
        if (shifts.toSet().length == shifts.length) continue wordLoop;
      }

      if (settings.filters.contains('hasplaintext')) {
        int same_letters = 0;
        splitEnglishWord.forEachIndexed((index, wordLetter) {
          final runeLetter = splitRuneWordEnglish[index].toLowerCase();

          if (wordLetter.toLowerCase() == runeLetter) same_letters++;
        });

        if (same_letters != 1) continue wordLoop;
      }

      if (settings.filters.contains('nouncommonshifts')) {
        for (final letter in splitEnglishWord) {
          if (['x', 'z'].contains(letter.toLowerCase())) continue wordLoop;
        }
      }

      if (settings.filters.contains('onlyprimeshifts')) {
        int minimumPrimeShifts = shifts.length;
        if (minimumPrimeShifts > 6) minimumPrimeShifts = minimumPrimeShifts - 1;

        int primeShifts = 0;
        for (final shift in shifts) {
          if (primes.contains(shift)) primeShifts++;
        }

        if (primeShifts < minimumPrimeShifts) continue wordLoop;
      }

      if (settings.filters.contains('onlygpshifts')) {
        int primeShifts = 0;
        for (final shift in shifts) {
          if (gpPrimesMod29.contains(shift)) primeShifts++;
        }

        if (primeShifts < shifts.length - 1) continue wordLoop;
      }

      if (settings.filters.contains('shiftisinoeis')) {
        final bool sequenceInOEIS = oeis.localOeisContainsSequnece(shifts);

        if (sequenceInOEIS == false) continue wordLoop;
      } // mfw time complexity

      if (settings.interruptors.isNotEmpty) {
        final interruptors = List<String>.generate(settings.interruptors.length, (index) => runeToEnglish[settings.interruptors[index]].toLowerCase());

        if (!shifts.contains(0)) continue wordLoop;

        final indexes_of_zero = <int>[];

        for (int i = 0; i < shifts.length; i++) {
          final shift = shifts[i];

          if (shift == 0) indexes_of_zero.add(i);
        }

        final plaintext_letters = List<String>.generate(indexes_of_zero.length, (index) => splitEnglishWord[indexes_of_zero[index]]);

        for (final plaintext in plaintext_letters) {
          if (!interruptors.contains(plaintext)) continue wordLoop;
        }
      }

      matches.add(CribMatch(runeWord, word, splitEnglishWord, shifts, matching_homophones));
    }

    if (settings.filters.contains('nozeroshiftdifferences')) {
      matches.removeWhere((match) => match.shift_differences().contains(0));
    }

    if (settings.filters.contains('onlyevenshifts')) {
      matches.removeWhere((match) => match.even_shifts == false);
    }

    if (settings.filters.contains('onlyoddshifts')) {
      matches.removeWhere((match) => match.odd_shifts == false);
    }

    if (settings.filters.contains('onlyprimewordsums')) {
      matches.removeWhere((match) => !is_prime(match.crib_in_prime_form.sum));
    }

    if (settings.filters.contains('onlyprimeshiftsums')) {
      matches.removeWhere((match) => !is_prime(match.shifts.sum));
    }

    if (settings.filters.contains('onlypuregpshifts')) {
      // ignore: unnecessary_raw_strings
      matches.removeWhere((match) => match.shift_word_using_gp.contains(RegExp(r'[?(]')));
    }

    if (settings.filters.contains('onlyimpuregpshifts')) {
      matches.removeWhere((match) => match.shift_word_using_gp.contains(RegExp('[?(]')) == false);
    }

    if (settings.filters.contains('onlyfarshifts')) {
      matches.removeWhere((match) => match.is_close_shift);
    }

    if (settings.filters.contains('onlycloseshifts')) {
      matches.removeWhere((match) => match.is_far_shift);
    }

    //eoeislookup?.client?.close(force: true);

    if (matches.length == 1) {
      GetIt.instance<CribCache>().add(matches.first);
    }

    if (settings.outputSortedBy == 'shiftsum') {
      return matches.sortedBy<num>((element) => element.shift_sum);
    } else if (settings.outputSortedBy == 'shiftdifferencessum') {
      return matches.sortedBy<num>((element) => element.shift_difference_sum());
    } else if (settings.outputSortedBy == 'matchinghomophones') {
      return matches.sortedBy<num>((element) => element.matching_homophones).reversed.toList();
    }
  }

  Future<void> start_crib() async {
    await wordCrib();

    if (settings.outputSortedBy == 'shiftsum') {
      matches = matches.sortedBy<num>((element) => element.shift_sum);
    } else if (settings.outputSortedBy == 'shiftdifferencessum') {
      matches = matches.sortedBy<num>((element) => element.shift_difference_sum());
    } else if (settings.outputSortedBy == 'matchinghomophones') {
      matches = matches.sortedBy<num>((element) => element.matching_homophones).reversed.toList();
    }
  }
}
