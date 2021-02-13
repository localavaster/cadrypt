import 'dart:io';

import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/models/crib_settings.dart';
import 'package:cicadrypt/services/oeis_search.dart';
import 'package:get_it/get_it.dart';
import 'package:characters/characters.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../models/crib_match.dart';

class Crib {
  Crib(this.settings, this.runeWord) : splitRuneWord = runeWord.split('') {
    try {
      splitRuneWordEnglish = List<String>.generate(runeWord.split('').length, (index) => runeToEnglish[runeWord.split('')[index]].toLowerCase());
    } catch (e) {
      print('crib.dart:19 -> $e');
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
        final runeIndex = runes.indexOf(rune);

        int englishIndex = runeEnglish.indexOf(splitEnglishWord.elementAt(index));

        if (englishIndex == -1) {
          englishIndex = altRuneEnglish.indexOf(splitEnglishWord.elementAt(index));
        }

        if (englishIndex == -1) {
          print('cant find ${splitEnglishWord[index]}');
        }

        final difference = (runeIndex - englishIndex) % 29;

        shifts.add(difference);
      }
    });

    return shifts;
    // shifts
  }

  Future<List<CribMatch>> wordCrib({int maximumLengthOffset = 3}) async {
    /*OEISLookUp oeislookup;
    if (settings.oeisLookUp == true) {
      oeislookup = OEISLookUp(localLookUp: true);
    }*/

    final runeWordLength = runeWord.length;
    final possibleWords = settings.get_crib_words(minimumLength: runeWordLength, maximumLengthOffset: 3);

    OEISLookUp oeis;
    if (settings.filters.contains('shiftisinoeis')) {
      oeis = OEISLookUp(localLookUp: true);
    }

    wordLoop:
    for (final word in possibleWords) {
      final splitEnglishWord = gematriaRegex.allMatches(word.toLowerCase()).map((e) => e.group(0)).toList(); // slow

      if (splitEnglishWord.length != splitRuneWord.length) continue;

      if (settings.wordFilters.contains('onlymagicsquaresums')) {
        final primeListOfWord = <int>[];
        for (final splitLetter in splitEnglishWord) {
          int prime = letterToPrime[splitLetter.toUpperCase()];
          prime ??= altLetterToPrime[splitLetter.toUpperCase()];

          if (prime == null) continue wordLoop;

          primeListOfWord.add(prime);
        }

        final int sum = primeListOfWord.sum();

        if (!square_sums.contains(sum)) continue wordLoop;
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
        int incrementingShifts = 0;
        for (int i = 0; i < (shifts.length - 1); i++) {
          final current = shifts[i];
          final next = shifts[i + 1];

          if (next > current) incrementingShifts++;
        }

        if (incrementingShifts < shifts.length - 3) continue wordLoop;
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

      if (settings.filters.contains('onlytotprimeshifts')) {
        int minimumPrimeShifts = shifts.length;
        //if (minimumPrimeShifts > 6) minimumPrimeShifts = minimumPrimeShifts - 1;

        int primeShifts = 0;
        for (final shift in shifts) {
          if (prime_with_totient.contains(shift)) primeShifts++;
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
      } // mfw o n  2

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

      matches.add(CribMatch(runeWord, word.toLowerCase(), shifts));
    }

    if (settings.filters.contains('onlypuregpshifts')) {
      matches.removeWhere((match) => match.shift_word_using_gp.contains(RegExp(r'[?(]')));
    }

    if (settings.filters.contains('onlyimpuregpshifts')) {
      matches.removeWhere((match) => match.shift_word_using_gp.contains(RegExp(r'[^?(]')));
    }

    //eoeislookup?.client?.close(force: true);
    return matches.sortedByNum((element) => element.shift_sum);
  }

  List<CribMatch> wordCribSync({int maximumLengthOffset = 3}) {
    final runeWordLength = runeWord.length;
    final possibleWords = settings.get_crib_words(minimumLength: runeWordLength, maximumLengthOffset: 3);

    wordLoop:
    for (final word in possibleWords) {
      final splitEnglishWord = gematriaRegex.allMatches(word).map((e) => e.group(0)).toList(); // slow

      if (splitEnglishWord.length != splitRuneWord.length) continue;

      final List<int> shifts = shifts_to_get_word(splitEnglishWord);

      matches.add(CribMatch(runeWord, word, shifts));
    }

    return matches.sortedByNum((element) => element.shift_sum);
  }

  Future<void> start_crib() async {
    await wordCrib();

    this.matches = this.matches.sortedByNum((element) => element.shift_sum);
  }
}
