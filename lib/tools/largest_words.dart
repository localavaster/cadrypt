import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../global/cipher.dart';
import '../models/console_state.dart';

void toolLargestWords(BuildContext context) {
  final cipher = GetIt.I<Cipher>().raw_cipher.join().replaceAll(RegExp(r'[%$&]'), '').replaceAll('.', '-').replaceAll(' ', '-');

  final words = cipher.split('-').sortedBy<num>((element) => element.length).reversed.toList();

  final console_state = GetIt.I.get<ConsoleState>(instanceName: 'analyze');

  words.forEach((element) {
    console_state.write_to_console('${element.length} | $element');
  });
}
