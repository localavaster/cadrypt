import 'package:flutter/material.dart';

class RuneGrid extends CustomPainter {
  RuneGrid({this.crossAxisCount, this.blocSize, this.blocs});

  final double gap = 1;
  final Paint painter = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  final int crossAxisCount;
  final double blocSize;
  final List<String> blocs;

  static const textStyle = TextStyle(
    fontFamily: 'SegoeUISymbol',
    color: Colors.white,
    fontSize: 12,
  );

  @override
  void paint(Canvas canvas, Size size) {
    blocs.asMap().forEach(
      (index, bloc) {
        final left = getLeft(index);
        final top = getTop(index);

        setColor(bloc);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left,
              top,
              blocSize - gap,
              blocSize - gap,
            ),
            const Radius.circular(0),
          ),
          painter,
        );

        if (!isSpecialCharacter(bloc)) {
          final textSpan = TextSpan(
            text: bloc,
            style: textStyle,
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(
            minWidth: 0,
            maxWidth: size.width,
          );
          final offset = Offset(left + 4, top - 2);
          textPainter.paint(canvas, offset);
        }
      },
    );
  }

  double getTop(int index) {
    return (index / crossAxisCount).floor().toDouble() * blocSize;
  }

  double getLeft(int index) {
    return (index % crossAxisCount).floor().toDouble() * blocSize;
  }

  @override
  bool shouldRepaint(RuneGrid oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(RuneGrid oldDelegate) => true;

  bool isSpecialCharacter(String character) => ['%', r'$', '&'].contains(character);

  void setColor(String character) {
    if (isSpecialCharacter(character)) {
      painter.color = Colors.black.withOpacity(0.165);
    } else {
      painter.color = Colors.black45;
    }

    return;
  }
}
