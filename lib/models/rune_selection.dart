import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RuneSelection extends Equatable {
  const RuneSelection(this.index, this.rune, this.type, {this.color = null});

  final String rune;
  final int index;
  final String type; // mouse, highlighter, etc
  final Color color;

  @override
  List<Object> get props => [index];

  Color get_highlighted_color(BuildContext context) {
    if (color != null) {
      return color.withOpacity(0.66);
    }

    switch (type) {
      case 'mouse':
        return Colors.cyan.withOpacity(0.33);
      case 'mousedoubleclick':
        return Colors.cyan.withOpacity(0.33);
      case 'highlighter':
        return Colors.red.withOpacity(0.10);
      case 'gramhighlighter':
        return Colors.red.withOpacity(0.10);

      default:
        return Colors.black.withOpacity(0.66);
    }
  }
}
