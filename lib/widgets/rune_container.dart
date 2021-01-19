import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
    final runeComparison = RuneSelection(widget.index, widget.rune, '');
    final selectedRunes = List<String>.generate(widget.state.selectedRunes.length, (index) => widget.state.selectedRunes[index].rune);

    if (widget.state.selectedRunes.contains(runeComparison)) {
      return widget.state.selectedRunes.where((element) => element == runeComparison).first.get_highlighted_color(context);
    }

    if (widget.state.highlighedRunes.contains(runeComparison)) {
      return widget.state.highlighedRunes.where((element) => element.index == widget.index).first.get_highlighted_color(context);
    }

    return Theme.of(context).scaffoldBackgroundColor;
  }

  Widget _buildRuneContainer() {
    return Material(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).cardColor, width: 0.5),
      ),
      color: get_color(context),
      child: InkWell(
        onTap: () {
          print(widget.index);
          widget.state.select_rune(widget.rune, widget.index, 'mouse');
          print('== ${widget.state.selectedRunes}');
        },
        onDoubleTap: () {
          widget.state.highlight_all_instances_of_rune(widget.rune);
        },
        child: Center(
          child: AutoSizeText(
            get_letter(),
            maxLines: 1,
            minFontSize: 8,
            style: TextStyle(
                //fontSize: get_font_size(),
                //height: 1.0,
                color: widget.index < GetIt.instance<Cipher>().header_size ? Colors.red : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialRuneContainer() {
    return Material(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).cardColor, width: 0.5),
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      final bool isSpecialGridCell = ['%'].contains(widget.rune);

      if (isSpecialGridCell) {
        return _buildSpecialRuneContainer();
      }

      return _buildRuneContainer();
    });
  }
}
