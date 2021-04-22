import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';

import '../constants/libertext.dart';

class NGram extends Equatable {
  NGram({this.startIndex, this.gram}) : length = gram.rune.length;

  final int startIndex;
  final LiberTextClass gram;
  final int length;

  @override
  String toString() {
    return 'NGram($startIndex, $gram, $length)';
  }

  // simple similarity check
  // returns how many characters are not the same
  int similarity(NGram other, {int threshold}) {
    int different = 0;

    if (other.gram.rune.split('').reversed.toList().join() == gram.rune) return different;

    for (int i = 0; i < length; i++) {
      try {
        final thisCharacter = gram.rune.characters.elementAt(i);
        final otherCharacter = other.gram.rune.characters.elementAt(i);

        if (thisCharacter != otherCharacter) different++;

        if (different >= threshold) break;
      } catch (e) {
        print('NGram->similarity: $e\n${gram.rune}\n${other.gram.rune}');
      }
    }

    return different;
  }

  @override
  List<Object> get props => [startIndex, length];
}
