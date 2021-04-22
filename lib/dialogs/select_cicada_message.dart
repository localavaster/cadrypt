import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../global/cipher.dart';
import '../pages/analyze/analyze_state.dart';

Future<void> selectCicadaMessage(BuildContext context, Function globalSetState) {
  return showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width * 0.30;
          final height = MediaQuery.of(context).size.height * 0.80;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Messages from Cicada'),
                    Builder(builder: (_) {
                      final basePath = Directory('${Directory.current.path}/cicada_messages/'.replaceAll(RegExp(r'[\/]'), '/'));

                      final rawFileList = basePath.listSync();

                      List<String> pagesSortedByNum;

                      try {
                        final pages = List<String>.generate(rawFileList.length, (index) => rawFileList[index].path.split('/').last).sortedBy<String>((element) => element);
                        pages.removeWhere((element) => !element.endsWith('.txt'));

                        final numberRegex = RegExp('[^0-9]');

                        pagesSortedByNum = pages.sortedBy<num>((element) {
                          return int.parse(element.replaceAll(numberRegex, ''));
                        });
                      } catch (e) {
                        print(e);
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Material(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: ListView.builder(
                              itemCount: pagesSortedByNum.length,
                              itemBuilder: (context, index) {
                                final rawPageName = pagesSortedByNum[index];
                                final pageName = pagesSortedByNum[index].replaceAll('.txt', '');

                                return Material(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  child: InkWell(
                                    onTap: () {
                                      print('loading ${basePath.path + rawPageName}');
                                      globalSetState(() {
                                        final AnalyzeState state = GetIt.I<AnalyzeState>();
                                        state.clear_selected_runes();
                                        state.highlighedRunes.clear();

                                        GetIt.I<Cipher>().load_from_file(basePath.path + rawPageName);
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [Text(pageName), const Icon(Icons.arrow_right)],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
