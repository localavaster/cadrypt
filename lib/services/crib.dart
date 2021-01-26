import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/models/crib_settings.dart';
import 'package:cicadrypt/services/oeis_search.dart';
import 'package:get_it/get_it.dart';
import 'package:characters/characters.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../models/crib_match.dart';

final gematriaRegex = RegExp('((th)|(ng)|(ea)|(oe)|(io)|(eo))|(.)',
    dotAll: true, caseSensitive: false);

class Crib {
  Crib(this.settings, this.runeWord)
      : splitRuneWord = runeWord.split(''),
        splitRuneWordEnglish = List<String>.generate(runeWord.split('').length,
            (index) => runeToEnglish[runeWord.split('')[index]].toLowerCase());

  final CribSettings settings;

  final List<String> splitRuneWordEnglish;
  final String runeWord;
  final List<String> splitRuneWord;

  List<CribMatch> matches = [];

  List<int> shifts_to_get_word(List<String> splitEnglishWord) {
    final List<int> shifts = [];

    splitRuneWord.forEachIndexed((index, rune) {
      if (splitRuneWord.length == 1 && splitEnglishWord.length != 1) return;

      if (splitRuneWord.length == splitEnglishWord.length) {
        final runeIndex = runes.indexOf(rune);

        int englishIndex =
            rune_english.indexOf(splitEnglishWord.elementAt(index));

        if (englishIndex == -1) {
          englishIndex =
              alt_rune_english.indexOf(splitEnglishWord.elementAt(index));
        }

        final difference = (runeIndex - englishIndex) % 29;

        shifts.add(difference);
      }
    });

    return shifts;
    // shifts
  }

  Future<List<CribMatch>> crib({int maximumLengthOffset = 3}) async {
    OEISLookUp oeislookup;
    if (settings.oeisLookUp == true) {
      oeislookup = OEISLookUp();
    }

    final runeWordLength = runeWord.length;
    final possibleWords = settings.get_crib_words(
        minimumLength: runeWordLength, maximumLengthOffset: 3);

    wordLoop:
    for (final word in possibleWords) {
      final splitEnglishWord = gematriaRegex
          .allMatches(word)
          .map((e) => e.group(0))
          .toList(); // slow

      if (splitEnglishWord.length != splitRuneWord.length) continue;
      //if (word.length != splitRuneWord.length) continue;

      if (settings.blacklistCipherLetters == true) {
        for (int i = 0; i < splitEnglishWord.length; i++) {
          final englishCharacter = splitEnglishWord[i];
          final cipherCharacter = splitRuneWordEnglish[i];

          if (englishCharacter == cipherCharacter) continue wordLoop;
        }
      }

      if (settings.blacklistDoubleLetters == true) {
        for (int i = 0; i < splitEnglishWord.length; i++) {
          final englishCharacter = splitEnglishWord[i];

          if (english_double_runes.contains(englishCharacter))
            continue wordLoop;
        }
      }

      final List<int> shifts = shifts_to_get_word(splitEnglishWord);

      bool sequenceInOEIS = null;
      if (settings.oeisLookUp == true) {
        sequenceInOEIS = await oeislookup.oeisContainsSequence(shifts);

        if (sequenceInOEIS == false) continue;
      }

      matches.add(CribMatch(word, shifts, shiftSequenceInOEIS: sequenceInOEIS));
    }

    oeislookup?.client?.close(force: true);
    return matches.sortedByNum((element) => element.shift_sum);
  }
}
