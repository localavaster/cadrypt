import 'dart:io';

enum MagicSquareCribOutputSorting {
  prime,
  length,
}

class CribChipFilter {
  CribChipFilter({this.text, this.value});

  final String text;
  final String value;
}

final cribFilters = <CribChipFilter>[
  CribChipFilter(text: 'Same Prime and Index', value: 'sameprimeandindex'), //
];

class MagicSquareCribSettings {
  int maximumLength = 0;

  MagicSquareCribOutputSorting sorting = MagicSquareCribOutputSorting.prime;

  List<String> filters = [];

  bool bruteforce = false;
  bool bruteforce_pad = false;

  @override
  String toString() {
    return '';
  }

  File get_crib_file() {
    return File('${Directory.current.path}/english_words/all');
  }

  List<String> get_crib_words() {
    final words = get_crib_file().readAsLinesSync();

    return words;
  }
}
