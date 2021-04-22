import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../global/cipher.dart';
import '../pages/analyze/analyze_state.dart';

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

    default:
      return 'All';
  }
}

Future<void> selectLiberPrimusPageDialog(BuildContext context, Function globalSetState) {
  CurrentPageFilter currentPageFilter = CurrentPageFilter.all;

  final List<String> allPages = [];

  final directorysToSearch = [
    Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/')),
    Directory('${Directory.current.path}/solved_liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/')),
  ];

  for (final directory in directorysToSearch) {
    final files = directory.listSync()..removeWhere((element) => !element.path.endsWith('.txt'));

    files.forEach((element) => allPages.add(element.path));
  }

  List<String> visiblePages = List<String>.from(allPages);

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
                                  color: filter == currentPageFilter ? Colors.cyan.withOpacity(0.22) : Colors.black.withOpacity(0.22),
                                  child: InkWell(
                                    onTap: () => setState(() {
                                      currentPageFilter = filter;

                                      switch (filter) {
                                        case CurrentPageFilter.all:
                                          {
                                            visiblePages = List<String>.from(allPages);
                                          }
                                          break;
                                        case CurrentPageFilter.unsolved:
                                          {
                                            visiblePages = List<String>.from(allPages);
                                            visiblePages.removeWhere((element) => element.contains('solved_liberprimus'));
                                          }
                                          break;
                                        case CurrentPageFilter.solved:
                                          {
                                            visiblePages = List<String>.from(allPages);
                                            visiblePages.removeWhere((element) => !element.contains('solved_liberprimus'));
                                            visiblePages.removeWhere((element) => element.split('/').last.contains('deciphered'));
                                          }
                                          break;
                                        case CurrentPageFilter.deciphered:
                                          {
                                            visiblePages = List<String>.from(allPages);
                                            visiblePages.removeWhere((element) => !element.split('/').last.contains('deciphered'));
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
                      final rawFileList = visiblePages;

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
                                final pagePath = pagesSortedByNum[index];
                                final pageName = pagesSortedByNum[index].split('/').last.replaceAll('.txt', '');

                                return Material(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  child: InkWell(
                                    onTap: () {
                                      globalSetState(() {
                                        final AnalyzeState state = GetIt.I<AnalyzeState>();
                                        state.clear_selected_runes();
                                        state.highlighedRunes.clear();

                                        GetIt.I<Cipher>().load_from_file(pagePath);
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
