import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../constants/runes.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import 'package:equatable/equatable.dart';

class CribMatch extends Equatable {
  final String rune_word;
  final String crib;
  final List<int> shifts;
  final String shift_word;
  String shift_word_using_gp;
  final String shift_rune_word;
  final int shift_sum;

  CribMatch(this.rune_word, this.crib, this.shifts)
      : shift_sum = shifts.sum(),
        shift_word = List<String>.generate(shifts.length, (index) => runeEnglish[shifts[index]].toUpperCase()).join(),
        shift_rune_word = List<String>.generate(shifts.length, (index) => runes[shifts[index]]).join() {
    final buffer = StringBuffer();

    for (final shift in shifts) {
      final letters = <String>[];

      for (int idx = 0; idx < gpPrimesMod29.length; idx++) {
        final value = gpPrimesMod29[idx];

        if (value == shift) {
          letters.add(runeEnglish[idx]);
        }
      }

      if (letters.isEmpty) {
        buffer.write('?${runeEnglish[shift]}?');
      } else if (letters.length == 1) {
        buffer.write(letters.first);
      } else if (letters.length != 1) {
        buffer.write('(${letters.join()})');
      }
    }

    shift_word_using_gp = buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.writeAll(['$shift_sum', ' | ', crib, ' | ', '$shifts', ' | ', '$shift_word', ' | ', '$shift_word_using_gp']);

    return buffer.toString();
  }

  // equality props
  @override
  List<Object> get props => [rune_word, shifts, shift_word];
}
