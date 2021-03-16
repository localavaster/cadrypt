import 'package:flutter/foundation.dart';

import '../constants/runes.dart';

enum CipherMode { english, cicada }

class Settings {
  CipherMode cipher_mode = CipherMode.cicada;

  bool is_english_mode() => cipher_mode == CipherMode.english;
  bool is_cicada_mode() => cipher_mode == CipherMode.cicada;

  void switch_to_english_mode() => cipher_mode = CipherMode.english;
  void switch_to_cicada_mode() => cipher_mode = CipherMode.cicada;

  bool is_release_mode() => kReleaseMode;

  List<String> get_alphabet({bool english = false}) {
    if (is_cicada_mode()) {
      if (english == true) {
        return runeEnglish;
      }
      return runes;
    } else {
      return alphabet;
    }
  }
}
