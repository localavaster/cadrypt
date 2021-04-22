import 'dart:io';
import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:collection/collection.dart';
import 'package:string_splitter/string_splitter.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../constants/extensions.dart';
import '../constants/libertext.dart';
import '../constants/runes.dart';
import '../constants/timer.dart';
import '../models/gram.dart';

class Cipher {
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

      final ngramtimer = TimeCode(identifier: 'Parse Repeated nGram');
      cached_ngrams.clear();
      repeated_ngrams = get_repeated_grams();
      ngramtimer.stop_print();

      final similarngramtimer = TimeCode(identifier: 'Parse Similar nGram');
      similar_ngrams = get_similar_grams();
      similarngramtimer.stop_print();

      t1.stop_print();

      current_cipher_file = path;
    } on Exception catch (e) {
      return false;
    }

    return true;
  }

  bool load_from_text(String text) {
    try {
      final List<String> parsed = [];
      final List<String> unparsed = text.split('\n');

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
    final sortedRowLengths = List<int>.generate(raw_cipher.length, (index) => raw_cipher[index].length).toList().sorted((a, b) => b.compareTo(a));

    return sortedRowLengths.first;
  }

  String get_flat_cipher() {
    return raw_cipher.join().replaceAll('-', '').replaceAll(r'\', '').replaceAll(' ', '').replaceAll('.', '').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '');
  }

  List<String> get_cipher_words() {
    return raw_cipher.join().replaceAll(r'\', '').replaceAll(' ', '-').replaceAll('.', '-').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '').split('-');
  }

  Map<LiberTextClass, int> get_character_frequencies() {
    final Map<LiberTextClass, int> seen = {};

    for (final character in raw_cipher.join().characters) {
      if (!runes.contains(character) && !alphabet.contains(character) && !numbers.contains(character)) continue;

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
    final matches = regex.allMatches(raw_cipher.join());

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

  double get_index_of_coincidence({String text}) {
    String flatCipher = get_flat_cipher();
    if (text != null) {
      flatCipher = text.replaceAll(RegExp('[^${runes.join()}]'), '');
    }
    flatCipher = flatCipher.replaceAll(RegExp(r'\d'), '');

    final length = flatCipher.length;

    final chunkedCipher = flatCipher.split('');
    final lettersInCipher = chunkedCipher.toSet();
    final frequencies = {for (final letter in lettersInCipher) letter: chunkedCipher.count((e) => e == letter)}; // fastest frequency counter in the west

    final frequencySum = runes.sumByDouble((s) => frequencies.containsKey(s) ? frequencies[s] * (frequencies[s] - 1) : 0.0);

    if (frequencySum == 0.0) return 0.0;

    return frequencySum / (length * (length - 1));
  }

  double get_entropy() {
    final occurences = get_character_frequencies().values.toList();
    final total = occurences.sum;
    double sum = 0.0;

    for (final occurence in occurences) {
      sum += occurence / total * math.log(total / occurence);
    }

    return sum;
  }

  double get_average_letter_distance() {
    final flatCipher = get_flat_cipher();

    final List<int> distances = [];

    for (int i = 0; i < flatCipher.length - 1; i++) {
      final currentCharacter = flatCipher.characters.elementAt(i);
      final nextCharacter = flatCipher.characters.elementAt(i + 1);

      final currentCharacterIdx = runes.indexOf(currentCharacter);
      final nextCharacterIdx = runes.indexOf(nextCharacter);

      distances.add((currentCharacterIdx - nextCharacterIdx).abs());
    }

    return distances.average;
  }

  double get_average_distance_until_letter_repeat() {
    // first, iterate the entire text
    final flatCipher = get_flat_cipher();

    final letterSeenIndexes = <String, List<int>>{};

    flatCipher.characters.forEachIndexed((index, rune) {
      letterSeenIndexes[rune] ??= [];

      letterSeenIndexes[rune].add(index);
    });

    final List<int> distances = [];

    for (final seenIndexes in letterSeenIndexes.values) {
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
    final flatCipher = get_flat_cipher();

    final letterSeenIndexes = <String, List<int>>{};

    flatCipher.characters.forEachIndexed((index, rune) {
      if (doubleRunes.contains(rune)) {
        letterSeenIndexes[rune] ??= [];

        letterSeenIndexes[rune].add(index);
      }
    });

    final List<int> distances = [];

    for (final seenIndexes in letterSeenIndexes.values) {
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

    if (distances == null || distances.isEmpty || distances.average == null) return 0.0;

    return distances.average;
  }

  double get_average_distance_until_rune_repeat(String runeToFind) {
    // first, iterate the entire text
    final flatCipher = get_flat_cipher();

    final letterSeenIndexes = <String, List<int>>{};

    flatCipher.characters.forEachIndexed((index, rune) {
      if (rune == runeToFind) {
        letterSeenIndexes[rune] ??= [];

        letterSeenIndexes[rune].add(index);
      }
    });

    final List<int> distances = [];

    for (final seenIndexes in letterSeenIndexes.values) {
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

    if (distances == null || distances.isEmpty || distances.average == null) return 0.0;

    return distances.average;
  }

  // useful for bigram substitution and such, shows how much of the text is unique bigrams, a low value could mean a bigram cipher
  // mono substitution is around 0.30 for a gramsize of 2
  double gram_ratio(int gramSize) {
    final flatCipher = get_flat_cipher().replaceAll(RegExp('[^${runes.join()}]'), '');
    final amountOfBigramsInText = flatCipher.length / gramSize;
    final bigrams = <String>[];

    for (int i = 0; i < flatCipher.length; i = i + gramSize) {
      try {
        final bigram = flatCipher.substring(i, (i + gramSize).clamp(0, flatCipher.length).toInt());
        if (bigram.length != gramSize) continue;
        if (!bigrams.contains(bigram)) bigrams.add(bigram);
      } catch (e) {
        continue;
      }
    }
    return bigrams.length / amountOfBigramsInText;
  }

  // aka where the most grams are repeated
  List<dynamic> get_gram_ratio_peak(int gramSize) {
    final chunkSizes = <int>[32, 64, 96, 128, 192, 256, 320];
    final flatCipher = get_flat_cipher().replaceAll(RegExp('[^${runes.join()}]'), '');

    if (flatCipher.isEmpty) return [];

    // save our results
    final List<List<dynamic>> results = [];

    // split it into chunks

    for (final chunk_size in chunkSizes) {
      for (int i = 0; i < flatCipher.length - chunk_size; i++) {
        final cipherChunk = flatCipher.substring(i, i + chunk_size);
        final amountOfBigramsInText = cipherChunk.length / gramSize;
        final bigrams = <String>[];

        for (int i = 0; i < cipherChunk.length; i = i + gramSize) {
          try {
            final bigram = cipherChunk.substring(i, (i + gramSize).clamp(0, cipherChunk.length).toInt());
            if (bigram.length != gramSize) continue;
            if (!bigrams.contains(bigram)) bigrams.add(bigram);
          } catch (e) {
            continue;
          }
        }

        results.add([(bigrams.length / amountOfBigramsInText).toStringAsFixed(2), i.toDouble(), (i + chunk_size).toDouble()]);
      }
    }

    return results.sortedBy<num>((element) => double.parse(element.first.toString())).first;
  }

  // aka where the least grams are repeated
  List<double> get_gram_ratio_low(int gramSize) {
    final chunkSizes = <int>[32, 64, 96, 128, 192, 256, 320];
    final flatCipher = get_flat_cipher().replaceAll(RegExp('[^${runes.join()}]'), '');

    if (flatCipher.isEmpty) return [];

    // save our results
    final List<List<double>> results = [];

    // split it into chunks

    for (final chunk_size in chunkSizes) {
      for (int i = 0; i < flatCipher.length - chunk_size; i++) {
        final cipherChunk = flatCipher.substring(i, i + chunk_size);
        final amountOfBigramsInText = cipherChunk.length / gramSize;
        final bigrams = <String>[];

        for (int i = 0; i < cipherChunk.length; i = i + gramSize) {
          try {
            final bigram = cipherChunk.substring(i, i + gramSize);
            if (bigram.length != gramSize) continue;
            if (!bigrams.contains(bigram)) bigrams.add(bigram);
          } catch (e) {
            continue;
          }
        }

        results.add([bigrams.length / amountOfBigramsInText, i.toDouble(), (i + chunk_size).toDouble()]);
      }
    }

    return results.sortedBy<num>((element) => element.first).last;
  }

  double get_gp_sum_ratio() {
    final cipherWords = get_cipher_words();
    final uniqueSums = <int>[];

    for (final word in cipherWords) {
      final sum = LiberText(word).prime.sum;
      if (uniqueSums.contains(sum)) continue;

      uniqueSums.add(sum);
    }

    return uniqueSums.length / cipherWords.length;
  }

  double get_normalized_bigram_repeats() {
    // not dry
    final bigrams = get_ngrams(2);
    final repeatedBigrams = <LiberTextClass, int>{};
    for (final bigram in bigrams) {
      final count = bigrams.count((string) => string == bigram);
      if (count <= 1) continue;

      if (!repeatedBigrams.containsKey(bigram)) {
        repeatedBigrams[bigram.gram] = count;
      }
    }

    final int sumOfBigramOccurences = repeatedBigrams.values.sum;
    final int patternCharacterOccurences = (sumOfBigramOccurences * 2).toInt();

    if (cipher_length == 0 || patternCharacterOccurences == 0) return 0.0;

    return patternCharacterOccurences / cipher_length;
  }

  Map<int, List<NGram>> cached_ngrams = {};

  List<NGram> get_ngrams(int n, {String text}) {
    if (cached_ngrams.containsKey(n)) return cached_ngrams[n];

    final flatCipher = text ?? get_flat_cipher();

    final List<NGram> result = [];
    for (int i = 0; i < flatCipher.length; i += 1) {
      final gram = flatCipher.substring(i, (i + n).clamp(0, flatCipher.length).toInt());
      if (gram.length != n) continue;

      result.add(NGram(startIndex: i, gram: LiberText(gram)));
    }

    cached_ngrams[n] = result;
    return result;
  }

  Map<NGram, int> get_repeated_ngrams(int n, {String text}) {
    final ngrams = get_ngrams(n, text: text);

    final Map<NGram, int> repeated = {};

    for (final gram in ngrams) {
      final count = ngrams.count((string) => string.gram == gram.gram);

      if (count == 1) continue;

      if (!repeated.containsKey(gram)) {
        repeated[gram] = count;
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

    for (int gramsize = 3; gramsize < 6; gramsize++) {
      final allGrams = get_ngrams(gramsize);
      final repeatedGrams = get_repeated_ngrams(gramsize).keys.toList();
      final similarityThreshold = (gramsize * 0.34).floor();

      if (repeatedGrams.isEmpty) {
        print('repeated_grams is empty');
        for (final gram in allGrams) {
          final similarGrams = allGrams.where((_gram) => _gram != gram && gram.length == _gram.length && gram.similarity(_gram, threshold: similarityThreshold + 1) <= similarityThreshold).toList();

          if (similarGrams.length <= 1) continue;

          if (gramsize == 3 && similarGrams.length <= 2) continue;

          if (repeated.keys.where((element) => element.gram == gram.gram).isEmpty) {
            repeated[gram] = similarGrams;
          }
        }
      } else {
        print('repeated_grams is not empty');
        for (final gram in repeatedGrams) {
          final similarGrams = allGrams.where((_gram) => _gram != gram && gram.length == _gram.length && gram.similarity(_gram, threshold: similarityThreshold + 1) <= similarityThreshold).toList();

          if (similarGrams.length <= 1) continue;

          if (gramsize == 3 && similarGrams.length <= 2) continue;

          if (repeated.keys.where((element) => element.gram == gram.gram).isEmpty) {
            repeated[gram] = similarGrams;
          }
        }
      }
    }

    return repeated;
  }

  List<String> get_characters_not_used() {
    final characters = List<String>.from(runes)..removeWhere((element) => raw_cipher.join('').contains(element));

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

    final cipherWords = get_cipher_words().sortedBy<num>((element) => element.length);

    final groupedCipherWords = <int, StringBuffer>{};

    for (final word in cipherWords) {
      groupedCipherWords[word.length] ??= StringBuffer();

      groupedCipherWords[word.length].write(word);
    }

    for (final length in groupedCipherWords.keys) {
      final ioc = get_index_of_coincidence(text: groupedCipherWords[length].toString());

      periodicIoCs[length] = ioc;
    }

    return periodicIoCs;
  }

  Map<int, double> get_ioc_history() {
    final Map<int, double> history = {};

    final flatCipher = get_flat_cipher();

    for (int i = 0; i < flatCipher.length; i++) {
      final subFlatCipher = flatCipher.substring(0, i);

      final ioc = get_index_of_coincidence(text: subFlatCipher);

      history[i] = ioc;
    }

    return history;
  }

  Map<List<int>, double> find_best_ioc() {
    final Map<List<int>, double> history = {};

    final flatCipher = get_flat_cipher();

    for (int s = 0; s < flatCipher.length; s++) {
      for (int e = s; e < flatCipher.length; e++) {
        final subFlatCipher = flatCipher.substring(s, e);

        if (subFlatCipher.length <= 20) continue;

        final ioc = get_index_of_coincidence(text: subFlatCipher);

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
    final flatCipher = get_flat_cipher();
    for (int i = 0; i < flatCipher.length; i++) {
      final currentCharacter = flatCipher.characters.elementAt(i);
      if (['%', r'$', '&', ' ', '-'].contains(currentCharacter)) continue;

      letterIndexesOfOccurence[currentCharacter] ??= [];

      letterIndexesOfOccurence[currentCharacter].add(i);
    }

    letterIndexesOfOccurence.forEach((key, value) {
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
  // experimental

}
