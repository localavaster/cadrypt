import 'dart:io';

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

      // ignore: no_default_cases
      default:
        return File('${Directory.current.path}/english_words/all');
    }
  }

  List<String> get_crib_words({int minimumLength, int maximumLengthOffset}) {
    final words = get_crib_file().readAsLinesSync();

    return words;
  }
}
