import 'dart:io';

import '../constants/libertext.dart';

import '../constants/runes.dart';

class CribChipFilter {
  CribChipFilter({this.text, this.value});

  final String text;
  final String value;
}

final cribFilters = <CribChipFilter>[
  CribChipFilter(text: 'No Plaintext Letters', value: 'noplaintext'), //
  CribChipFilter(text: 'Has Plaintext Letter', value: 'hasplaintext'), //
  CribChipFilter(text: 'Shift In OEIS', value: 'shiftisinoeis'),
  CribChipFilter(text: 'No Vowel Start', value: 'novowelstart'), //
  CribChipFilter(text: 'No Plurals', value: 'noplural'), //
  CribChipFilter(text: 'Only Prime Shifts', value: 'onlyprimeshifts'),
  CribChipFilter(text: 'Only Prime Shift Sums', value: 'onlyprimeshiftsums'),
  CribChipFilter(text: 'Only Prime Word Sums', value: 'onlyprimewordsums'),
  CribChipFilter(text: 'Only Unique Shifts', value: 'onlyunique'), //
  CribChipFilter(text: 'Only Similar Shifts', value: 'onlysimilar'), //
  CribChipFilter(text: 'Only Incrementing Shifts', value: 'onlyincshifts'),
  CribChipFilter(text: 'Only Decrementing Shifts', value: 'onlydecshifts'),
  CribChipFilter(text: 'Only GP Shifts', value: 'onlygpshifts'),
  CribChipFilter(text: 'Only Pure GP Shifts', value: 'onlypuregpshifts'),
  CribChipFilter(text: 'Only Impure GP Shifts', value: 'onlyimpuregpshifts'),
  CribChipFilter(text: 'Only Far Shifts', value: 'onlyfarshifts'),
  CribChipFilter(text: 'Only Close Shifts', value: 'onlycloseshifts'),
  CribChipFilter(text: 'Only Even Shifts', value: 'onlyevenshifts'),
  CribChipFilter(text: 'Only Odd Shifts', value: 'onlyoddshifts'),
  CribChipFilter(text: 'No Zero Shift Differences', value: 'nozeroshiftdifferences'),
  CribChipFilter(text: 'Only words with same GP sum', value: 'onlywordswithsamegpsum')
];

final cribWordFilters = <CribChipFilter>[
  CribChipFilter(text: 'Only Popular Words', value: 'onlypopular'),
  CribChipFilter(text: 'Only Liber Primus words', value: 'onlylp'),
  CribChipFilter(text: 'Only Exact Length', value: 'strictlength'),
  CribChipFilter(text: 'Only Words With Magic Square Sum', value: 'onlymagicsquaresums'),
  CribChipFilter(text: 'Use Crib Cache Homophones', value: 'usecribcachehomophones'),
];

final cribInterruptorFilters = List<CribChipFilter>.generate(runes.length, (index) => CribChipFilter(text: runes[index], value: runes[index]));

final cribOutputSelection = <CribChipFilter>[
  CribChipFilter(text: 'Shift Sum', value: 'shiftsum'),
  CribChipFilter(text: 'Shift Differences Sum', value: 'shiftdifferencessum'),
  CribChipFilter(text: 'Crib Word', value: 'cribword'),
  CribChipFilter(text: 'Shift List', value: 'shiftlist'),
  CribChipFilter(text: 'Shift Differences', value: 'shiftdifferences'),
  CribChipFilter(text: 'Shifts In Word Form', value: 'shiftsinwordform'),
  CribChipFilter(text: 'Shifts In GP Form', value: 'shiftsingpform'),
  CribChipFilter(text: 'Matching Homophones', value: 'matchinghomophones'),
  CribChipFilter(text: 'Shift List Facts', value: 'shiftlistfacts'),
];

enum CribPartOfSpeech { all, noun, verb, adjective, adverb, magic_square_words }

class CribSettings {
  CribPartOfSpeech pos = CribPartOfSpeech.all;

  List<String> filters = [];

  List<String> wordFilters = [];

  List<String> interruptors = [];

  List<String> outputFillers = ['shiftsum', 'shiftlist', 'shiftsinwordform', 'cribword'];

  String outputSortedBy = 'shiftsum';

  String endsWith = '';
  String startsWith = '';
  String pattern = '';

  String shiftMode = 'negative';

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

      case CribPartOfSpeech.magic_square_words:
        return File('${Directory.current.path}/english_words/square_sum_words');

      // ignore: no_default_cases
      default:
        return File('${Directory.current.path}/english_words/all');
    }
  }

  List<String> get_crib_words({String wordBeingCribbed, List<String> onlyIncludeWords}) {
    final words = get_crib_file().readAsLinesSync()..removeWhere((element) => LiberText(element).rune.length != wordBeingCribbed.length);

    if (filters.length == 1 && filters.contains('onlywordswithsamegpsum')) {
      final cipheredWordSum = LiberText(wordBeingCribbed).prime_sum;

      words.removeWhere((word) => LiberText(word).prime_sum != cipheredWordSum);
    }

    if (filters.contains('novowelstart')) {
      words.removeWhere((word) => word.startsWith(RegExp('[aeiouAEIOU]')));
    }

    if (filters.contains('noplural')) {
      // terrible
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

    if (startsWith.isNotEmpty) {
      words.removeWhere((element) => !element.startsWith(startsWith));
    }

    if (endsWith.isNotEmpty) {
      words.removeWhere((element) => !element.endsWith(endsWith));
    }

    if (pattern.isNotEmpty) {
      final regex = RegExp(pattern);

      words.removeWhere((element) => !regex.hasMatch(element));
    }

    if (onlyIncludeWords != null && onlyIncludeWords.isNotEmpty) {
      words.removeWhere((element) => onlyIncludeWords.contains(element) == false);
    }

    return words;
  }
}
