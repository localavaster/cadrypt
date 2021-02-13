import 'dart:io';
import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/runes.dart';

class HeaderBoundary {
  int start;
  int end;
  HeaderBoundary(this.start, this.end);
}

class Cipher {
  Cipher(this.raw_cipher) {
    cipher = raw_cipher.join();
  }

  List<String> raw_cipher;
  String cipher;
  int flat_cipher_length = 0;
  int cipher_length = 0;
  Map<String, int> frequencies = {};
  Map<String, int> repeated_ngrams = {};
  //
  String current_cipher_file = '';
  int longest_row = 0;
  List<int> spacer_row_indexes = [];

  List<HeaderBoundary> headers = [];

  bool load_from_file(String path) {
    try {
      final List<String> parsed = [];
      final List<String> unparsed = File(path).readAsLinesSync();

      cipher_length = unparsed.join().length;
      flat_cipher_length = unparsed.join().replaceAll('-', '').replaceAll('.', '').replaceAll(' ', '').replaceAll(RegExp(r'[$%&]'), '').length;

      for (final line in unparsed) {
        final formatted = line.replaceAll('-', ' ');
        parsed.add(formatted);
      }

      raw_cipher = parsed;

      spacer_row_indexes = get_spacer_row_indexes();
      longest_row = get_longest_row();
      frequencies = get_character_frequencies();
      repeated_ngrams = get_repeated_grams();

      current_cipher_file = path;
    } on Exception catch (e) {
      print('failure $e');
      return false;
    }

    return true;
  }

  List<int> get_spacer_row_indexes() {
    final spacerRows = raw_cipher.where((element) => element.split('').count((s) => s == '') >= 12);

    final spacerRowIndexes = <int>[];
    raw_cipher.forEachIndexed((index, row) {
      if (spacerRows.contains(row)) {
        spacerRowIndexes.add(index);
      }
    });

    return spacerRowIndexes;
  }

  int get_longest_row() {
    final sorted_row_lengths = List<int>.generate(raw_cipher.length, (index) => raw_cipher[index].length).toList().sortedBy((a, b) => b.compareTo(a));

    return sorted_row_lengths.first;
  }

