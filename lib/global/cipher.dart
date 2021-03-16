import 'dart:io';
import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:cicadrypt/constants/libertext.dart';
import 'package:get_it/get_it.dart';
import 'package:string_splitter/string_splitter.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../constants/extensions.dart';
import '../constants/runes.dart';
import '../constants/timer.dart';
import '../models/gram.dart';
import 'settings.dart';

class HeaderBoundary {
  HeaderBoundary(this.start, this.end);
  int start;
  int end;
}

class Cipher {
  Cipher(this.raw_cipher) {
    cipher = raw_cipher.join();
  }

  List<String> raw_cipher;
  String cipher;
  int flat_cipher_length = 0;
  int cipher_length = 0;
  Map<LiberTextClass, int> frequencies = {};
  Map<LiberTextClass, int> repeated_ngrams = {};
  Map<NGram, List<NGram>> similar_ngrams = {};
  //
  String current_cipher_file = '';
  int longest_row = 0;
  List<int> spacer_row_indexes = [];

  List<HeaderBoundary> headers = [];

  bool load_from_file(String path) {
    try {
      final List<String> parsed = [];
      final List<String> unparsed = File(path).readAsLinesSync();

      final t1 = TimeCode(identifier: 'Parse Cipher');
      cipher_length = unparsed.join().length;
      flat_cipher_length = unparsed.join().replaceAll('-', '').replaceAll('.', '').replaceAll(' ', '').replaceAll(RegExp(r'[$%&]'), '').length;

      for (final line in unparsed) {
        final formatted = line.replaceAll('-', ' ').toLowerCase();
        parsed.add(formatted);
      }

      raw_cipher = parsed;

      final frequencie = TimeCode(identifier: 'Parse Frequencies');
      spacer_row_indexes = get_spacer_row_indexes();
      longest_row = get_longest_row();
      frequencies = get_character_frequencies();
      frequencie.stop_print();

      final ngramtimer = TimeCode(identifier: 'Parse nGram');
      cached_ngrams.clear();
      repeated_ngrams = get_repeated_grams();
      similar_ngrams = get_similar_grams();
      ngramtimer.stop_print();

      t1.stop_print();

      current_cipher_file = path;
    } on Exception catch (e) {
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
    final sorted_row_lengths = List<int>.generate(raw_cipher.length, (index) => raw_cipher[index].length).toList().sorted((a, b) => b.compareTo(a));

    return sorted_row_lengths.first;
  }

  String get_flat_cipher() {
    return raw_cipher.join().replaceAll('-', '').replaceAll(r'\', '').replaceAll(' ', '').replaceAll('.', '').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '');
  }

  List<String> get_cipher_words() {
    return raw_cipher.join().replaceAll(r'\', '').replaceAll(' ', '-').replaceAll('.', '-').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '').split('-');
  }

  Map<LiberTextClass, int> get_character_frequencies() {
    final alphabet = GetIt.I<Settings>().get_alphabet();
    final Map<LiberTextClass, int> seen = {};

    for (final character in raw_cipher.join().characters) {
      if (!alphabet.contains(character)) continue;

      final text = LiberText(character);

      if (seen.containsKey(text)) {
        seen[text] += 1;
      } else {
        seen[text] = 1;
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
    final List<String> alphabet = GetIt.I<Settings>().get_alphabet();

    String flat_cipher = get_flat_cipher();
    if (text != null) {
      flat_cipher = text.replaceAll(RegExp('[ .]'), '');
    }
    flat_cipher = flat_cipher.replaceAll(RegExp(r'\d'), '');

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
    final total = occurences.sum;
    double sum = 0.0;

    for (final occurence in occurences) {
      sum += occurence / total * math.log(total / occurence);
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
      for (int i = 0; i < seenIndexes.length - 1; i++) {
        try {
          final current = seenIndexes[i];
          final next = seenIndexes[i + 1];

          final distance = next - current;

          distances.add(distance);
        } catch (e) {
          continue;
        }
      }
    }

    if (distances == null || distances.average == null) return 0.0;

    return distances.average;
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

          final distance = next - current;

          distances.add(distance);
        } catch (e) {
          continue;
        }
      }
    }

    if (distances == null || distances.average == null) return 0.0;

    return distances.average;
  }

  double get_average_distance_until_rune_repeat(String runeToFind) {
    // first, iterate the entire text
    final flat_cipher = get_flat_cipher();

    final letter_seen_indexes = <String, List<int>>{};

    flat_cipher.characters.forEachIndexed((index, rune) {
      if (rune == runeToFind) {
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

          final distance = next - current;

          distances.add(distance);
        } catch (e) {
          continue;
        }
      }
    }

    if (distances == null || distances.average == null) return 0.0;

    return distances.average;
  }

  double get_normalized_bigram_repeats() {
    // not dry
    final bigrams = get_ngrams(2);
    final repeated_bigrams = <LiberTextClass, int>{};
    for (final bigram in bigrams) {
      final count = bigrams.count((string) => string == bigram);
      if (count <= 1) continue;

      if (!repeated_bigrams.containsKey(bigram)) {
        repeated_bigrams[bigram.gram] = count;
      }
    }

    final int sum_of_bigram_occurences = repeated_bigrams.values.sum;
    final int pattern_character_occurences = (sum_of_bigram_occurences * 2).toInt();

    if (cipher_length == 0 || pattern_character_occurences == 0) return 0.0;

    return pattern_character_occurences / cipher_length;
  }

  List<NGram> get_ngrams(int n, {String text = null}) {
    if (cached_ngrams.containsKey(n)) return cached_ngrams[n];

    final flat_cipher = text ?? get_flat_cipher();
    final split_cipher = flat_cipher.split('');

    final List<NGram> result = [];
    for (int i = 0; i < flat_cipher.length; i += 1) {
      final gram = split_cipher.sublist(i, (i + n).clamp(0, flat_cipher.length).toInt()).join();
      if (gram.length != n) continue;

      result.add(NGram(startIndex: i, gram: LiberText(gram)));
    }

    cached_ngrams[n] = result;
    return result;
  }

  Map<int, List<NGram>> cached_ngrams = {};

  Map<LiberTextClass, int> get_repeated_ngrams(int n, {String text = null}) {
    final ngrams = get_ngrams(n, text: text);

    final Map<LiberTextClass, int> repeated = {};

    for (final gram in ngrams) {
      final count = ngrams.count((string) => string == gram);

      if (count == 1) continue;

      if (!repeated.containsKey(gram)) {
        repeated[gram.gram] = count;
      }
    }

    return repeated;
  }

  Map<LiberTextClass, int> get_repeated_grams() {
    final Map<LiberTextClass, int> repeated = {};

    for (int gramsize = 2; gramsize < 8; gramsize++) {
      final grams = get_ngrams(gramsize);

      for (final gram in grams) {
        final count = grams.count((_gram) => _gram.gram == gram.gram);

        if (count <= 1) continue;

        if (!repeated.containsKey(gram.gram)) {
          repeated[gram.gram] = count;
        }
      }
    }

    return repeated;
  }

  Map<NGram, List<NGram>> get_similar_grams() {
    final Map<NGram, List<NGram>> repeated = {};

    for (int gramsize = 3; gramsize < 8; gramsize++) {
      final grams = get_ngrams(gramsize);
      final similarity_threshold = (gramsize * 0.34).floor();

      for (final gram in grams) {
        final similar_grams = grams.where((_gram) => _gram != gram && gram.similarity(_gram, threshold: similarity_threshold + 1) <= similarity_threshold).toList();

        if (similar_grams.length <= 1) continue;

        if (gramsize == 3 && similar_grams.length <= 2) continue;

        if (repeated.keys.where((element) => element.gram == gram.gram).isEmpty) {
          repeated[gram] = similar_grams;
        }
      }
    }

    return repeated;
  }

  List<String> get_characters_not_used() {
    final characters = List<String>.from(GetIt.I<Settings>().get_alphabet())..removeWhere((element) => raw_cipher.join('').contains(element));

    return characters;
  }

  Map<int, double> get_chunked_periodic_iocs({int maxKeyLength = 32}) {
    final Map<int, double> periodicIoCs = {};

    for (int i = 1; i < maxKeyLength; i++) {
      final chunkedCipher = List<String>.from(StringSplitter.chunk(get_flat_cipher(), i))..removeWhere((element) => element.length != i);

      final List<double> iocs = [];

      for (final chunk in chunkedCipher) {
        final ioc = get_index_of_coincidence(text: chunk);

        iocs.add(ioc);
      }

      periodicIoCs[i] = iocs.average;
    }

    return periodicIoCs;
  }

  Map<int, double> get_word_periodic_iocs() {
    final Map<int, double> periodicIoCs = {};

    final cipher_words = get_cipher_words().sortedBy<num>((element) => element.length);

    final grouped_cipher_words = <int, StringBuffer>{};

    for (final word in cipher_words) {
      grouped_cipher_words[word.length] ??= StringBuffer();

      grouped_cipher_words[word.length].write(word);
    }

    for (final length in grouped_cipher_words.keys) {
      final ioc = get_index_of_coincidence(text: grouped_cipher_words[length].toString());

      periodicIoCs[length] = ioc;
    }

    return periodicIoCs;
  }

  Map<int, double> get_ioc_history() {
    final Map<int, double> history = {};

    final flat_cipher = get_flat_cipher();

    for (int i = 0; i < flat_cipher.length; i++) {
      final sub_flat_cipher = flat_cipher.substring(0, i);

      final ioc = get_index_of_coincidence(text: sub_flat_cipher);

      history[i] = ioc;
    }

    return history;
  }

  Map<List<int>, double> find_best_ioc() {
    final Map<List<int>, double> history = {};

    final flat_cipher = get_flat_cipher();

    for (int s = 0; s < flat_cipher.length; s++) {
      for (int e = s; e < flat_cipher.length; e++) {
        final sub_flat_cipher = flat_cipher.substring(s, e);

        if (sub_flat_cipher.length <= 20) continue;

        final ioc = get_index_of_coincidence(text: sub_flat_cipher);

        if (ioc >= 0.1) continue;

        history[[s, e]] = ioc;
      }
    }

    return history;
  }

  Map<int, int> get_common_factors_of_repeats() {
    final Map<int, int> seenFactors = {};

    // analyze triGRAMS
    final repeatingTrigrams = get_ngrams(3);
    repeatingTrigrams.removeWhere((a) => repeatingTrigrams.count((b) => a.gram == b.gram) == 1);

    for (final trigram in repeatingTrigrams) {
      final repeats = repeatingTrigrams.where((element) => element.gram == trigram.gram && element.startIndex != trigram.startIndex && element.startIndex > trigram.startIndex);

      for (final repeat in repeats) {
        final difference = repeat.startIndex - trigram.startIndex;

        final factors = difference.factors();
        factors.forEach((element) {
          if (seenFactors.containsKey(element)) {
            seenFactors[element]++;
          } else {
            seenFactors[element] = 1;
          }
        });
      }
    }

    // analyze bigrams, but only with a fixed repeat distance
    final repeatingBigrams = get_ngrams(2);
    repeatingBigrams.removeWhere((a) => repeatingBigrams.count((b) => a.gram == b.gram) == 1);

    for (final bigram in repeatingBigrams) {
      final repeats = repeatingBigrams.where((element) => element.gram == bigram.gram && element.startIndex != bigram.startIndex && element.startIndex > bigram.startIndex);

      if (repeats.length <= 1) continue;

      print('checking $bigram with $repeats');

      for (final repeat in repeats) {
        final difference = repeat.startIndex - bigram.startIndex;

        final factors = difference.factors();
        factors.forEach((element) {
          if (seenFactors.containsKey(element)) {
            seenFactors[element]++;
          } else {
            seenFactors[element] = 1;
          }
        });
      }
    }

    // analyze tri repeating letters
    final Map<String, List<int>> letterIndexesOfOccurence = {};
    final flat_cipher = get_flat_cipher();
    for (int i = 0; i < flat_cipher.length; i++) {
      final current_character = flat_cipher.characters.elementAt(i);
      if (['%', r'$', '&', ' ', '-'].contains(current_character)) continue;

      letterIndexesOfOccurence[current_character] ??= [];

      letterIndexesOfOccurence[current_character].add(i);
    }

    letterIndexesOfOccurence.forEach((key, value) {
      final letter = key;

      for (int i = 0; i < value.length - 2; i++) {
        final curIndex = value[i];
        final nextIndex = value[i + 1];
        final nextNextIndex = value[i + 2];

        final curNextDiff = nextIndex - curIndex;
        final nextNextDiff = nextNextIndex - nextIndex;

        if (curNextDiff == nextNextDiff) {
          final factors = curNextDiff.factors();
          factors.forEach((element) {
            if (seenFactors.containsKey(element)) {
              seenFactors[element]++;
            } else {
              seenFactors[element] = 1;
            }
          });
        }
      }
    });

    seenFactors.removeWhere((key, value) => value == 1);

    return seenFactors;
  }

  //////////////////////////////////////////
}
