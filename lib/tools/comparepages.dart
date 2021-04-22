import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/runes.dart';

String get_page_name_from_path(String path) {
  return path.replaceAll(r'\', '/').split('/').last;
}

void toolComparePages(BuildContext context) {
  // select two pages
  final pageDirectories = <String>[
    '${Directory.current.path}/liberprimus_pages/',
    '${Directory.current.path}/solved_liberprimus_pages/',
  ];

  final pages = <File>[];

  for (final directory in pageDirectories) {
    final dir = Directory(directory);

    for (final file in dir.listSync()) {
      if (!file.path.endsWith('.txt')) continue;

      pages.add(File(file.path));
    }
  }

  File selectedPageA = pages.first;
  File selectedPageB = pages.last;

  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.50;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Theme.of(context).cardColor,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<File>(
                            value: selectedPageA,
                            onChanged: (selection) {
                              setState(() {
                                selectedPageA = selection;
                              });
                            },
                            items: List<DropdownMenuItem<File>>.generate(
                              pages.length,
                              (index) => DropdownMenuItem(
                                value: pages[index],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(get_page_name_from_path(pages[index].path)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.compare_arrows_sharp, color: Colors.white.withOpacity(0.88))]),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Theme.of(context).cardColor,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<File>(
                            value: selectedPageB,
                            onChanged: (selection) {
                              setState(() {
                                selectedPageB = selection;
                              });
                            },
                            items: List<DropdownMenuItem<File>>.generate(
                              pages.length,
                              (index) => DropdownMenuItem(
                                value: pages[index],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(get_page_name_from_path(pages[index].path)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            final sharedTrigrams = <dynamic>{};

                            final aFlat = selectedPageA.readAsStringSync().replaceAll(RegExp('[^${runes.join()}]'), '');
                            final bFlat = selectedPageB.readAsStringSync().replaceAll(RegExp('[^${runes.join()}]'), '');

                            for (int gramSize = 4; gramSize < 10; gramSize++) {
                              for (int i = 0; i < aFlat.length; i++) {
                                final gram = aFlat.substring(i, (i + gramSize).clamp(0, aFlat.length).toInt());

                                if (gram.length != gramSize) continue;

                                if (bFlat.contains(gram)) sharedTrigrams.add(gram);
                              }
                            }

                            print('Shared Grams (${sharedTrigrams.length})');
                            print(sharedTrigrams);
                          },
                          child: const Text('COMPARE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  // now time for the comparison

  // shared trigrams

  //
}
