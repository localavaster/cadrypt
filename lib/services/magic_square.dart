import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/runes.dart';
import '../models/magic_square_match.dart';
import '../models/magic_square_settings.dart';
import 'package:collection/collection.dart';

class MagicSquareCrib {
  final MagicSquareCribSettings settings;

  final int magicNumber;

  final List<MagicSquareMatch> matches = [];

  MagicSquareCrib(this.settings, String magicNumber) : this.magicNumber = int.parse(magicNumber);

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
  }
}
