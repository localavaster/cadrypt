import 'dart:io';

import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/pages/analyze/analyze_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:collection/collection.dart';

enum CurrentPageFilter {
  all,
  unsolved,
  solved,
  deciphered,
}

String pageFilterToString(CurrentPageFilter filter) {
  switch (filter) {
    case CurrentPageFilter.all:
      return 'All';
    case CurrentPageFilter.unsolved:
      return 'Unsolved';
    case CurrentPageFilter.solved:
      return 'Solved';
    case CurrentPageFilter.deciphered:
      return 'Plaintext';
  }
}

Future<void> selectLiberPrimusPageDialog(BuildContext context, Function globalSetState) {
  CurrentPageFilter current_page_filter = CurrentPageFilter.all;

  List<String> all_pages = [];

  final directorys_to_search = [
    Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/')),
    Directory('${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/')),
  ];

  for (final directory in directorys_to_search) {
    final files = directory.listSync()..removeWhere((element) => !element.path.endsWith('.txt'));

    files.forEach((element) => all_pages.add(element.path));
  }

  List<String> visible_pages = List<String>.from(all_pages);

  return showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
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
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Liber Primus Pages'),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 26,
                        child: Row(
                          children: List<Widget>.generate(4, (index) {
                            final filter = CurrentPageFilter.values[index];
                            return Expanded(
                              child: Container(
                                height: 26,
                                width: double.infinity,
                                child: Material(
                                  color: filter == current_page_filter ? Colors.cyan.withOpacity(0.22) : Colors.black.withOpacity(0.22),
                                  child: InkWell(
                                    onTap: () => setState(() {
                                      current_page_filter = filter;

                                      switch (filter) {
                                        case CurrentPageFilter.all:
                                          {
                                            visible_pages = List<String>.from(all_pages);
                                          }
                                          break;
                                        case CurrentPageFilter.unsolved:
                                          {
                                            visible_pages = List<String>.from(all_pages);
                                            visible_pages.removeWhere((element) => element.contains('solved_liberprimus'));
                                          }
                                          break;
                                        case CurrentPageFilter.solved:
                                          {
                                            visible_pages = List<String>.from(all_pages);
                                            visible_pages.removeWhere((element) => !element.contains('solved_liberprimus'));
                                            visible_pages.removeWhere((element) => element.split('/').last.contains('deciphered'));
                                          }
                                          break;
                                        case CurrentPageFilter.deciphered:
                                          {
                                            visible_pages = List<String>.from(all_pages);
                                            visible_pages.removeWhere((element) => !element.split('/').last.contains('deciphered'));
                                          }
                                          break;
                                      }
                                    }),
                                    child: Center(
                                      child: Text(pageFilterToString(filter)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Builder(builder: (_) {
                      final rawFileList = visible_pages;

                      List<String> pagesSortedByNum;

                      try {
                        final pages = List<String>.generate(rawFileList.length, (index) => rawFileList[index]).sortedBy<String>((element) => element);
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
                          padding: const EdgeInsets.all(4),
                          child: Material(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: ListView.builder(
                              itemCount: pagesSortedByNum.length,
                              itemBuilder: (context, index) {
                                final page_path = pagesSortedByNum[index];
                                final page_name = pagesSortedByNum[index].split('/').last.replaceAll('.txt', '');

                                return Material(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  child: InkWell(
                                    onTap: () {
                                      globalSetState(() {
                                        final AnalyzeState state = GetIt.I<AnalyzeState>();
                                        state.clear_selected_runes();
                                        state.highlighedRunes.clear();

                                        GetIt.I<Cipher>().load_from_file(page_path);
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [Text(page_name), const Icon(Icons.arrow_right)],
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
                            padding: const EdgeInsets.all(4.0),
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
