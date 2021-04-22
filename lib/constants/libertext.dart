import 'package:characters/characters.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'runes.dart';

// A simple universal text class with caching and easy methods of translation
// also featuring a singleton style cache (there is no need for 50 instances of F, for example)

final LiberTextCache = <int, LiberTextClass>{};

class LiberTextClass extends Equatable {
  final String text;
  LiberTextClass(this.text) {
    LiberTextCache[text.hashCode] = this;
  }

  String _cached_english;
  String _cached_rune;
  List<int> _cached_prime;
  List<int> _cached_index;
  int _cached_sum;

  String get english => _get_english();
  String _get_english() {
    if (_cached_english != null && _cached_english.isNotEmpty) return _cached_english;

    final english = List<String>.generate(text.length, (index) {
      final character = text.characters.elementAt(index);

      if (runes.contains(character)) {
        return runeToEnglish[text.characters.elementAt(index)];
      } else {
        return character;
      }
    }).join();

    if (_cached_english == null || _cached_english.isEmpty) _cached_english = english;

    return english;
  }

  String get rune => _get_rune();
  String _get_rune() {
    if (_cached_rune != null && _cached_rune.isNotEmpty) return _cached_rune;

    final textSplit = gematriaRegex.allMatches(text).map((e) => e.group(0)).toList();

    final rune = List<String>.generate(textSplit.length, (index) {
      final character = textSplit[index];
      int idx = runeEnglish.indexOf(character);
      if (idx == -1) idx = altRuneEnglish.indexOf(character);

      if (idx == -1) return character;

      return runes[idx];
    }).join();

    if (_cached_rune == null || _cached_rune.isEmpty) _cached_rune = rune;

    return rune;
  }

  List<int> get prime => _get_prime();
  List<int> _get_prime() {
    if (_cached_prime != null && _cached_prime.isNotEmpty) return _cached_prime;

    final runified = rune.split('');

    final primified = <int>[];

    for (final rune in runified) {
      if (runes.contains(rune)) {
        primified.add(int.parse(runePrimes[rune]));
      } else {
        primified.add(0);
      }
    }

    if (_cached_prime == null || _cached_prime.isEmpty) _cached_prime = primified;

    return primified;
  }

  List<int> get index => _get_index();
  List<int> _get_index() {
    if (_cached_index != null && _cached_index.isNotEmpty) return _cached_index;

    final runified = rune.split('');

    final indexified = <int>[];

    for (final rune in runified) {
      indexified.add(runes.indexOf(rune)); // will give -1 if not found
    }

    if (_cached_index == null || _cached_index.isEmpty) _cached_index = indexified;

    return indexified;
  }

  int get prime_sum => _get_sum();
  int _get_sum() {
    if (_cached_sum != null) return _cached_sum;

    final sum = prime.sum;

    _cached_sum ??= sum;

    return sum;
  }

  @override
  List<Object> get props => [rune];
}

LiberTextClass LiberText(String text) {
  final hash = text.hashCode;

  if (LiberTextCache.containsKey(hash)) {
    final cached = LiberTextCache[hash];

    if (cached == null) return LiberTextClass(text);

    return cached;
  } else {
    return LiberTextClass(text);
  }
}
