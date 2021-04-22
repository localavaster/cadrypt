import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

import '../constants/runes.dart';
import '../global/settings.dart';
import '../models/crib_match.dart';

class CribCache {
  List<CribMatch> cache = [];

  int cached_amount() {
    return cache.length;
  }

  void add(CribMatch match) {
    if (cache.where((element) => element.cribbed_word == match.cribbed_word && element.shift_sum == match.shift_sum).isNotEmpty) return;

    cache.add(match);
  }

  bool sequenceHasSameNumbers(List<int> sequenceA, List<int> sequenceB) {
    int sameNumbers = 0;

    for (int i = 0; i < sequenceA.length; i++) {
      try {
        final aNum = sequenceA[i];

        loop:
        for (final bNum in sequenceB) {
          if (bNum == aNum) {
            sameNumbers++;
            break loop;
          }
        }
      } catch (e) {
        break;
      }
    }

    return sameNumbers >= sequenceA.length - 1;
  }

  bool similarDistance(List<int> sequenceA, List<int> sequenceB) {
    final int sequenceADistance = (sequenceA.first - sequenceA.last).abs();
    final int sequenceBDistance = (sequenceB.first - sequenceB.last).abs();

    if (sequenceBDistance >= (sequenceADistance - 5) && sequenceBDistance <= (sequenceADistance + 5)) return true;

    return false;
  }

  bool similar_sum(List<int> sequenceA, List<int> sequenceB) {
    final int sumA = sequenceA.sum;
    final int sumB = sequenceB.sum;

    return sumB >= (sumA - 30) && sumB <= (sumA + 30);
  }

  List<CribMatch> get_similar() {
    final Map<CribMatch, List<CribMatch>> similar = {};

    for (final parent in cache) {
      similar[parent] ??= [];

      for (final child in cache) {
        if (parent == child) continue;

        if (!sequenceHasSameNumbers(parent.shifts, child.shifts)) continue;

        if (!similarDistance(parent.shifts, child.shifts)) continue;

        if (!similar_sum(parent.shifts, child.shifts)) continue;

        similar[parent].add(child);
      }
    }

    similar.forEach((key, value) {
      if (value.length > 2) {
        print(key.cribbed_word);
        print('==${value.length}');
      }
    });
  }

  // homophones, etc

  Map<String, List<String>> calculate_homophones() {
    final homophones = <String, List<String>>{};
    final List<String> alphabet = runes;

    alphabet.forEach((element) {
      homophones[element] = [];
    });

    for (final crib in cache) {
      final cribWord = crib.original_word.split('');
      List<String> realWord = [];
      if (GetIt.I<Settings>().is_cicada_mode()) {
        realWord = gematriaRegex.allMatches(crib.cribbed_word.toLowerCase()).map((e) => e.group(0)).toList();
      } else {
        realWord = crib.cribbed_word.split('');
      }

      for (int i = 0; i < cribWord.length; i++) {
        final cribLetter = cribWord[i];
        final realLetter = realWord[i];

        if (!homophones[cribLetter].contains(cribLetter)) {
          homophones[cribLetter].add(realLetter);
        }
      }
    }
    return homophones;
  }
}
