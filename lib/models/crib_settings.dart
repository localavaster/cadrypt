import 'dart:io';

import 'package:cicadrypt/constants/runes.dart';

class CribChipFilter {
  final String text;
  final String value;
  CribChipFilter({this.text, this.value});
}

final cribFilters = <CribChipFilter>[
  CribChipFilter(text: 'No Plaintext Letters', value: 'noplaintext'), //
  CribChipFilter(text: 'Has Plaintext Letter', value: 'hasplaintext'), //
  CribChipFilter(text: 'Shift In OEIS', value: 'shiftisinoeis'),
  CribChipFilter(text: 'No Vowel Start', value: 'novowelstart'), //
  CribChipFilter(text: 'No Plurals', value: 'noplural'), //
  CribChipFilter(text: 'No Uncommon Shifts', value: 'nouncommonshifts'),
  CribChipFilter(text: 'No Double Letters In Word', value: 'nodoubleletters'),
  CribChipFilter(text: 'Only Prime Shifts', value: 'onlyprimeshifts'),
  CribChipFilter(text: 'Only Totient Prime Shifts', value: 'onlytotprimeshifts'),
  CribChipFilter(text: 'Only Unique Shifts', value: 'onlyunique'), //
  CribChipFilter(text: 'Only Similar Shifts', value: 'onlysimilar'), //
  CribChipFilter(text: 'Only Incrementing Shifts', value: 'onlyincshifts'),
  CribChipFilter(text: 'Only Decrementing Shifts', value: 'onlydecshifts'),
  CribChipFilter(text: 'Only GP Shifts', value: 'onlygpshifts'),
  CribChipFilter(text: 'Only Pure GP Shifts', value: 'onlypuregpshifts'),
  CribChipFilter(text: 'Only Impure GP Shifts', value: 'onlyimpuregpshifts'),
];

final cribWordFilters = <CribChipFilter>[
  CribChipFilter(text: 'Only Popular Words', value: 'onlypopular'),
  CribChipFilter(text: 'Only Liber Primus words', value: 'onlylp'),
  CribChipFilter(text: 'Only Exact Length', value: 'strictlength'),
  CribChipFilter(text: 'Only Words With Magic Square Sum', value: 'onlymagicsquaresums'),
];

final cribInterruptorFilters = List<CribChipFilter>.generate(runes.length, (index) => CribChipFilter(text: runes[index], value: runes[index]));

enum CribPartOfSpeech { all, noun, verb, adjective, adverb }

class CribSettings {
  CribPartOfSpeech pos = CribPartOfSpeech.all;

  List<String> filters = [];

  List<String> wordFilters = [];

  List<String> interruptors = [];

  @override
  String toString() {
    return '=== Crib Settings';
  }

  File get_crib_file() {
    switch (pos) {
      case CribPartOfSpeech.all:
        return File('${Directory.current.path}/english_words/all');

      case CribPartOfSpeech.noun:
        return File('${Directory.current.path}/english_words/nouns');

      case CribPartOfSpeech.verb:
        return File('${Directory.current.path}/english_words/verbs');

      case CribPartOfSpeech.adjective:
        return File('${Directory.current.path}/english_words/adjectives');

      case CribPartOfSpeech.adverb:
        return File('${Directory.current.path}/english_words/adverbs');

      default:
        return File('${Directory.current.path}/english_words/all');
    }
  }

  List<String> get_crib_words({int minimumLength, int maximumLengthOffset}) {
    final words = get_crib_file().readAsLinesSync();

    words.removeWhere((word) => word.length < minimumLength - 1 || word.length > (minimumLength + maximumLengthOffset));

    if (filters.contains('novowelstart')) {
      words.removeWhere((word) => word.startsWith(RegExp('[aeiouAEIOU]')));
    }

    if (filters.contains('noplural')) {
      words.removeWhere((word) => word.endsWith('s'));
    }

    if (wordFilters.contains('onlylp')) {
      final liberPrimusWords = File('${Directory.current.path}/english_words/cicada').readAsLinesSync();

      words.removeWhere((element) => !liberPrimusWords.contains(element.toLowerCase()));
    }

    if (wordFilters.contains('onlypopular')) {
      final popularWords = File('${Directory.current.path}/english_words/popular').readAsLinesSync();

      words.removeWhere((element) => !popularWords.contains(element.toLowerCase()));
    }

    return words;
  }
}
