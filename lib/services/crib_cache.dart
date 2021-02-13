import 'package:cicadrypt/models/crib_match.dart';

import 'package:supercharged_dart/supercharged_dart.dart';

class CribCache {
  List<CribMatch> cache = [];

  int cached_amount() {
    return cache.length;
  }

  void add(CribMatch match) {
    // do nothing for now
    //cache.add(match);
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

  bool similarSum(List<int> sequenceA, List<int> sequenceB) {
    final int sumA = sequenceA.sum();
    final int sumB = sequenceB.sum();

    return sumB >= (sumA - 30) && sumB <= (sumA + 30);
  }

  List<CribMatch> getSimilar() {
    final Map<CribMatch, List<CribMatch>> similar = {};

    for (final parent in cache) {
      similar[parent] ??= [];

      for (final child in cache) {
        if (parent == child) continue;

        if (!sequenceHasSameNumbers(parent.shifts, child.shifts)) continue;

        if (!similarDistance(parent.shifts, child.shifts)) continue;

        if (!similarSum(parent.shifts, child.shifts)) continue;

        similar[parent].add(child);
      }
    }

    similar.forEach((key, value) {
      if (value.length > 2) {
        print(key.crib);
        print('==${value.length}');
      }
    });
  }
}
