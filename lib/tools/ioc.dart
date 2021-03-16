import 'package:cicadrypt/global/cipher.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

void toolIocAnalysis(BuildContext context) {
  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          // ignore: strict_raw_type
          final best = GetIt.I<Cipher>().find_best_ioc();

          List<int> best_position = [];
          double best_ioc = 0.0;
          best.forEach((key, value) {
            if (value > best_ioc) {
              best_position = key;
              best_ioc = value;
            }
          });

          print('$best_ioc $best_position');

          final average_ioc = GetIt.I<Cipher>().get_index_of_coincidence();
          final test = GetIt.I<Cipher>().get_ioc_history();

          int highest = 0;
          double highest_ioc = 0.0;

          test.forEach((key, value) {
            print('$key | ${value.toStringAsFixed(4)}');

            if (value > highest_ioc) {
              highest = key;
              highest_ioc = value;
            }
          });

          print('peak: $highest $highest_ioc');

          //print('dro')

          final pathKey = GlobalKey<FormFieldState>();
          final pathTextController = TextEditingController();
          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.80;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: List<Widget>.generate(test.keys.length, (index) {
                      final key = test.keys.elementAt(index);
                      final value = test[key];

                      final colorRaw = value.toStringAsFixed(4).allAfter('.').allAfter('0');
                      int color = int.tryParse(colorRaw);

                      if (color == null) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(width: 25, height: 10, color: const Color.fromARGB(255, 255, 127, 255), child: Text(key.toString(), style: const TextStyle(fontSize: 8, color: Colors.black))),
                        );
                      }

                      if (color != 0) {
                        color = color % 255;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(width: 25, height: 10, color: Color.fromARGB(255, color, 127, color), child: Text(key.toString(), style: const TextStyle(fontSize: 8, color: Colors.black))),
                      );
                    }),
                  )),
            ),
          );
        },
      ),
    ),
  );
}
