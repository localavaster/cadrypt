import 'package:cicadrypt/constants/libertext.dart';
import 'package:collection/collection.dart';

import '../constants/runes.dart';
import '../models/magic_square_match.dart';
import '../models/magic_square_settings.dart';

class MagicSquareCrib {
  final MagicSquareCribSettings settings;

  final int magicNumber;

  final List<MagicSquareMatch> matches = [];

  MagicSquareCrib(this.settings, String magicNumber) : magicNumber = int.parse(magicNumber);

  void start_crib() {
    final possibleWords = settings.get_crib_words();

    wordLoop:
    for (final word in possibleWords) {
      final splitEnglishWord = gematriaRegex.allMatches(word).map((e) => e.group(0)).toList(); // slow

      final primeListOfWord = <int>[];
      for (final splitLetter in splitEnglishWord) {
        int prime = letterToPrime[splitLetter.toUpperCase()];
        prime ??= altLetterToPrime[splitLetter.toUpperCase()];

        if (prime == null) continue wordLoop;

        primeListOfWord.add(prime);
      }

      final int sum = primeListOfWord.sum;

      if (sum != magicNumber) continue wordLoop;

      matches.add(MagicSquareMatch(word, sum, primeListOfWord));
    }

    if (settings.bruteforce_pad) {
      wordLoop:
      for (final word in possibleWords) {
        for (int i = 0; i < runes.length; i++) {
          final libified = LiberText('${runes[i]}${word}${runes[i]}');

          final int sum = libified.prime_sum;

          if (sum != magicNumber) continue wordLoop;

          matches.add(MagicSquareMatch(word, sum, libified.prime));
        }
      }
    }

    if (settings.bruteforce) {
      // what the fuck is this?
      for (int i = 0; i < runes.length; i++) {
        final word = LiberText(runes[i]);

        if (word.prime_sum == magicNumber) matches.add(MagicSquareMatch(word.english.toLowerCase(), word.prime_sum, word.prime));
      }

      for (int a = 0; a < runes.length; a++) {
        for (int b = 0; b < runes.length; b++) {
          final word = LiberText('${runes[a]}${runes[b]}');

          if (word.prime_sum == magicNumber) matches.add(MagicSquareMatch(word.english.toLowerCase(), word.prime_sum, word.prime));
        }
      }

      for (int a = 0; a < runes.length; a++) {
        for (int b = 0; b < runes.length; b++) {
          for (int c = 0; c < runes.length; c++) {
            final word = LiberText('${runes[a]}${runes[b]}${runes[c]}');

            if (word.prime_sum == magicNumber) matches.add(MagicSquareMatch(word.english.toLowerCase(), word.prime_sum, word.prime));
          }
        }
      }

      for (int a = 0; a < runes.length; a++) {
        for (int b = 0; b < runes.length; b++) {
          for (int c = 0; c < runes.length; c++) {
            for (int d = 0; d < runes.length; d++) {
              final word = LiberText('${runes[a]}${runes[b]}${runes[c]}${runes[d]}');

              if (word.prime_sum == magicNumber) matches.add(MagicSquareMatch(word.english.toLowerCase(), word.prime_sum, word.prime));
            }
          }
        }
      }
    }

    print(settings.filters);

    if (settings.filters.contains('sameprimeandindex')) {
      print('sameprimeandindex');
      matches.removeWhere((element) {
        final gp_mod_29 = List<int>.generate(element.values.length, (index) => element.values[index] % runes.length);
        final indexs_of_word = LiberText(element.word).index;

        bool equal = true;

        for (int i = 0; i < gp_mod_29.length; i++) {
          final value_a = gp_mod_29[i];
          final value_b = indexs_of_word[i];

          if (value_a != value_b) {
            equal = false;
            break;
          }
        }

        return !equal;
      });
    }

    if (settings.sorting == MagicSquareCribOutputSorting.length) {
      matches.sortBy<num>((element) => element.values.length);
    }
  }
}
