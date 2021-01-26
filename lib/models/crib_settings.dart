import 'dart:io';

enum CribFileMethod {
  popular,
  mortlach,
  cicada,
}

class CribSettings {
  // 1 = mortlach's
  // 2 = popular wordlist
  // 3 = solved lp wordlist
  CribFileMethod cribMethod = CribFileMethod.popular;
  //
  //

  bool blacklistCipherLetters = false;
  bool blacklistDoubleLetters = false;
  bool includeOneLetterVariations = true;

  // look up the crib shift sequence on OEIS
  bool oeisLookUp = false;

  @override
  String toString() {
    return '=== Crib Settings\n= Crib Method: $cribMethod\n= blacklistCipherLetters: $blacklistCipherLetters\n= blacklistDoubleLetters: $blacklistDoubleLetters';
  }

  File get_crib_file() {
    switch (cribMethod) {
      case CribFileMethod.popular:
        return File('${Directory.current.path}/english_words/popular.txt');

      case CribFileMethod.mortlach:
        return File(
            '${Directory.current.path}/english_words/custom.txt'); // TODO: add this

      case CribFileMethod.cicada:
        return File('${Directory.current.path}/english_words/cicada.txt');

      // ignore: no_default_cases
      default:
        return File(
            '${Directory.current.path}/english_words/popular.txt'); // should never be called but oh well
    }
  }

  List<String> get_crib_words({int minimumLength, int maximumLengthOffset}) {
    final words = get_crib_file().readAsLinesSync();

    words.removeWhere((word) =>
        word.length < minimumLength ||
        word.length > (minimumLength + maximumLengthOffset));

    return words;
  }
}