  String get_flat_cipher() {
    return raw_cipher.join().replaceAll('-', '').replaceAll(r'\', '').replaceAll(' ', '').replaceAll('.', '').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '');
  }

  Map<String, int> get_character_frequencies({bool runeOnly = true}) {
    final Map<String, int> seen = {};

    for (final character in raw_cipher.join().characters) {
      if (runeOnly) {
        if (!runeToEnglish.containsKey(character)) continue;
      }

      if (seen.containsKey(character)) {
        seen[character] += 1;
      } else {
        seen[character] = 1;
      }
    }

    return seen;
  }

  int get_single_frequency(String rune) {
    return frequencies[rune];
  }

  int get_regex_frequency(String pattern) {
    final regex = RegExp('($pattern)');
    final matches = regex.allMatches(this.raw_cipher.join());

    return matches.length;
  }

  int get_total_frequency(List<String> runes) {
    int sum = 0;

    for (final rune in runes) {
      if (!frequencies.containsKey(rune)) continue;

      sum += frequencies[rune];
    }

    return sum;
  }

  double get_frequency_percent(int count) {
    return (count / flat_cipher_length) * 100;
  }

  bool is_rune_double_letter(String rune) {
    return runeToEnglish[rune].length == 2;
  }

  double get_index_of_coincidence({String text = null}) {
    final List<String> alphabet = runes;

    String flat_cipher = get_flat_cipher();
    if (text != null) {
      flat_cipher = text.replaceAll(RegExp('[ .]'), '');
    }

    final length = flat_cipher.length;

    final chunked_cipher = flat_cipher.split('');
    final letters_in_cipher = chunked_cipher.toSet();
    final frequencies = {for (final letter in letters_in_cipher) letter: chunked_cipher.count((e) => e == letter)}; // fastest frequency counter in the west

    final frequency_sum = alphabet.sumByDouble((s) => frequencies.containsKey(s) ? frequencies[s] * (frequencies[s] - 1) : 0.0);

    if (frequency_sum == 0.0) return 0.0;

    return frequency_sum / (length * (length - 1));
  }

  double get_entropy() {
    final occurences = this.get_character_frequencies().values.toList();
    final total = occurences.sum();
    double sum = 0.0;

    for (final occurence in occurences) {
      sum += (occurence / total * math.log(total / occurence));
    }

    return sum;
  }

  double get_average_distance_until_letter_repeat() {
    // first, iterate the entire text
    final flat_cipher = get_flat_cipher();

    final letter_seen_indexes = <String, List<int>>{};

    flat_cipher.characters.forEachIndexed((index, rune) {
      letter_seen_indexes[rune] ??= [];

      letter_seen_indexes[rune].add(index);
    });

    final List<int> distances = [];

    for (final seenIndexes in letter_seen_indexes.values) {
      for (int i = 0; i < seenIndexes.length; i++) {
        try {
          final current = seenIndexes[i];
          final next = seenIndexes[i + 1];

          final distance = (next - current);

          distances.add(distance);
        } catch (e) {
          continue;
        }
      }
    }

    return distances.average();
  }

  double get_average_distance_until_double_rune_repeat() {
    // first, iterate the entire text
    final flat_cipher = get_flat_cipher();

    final letter_seen_indexes = <String, List<int>>{};

    flat_cipher.characters.forEachIndexed((index, rune) {
      if (doubleRunes.contains(rune)) {
        letter_seen_indexes[rune] ??= [];

        letter_seen_indexes[rune].add(index);
      }
    });

    final List<int> distances = [];

    for (final seenIndexes in letter_seen_indexes.values) {
      for (int i = 0; i < seenIndexes.length; i++) {
        try {
          final current = seenIndexes[i];
          final next = seenIndexes[i + 1];

          final distance = (next - current);

          distances.add(distance);
        } catch (e) {
          continue;
        }
      }
    }

    return distances.average();
  }

  double get_average_distance_until_x_rune_repeat() {
    // first, iterate the entire text
    final flat_cipher = get_flat_cipher();

    final letter_seen_indexes = <String, List<int>>{};

    flat_cipher.characters.forEachIndexed((index, rune) {
      if (rune == 'ᛉ') {
        letter_seen_indexes[rune] ??= [];

        letter_seen_indexes[rune].add(index);
      }
    });

    final List<int> distances = [];

    for (final seenIndexes in letter_seen_indexes.values) {
      for (int i = 0; i < seenIndexes.length; i++) {
        try {
          final current = seenIndexes[i];
          final next = seenIndexes[i + 1];

          final distance = (next - current);

          distances.add(distance);
        } catch (e) {
          continue;
        }
      }
    }

    if (distances.isEmpty) return 0.0;

    return distances.average();
  }

  double get_normalized_bigram_repeats() {
    // not dry
    final bigrams = get_ngrams(2);
    final repeated_bigrams = <String, int>{};
    for (final bigram in bigrams) {
      final count = bigrams.count((string) => string == bigram);
      if (count <= 1) continue;

      if (!repeated_bigrams.containsKey(bigram)) {
        repeated_bigrams[bigram] = count;
      }
    }

    final int sum_of_bigram_occurences = repeated_bigrams.values.sum();
    final int pattern_character_occurences = (sum_of_bigram_occurences * 2).toInt();

    if (cipher_length == 0 || pattern_character_occurences == 0) return 0.0;

    return pattern_character_occurences / cipher_length;
  }

  List<String> get_ngrams(int n) {
    /*def ngrams(input, n):
    input = input.split(' ')
    output = []
    for i in range(len(input)-n+1):
        output.append(input[i:i+n])
    return output*/

    final flat_cipher = get_flat_cipher();
    final List<String> result = [];
    for (int i = 0; i < flat_cipher.length; i += 1) {
      final gram = flat_cipher.split('').sublist(i, (i + n).clamp(0, flat_cipher.length).toInt()).join();
      if (gram.length != n) continue;

      result.add(gram);
    }
    return result;
  }

  Map<String, int> get_repeated_grams() {
    final bigrams = get_ngrams(2);
    final trigrams = get_ngrams(3);
    final quadgrams = get_ngrams(4);
    final fivegrams = get_ngrams(5);
    final sixgrams = get_ngrams(6);

    final Map<String, int> repeated = {};

    for (final sixgram in sixgrams) {
      final count = sixgrams.count((string) => string == sixgram);

      if (count == 1) continue;

      if (!repeated.containsKey(sixgram)) {
        repeated[sixgram] = count;
      }
    }

    for (final fivegram in fivegrams) {
      final count = fivegrams.count((string) => string == fivegram);

      if (count == 1) continue;

      if (!repeated.containsKey(fivegram)) {
        repeated[fivegram] = count;
      }
    }

    for (final quadgram in quadgrams) {
      final count = quadgrams.count((string) => string == quadgram);

      if (count == 1) continue;

      if (!repeated.containsKey(quadgram)) {
        repeated[quadgram] = count;
      }
    }

    for (final trigram in trigrams) {
      final count = trigrams.count((string) => string == trigram);

      if (count == 1) continue;

      if (!repeated.containsKey(trigram)) {
        repeated[trigram] = count;
      }
    }

    for (final bigram in bigrams) {
      final count = bigrams.count((string) => string == bigram);

      if (count == 1) continue;

      if (!repeated.containsKey(bigram)) {
        repeated[bigram] = count;
      }
    }

    return repeated;
  }

  List<String> get_characters_not_used() {
    final characters = List<String>.from(runeToEnglish.keys.toList())..removeWhere((element) => raw_cipher.join('').contains(element));

    return characters;
  }

  //////////////////////////////////////////
}
