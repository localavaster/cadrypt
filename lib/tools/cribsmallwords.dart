import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../global/cipher.dart';
import '../models/console_state.dart';
import '../models/crib_settings.dart';
import '../services/crib.dart';

Future<void> toolCribSmallWords(BuildContext context) async {
  final console_state = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  final cipher = GetIt.I<Cipher>().raw_cipher.join().replaceAll(RegExp(r'[%$&]'), '').replaceAll('.', '-').replaceAll(' ', '-');

  final words = cipher.split('-').sortedBy<num>((element) => element.length).reversed.toList();

  words.removeWhere((element) => element.length > 2);

  console_state.write_to_console('Total small words: ${words.length}');

  final settings = CribSettings();
  settings.wordFilters.add('onlylp');
  settings.outputFillers.add('shiftlist');
  settings.outputFillers.add('shiftsinwordform');
  settings.outputFillers.add('shiftsingpform');

  final results = <String, List<String>>{};

  for (final word in words) {
    final cribber = Crib(settings, word);

    await cribber.start_crib();

    cribber.matches.forEach((element) {
      results[element.cribbed_word] ??= [];

      results[element.cribbed_word].add(element.toString());
    });
  }

  results.forEach((key, value) {
    console_state.write_to_console('-> $key');
    value.sortedBy<num>((element) => int.parse(element.split('|').first.trim())).forEach((element) {
      console_state.write_to_console('---> $element');
    });
  });
}
