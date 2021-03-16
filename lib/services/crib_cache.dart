import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/global/settings.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../models/crib_match.dart';

class CribCache {
  List<CribMatch> cache = [];

  int cached_amount() {
    return cache.length;
  }

  void add(CribMatch match) {
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
    List<String> alphabet = GetIt.I<Settings>().get_alphabet();

    alphabet.forEach((element) {
      homophones[element] = [];
    });

    for (final crib in cache) {
      final crib_word = crib.original_word.split('');
      List<String> real_word = [];
      if (GetIt.I<Settings>().is_cicada_mode()) {
        real_word = gematriaRegex.allMatches(crib.cribbed_word.toLowerCase()).map((e) => e.group(0)).toList();
      } else {
        real_word = crib.cribbed_word.split('');
      }

      for (int i = 0; i < crib_word.length; i++) {
        final crib_letter = crib_word[i];
        final real_letter = real_word[i];

        if (!homophones[crib_letter].contains(crib_letter)) {
          homophones[crib_letter].add(real_letter);
        }
      }
    }
    return homophones;
  }
}
