import 'package:characters/characters.dart';
import 'package:cicadrypt/constants/libertext.dart';
import 'package:equatable/equatable.dart';

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

    for (int i = 0; i < length; i++) {
      final this_character = gram.rune.characters.elementAt(i);
      final other_character = other.gram.rune.characters.elementAt(i);

      if (this_character != other_character) different++;

      if (different >= threshold) break;
    }

    return different;
  }

  @override
  List<Object> get props => [startIndex, length];
}
