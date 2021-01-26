import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../constants/runes.dart';
import '../global/cipher.dart';
import '../models/rune_selection.dart';
import '../pages/analyze/analyze_state.dart';

class RuneContainer extends StatefulWidget {
  RuneContainer(this.state, this.index, this.rune, {Key key}) : super(key: key);

  final AnalyzeState state;
  final int index;
  final String rune;

  @override
  _RuneContainerState createState() => _RuneContainerState();
}

class _RuneContainerState extends State<RuneContainer> {
  String get_letter() {
    switch (widget.state.readingMode) {
      case 'rune':
        {
          return widget.rune;
        }
        break;
      case 'english':
        {
          if (runeToEnglish.containsKey(widget.rune)) {
            return runeToEnglish[widget.rune];
          } else {
            return widget.rune;
          }
        }
        break;
      case 'value':
        {
          if (runeToValue.containsKey(widget.rune)) {
            return runeToValue[widget.rune];
          } else {
            return widget.rune;
          }
        }
        break;
      case 'prime':
        {
          if (runeToPrime.containsKey(widget.rune)) {
            return runeToPrime[widget.rune];
          } else {
            return widget.rune;
          }
        }
        break;
      case 'index':
        {
          return widget.index.toString();
        }
        break;

      default:
        {
          return widget.rune;
        }
    }
  }

  double get_font_size() {
    //return 10;
    if (widget.state.readingMode == 'rune') {
      return 14;
    } else {
      switch (get_letter().length) {
        case 1:
          return 14;
        case 2:
          return 13;
        case 3:
          return 11;

        default:
          return 12;
      }
    }
  }

  Color get_color(BuildContext context) {
    if (widget.state.readingMode == 'color') {
      try {
        final index = runeToEnglish.keys.toList().indexOf(widget.rune);
        if (index == -1) {
          return const Color.fromARGB(255, 0, 0, 0);
        }
        final colorCodeR = ((index + 1) * 29) % 240;
        final colorCodeG = ((index + 1) * 29) % 180;
        final colorCodeB = ((index + 1) * 29) % 140;

        return Color.fromARGB(255, colorCodeR, colorCodeG, colorCodeB);
      } catch (e) {
        return const Color.fromARGB(255, 0, 0, 0);
      }
    }

    final runeComparison = RuneSelection(widget.index, widget.rune, '');
    final selectedRunes = List<String>.generate(widget.state.selectedRunes.length, (index) => widget.state.selectedRunes[index].rune);

    if (widget.state.selectedRunes.contains(runeComparison)) {
      return widget.state.selectedRunes.where((element) => element == runeComparison).first.get_highlighted_color(context);
    }

    if (widget.state.highlighedRunes.contains(runeComparison)) {
      return widget.state.highlighedRunes.where((element) => element.index == widget.index).first.get_highlighted_color(context);
    }

    return Colors.black.withOpacity(0.495);
  }

  bool shouldShowText() {
    return widget.state.readingMode != 'color';
  }

  Widget _buildRuneContainer() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {},
      onExit: (event) {},
      child: GestureDetector(
        onTap: () {
          widget.state.select_rune(widget.rune, widget.index, 'mouse');
        },
        onDoubleTap: () {
          widget.state.highlight_all_instances_of_rune(widget.rune);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).cardColor, width: 0.5),
            color: get_color(context),
          ),
          child: Center(
            child: AutoSizeText(
              get_letter(),
              maxLines: 1,
              minFontSize: 8,
              style: TextStyle(
                //fontSize: get_font_size(),
                //height: 1.0,
                color: shouldShowText() == true ? Colors.white : Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialRuneContainer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.state.clear_selected_runes();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).cardColor, width: 0.5),
          color: Colors.black.withOpacity(0.165),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      final bool isSpecialGridCell = [
        '%',
        '&',
        r'$',
      ].contains(widget.rune);

      if (isSpecialGridCell) {
        return _buildSpecialRuneContainer(context);
      }

      return _buildRuneContainer();
    });
  }
}
