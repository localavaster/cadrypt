import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RuneSelection extends Equatable {
  final String rune;
  final int index;
  final String type; // mouse, highlighter, etc

  const RuneSelection(this.index, this.rune, this.type);

  @override
  List<Object> get props => [index];

  Color get_highlighted_color(BuildContext context) {
    switch (type) {
      case 'mouse':
        return Colors.cyan.withOpacity(0.33);
      case 'mousedoubleclick':
        return Colors.cyan.withOpacity(0.33);
      case 'highlighter':
        return Colors.red.withOpacity(0.33);
      case 'gramhighlighter':
        return Colors.red.withOpacity(0.33);

      default:
        return Theme.of(context).scaffoldBackgroundColor;
    }
  }
}
