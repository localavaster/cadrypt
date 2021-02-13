import 'dart:io';

class MagicSquareCribSettings {
  int maximumLength = 0;

  @override
  String toString() {
    return '';
  }

  File get_crib_file() {
    return File('${Directory.current.path}/english_words/5455criblist');
  }

  List<String> get_crib_words() {
    final words = get_crib_file().readAsLinesSync();

    return words;
  }
}
