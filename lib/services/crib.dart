import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

import '../constants/extensions.dart';
import '../constants/runes.dart';
import '../constants/utils.dart';
import '../models/crib_match.dart';
import '../models/crib_settings.dart';
import 'crib_cache.dart';
import 'oeis_search.dart';

class Crib {
  Crib(this.settings, this.runeWord) : splitRuneWord = runeWord.split('') {
    splitRuneWordEnglish = List<String>.generate(splitRuneWord.length, (index) => runeToEnglish[splitRuneWord[index]].toLowerCase());
  }

  final CribSettings settings;

  final String runeWord;

  List<String> splitRuneWordEnglish;
  final List<String> splitRuneWord;

  List<CribMatch> matches = [];

  List<int> negative_shifts_to_get_word(List<String> splitEnglishWord) {
    final List<int> shifts = [];

    splitRuneWord.forEachIndexed((index, rune) {
      if (splitRuneWord.length == 1 && splitEnglishWord.length != 1) return;

      if (splitRuneWord.length == splitEnglishWord.length) {
        final runeIndex = runes.indexOf(rune);

        int englishIndex = runeEnglish.indexOf(splitEnglishWord.elementAt(index));

        if (englishIndex == -1) {
          englishIndex = altRuneEnglish.indexOf(splitEnglishWord.elementAt(index));
        }

        if (englishIndex == -1) {
          print('Word List Error: cannot find ${splitEnglishWord[index]} in ${splitEnglishWord.join()}');
        }

        final difference = (runeIndex - englishIndex) % runes.length;

        shifts.add(difference);
      }
    });

    return shifts;
    // shifts
  }

  List<int> positive_shifts_to_get_word(List<String> splitEnglishWord) {
    final List<int> shifts = [];

    splitRuneWord.forEachIndexed((index, rune) {
      if (splitRuneWord.length == 1 && splitEnglishWord.length != 1) return;

      if (splitRuneWord.length == splitEnglishWord.length) {
        final runeIndex = runes.indexOf(rune);

        int englishIndex = runeEnglish.indexOf(splitEnglishWord.elementAt(index));

        if (englishIndex == -1) {
          englishIndex = altRuneEnglish.indexOf(splitEnglishWord.elementAt(index));
        }

        if (englishIndex == -1) {
          print('Word List Error: cannot find ${splitEnglishWord[index]} in ${splitEnglishWord.join()}');
        }

        final difference = (runeIndex - (englishIndex + runes.length)).abs() % runes.length;

        shifts.add(difference);
      }
    });

    return shifts;
    // shifts
  }

  Future<List<CribMatch>> wordCrib({List<String> onlyIncludeWords}) async {
    final possibleWords = settings.get_crib_words(wordBeingCribbed: runeWord, onlyIncludeWords: onlyIncludeWords);

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
      final List<String> extra_information = [];
      final List<String> splitEnglishWord = gematriaRegex.allMatches(word.toLowerCase()).map((e) => e.group(0)).toList(); // slow

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

      int matchingHomophones = 0;
      if (settings.wordFilters.contains('usecribcachehomophones')) {
        for (int i = 0; i < runeWord.length; i++) {
          final originalRuneLetter = runeWord.split('')[i];
          final hps = homophones[originalRuneLetter];
          if (hps.isEmpty) continue;

          final cribEnglishLetter = splitEnglishWord[i];

          if (hps.contains(cribEnglishLetter)) matchingHomophones++;
        }

        if (matchingHomophones == 0) continue wordLoop;
      }

      if (settings.filters.contains('noplaintext')) {
        int sameLetters = 0;
        splitEnglishWord.forEachIndexed((index, wordLetter) {
          final runeLetter = splitRuneWordEnglish[index].toLowerCase();

          if (wordLetter.toLowerCase() == runeLetter) sameLetters++;
        });

        if (sameLetters != 0) continue wordLoop;
      }

      if (settings.filters.contains('nodoubleletters')) {
        for (final letter in splitEnglishWord) {
          if (letter.length == 2) continue wordLoop;
        }
      }

      List<int> shifts = [];
      if (settings.shiftMode == 'negative') shifts = negative_shifts_to_get_word(splitEnglishWord);
      if (settings.shiftMode == 'positive') shifts = positive_shifts_to_get_word(splitEnglishWord);

      if (settings.filters.contains('onlyincshifts')) {
        if (!shifts.is_incremental()) continue wordLoop;
      }

      if (settings.filters.contains('onlydecshifts')) {
        if (!shifts.is_decremental()) continue wordLoop;
      }

      if (settings.filters.contains('onlyunique')) {
        if (shifts.toSet().length != shifts.length) continue wordLoop;
      }

      if (settings.filters.contains('onlysimilar')) {
        if (shifts.toSet().length == shifts.length) continue wordLoop;
      }

      if (settings.filters.contains('hasplaintext')) {
        int sameLetters = 0;
        splitEnglishWord.forEachIndexed((index, wordLetter) {
          final runeLetter = splitRuneWordEnglish[index].toLowerCase();

          if (wordLetter.toLowerCase() == runeLetter) sameLetters++;
        });

        if (sameLetters != 1) continue wordLoop;
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
        final int sequenceInOEIS = oeis.localOeisContainsSequnece(shifts);

        if (sequenceInOEIS == -1) continue wordLoop;

        extra_information.add('sequence: ${sequenceInOEIS}');
      } // mfw time complexity

      if (settings.interruptors.isNotEmpty) {
        final interruptors = List<String>.generate(settings.interruptors.length, (index) => runeToEnglish[settings.interruptors[index]].toLowerCase());

        if (!shifts.contains(0)) continue wordLoop;

        final indexesOfZero = <int>[];

        for (int i = 0; i < shifts.length; i++) {
          final shift = shifts[i];

          if (shift == 0) indexesOfZero.add(i);
        }

        final plaintextLetters = List<String>.generate(indexesOfZero.length, (index) => splitEnglishWord[indexesOfZero[index]]);

        for (final plaintext in plaintextLetters) {
          if (!interruptors.contains(plaintext)) continue wordLoop;
        }
      }

      matches.add(CribMatch(runeWord, word, splitEnglishWord, shifts, matchingHomophones, extra_information));
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
