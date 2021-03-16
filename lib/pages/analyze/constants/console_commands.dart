import 'package:cicadrypt/constants/runes.dart';
import 'package:cicadrypt/constants/utils.dart';
import 'package:cicadrypt/models/console_state.dart';
import 'package:cicadrypt/services/crib_cache.dart';
import 'package:get_it/get_it.dart';
import 'package:collection/collection.dart';

import '../../../models/console_command.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import 'package:flutter/services.dart';

List<ConsoleCommand> analyze_console_commands = [
  ConsoleCommand(
      name: 'help',
      args: [],
      help: 'Shows help information',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

        final commands = (args.first as List).cast<ConsoleCommand>();

        console.write_to_console('Execution -> Enter a command along with its args');
        console.write_to_console('Example -> toenglish(hello) returns the runified version of hello');

        for (final command in commands) {
          console.write_to_console('${command.name} -> ${command.help}');
        }
      }),
  ConsoleCommand(
      name: 'torune',
      args: [],
      help: 'Converts latin characters to Gematria Primus',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

        String latin = '';
        if (args.isEmpty && console.previousResult != null) latin = console.previousResult as String;
        if (args.isNotEmpty) latin = args[0] as String;

        final gematria_characters = gematriaRegex.allMatches(latin.toLowerCase()).map((e) => e.group(0)).toList(); // slow

        final gematria = List<String>.generate(gematria_characters.length, (index) {
          final character = gematria_characters.elementAt(index);
          int idx = runeEnglish.indexOf(character);
          if (idx == -1) idx = altRuneEnglish.indexOf(character);

          if (idx == -1) {
            return character;
          } else {
            return runes[idx];
          }
        }).join();

        console.previousResult = gematria;
        console.write_to_console('Rune Word: $gematria');
      }),
  ConsoleCommand(
      name: 'toenglish',
      args: [],
      help: 'Converts gematria primus characters to English',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
        String runes = '';
        if (args.isEmpty && console.previousResult != null) runes = console.previousResult as String;
        if (args.isNotEmpty) runes = args[0] as String;

        final english = List<String>.generate(runes.length, (index) {
          final character = runes.characters.elementAt(index);

          if (runeToEnglish.containsKey(character)) {
            return runeToEnglish[character];
          } else {
            return character;
          }
        }).join();

        console.previousResult = english;
        console.write_to_console('English Word: $english');
      }),
  ConsoleCommand(
      name: 'cc',
      args: [],
      help: 'Shows what is in your crib cache',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
        final cache = GetIt.I<CribCache>();

        cache.cache.forEach((element) {
          console.write_to_console(element.toConsoleString(['shiftsum', 'shiftdifferencessum', 'cribword', 'shiftlist', 'shiftdifferences']));
        });
      }),
  ConsoleCommand(
      name: 'cc_homophones',
      args: [],
      help: 'Uses crib cache to determine homophones',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
        final cache = GetIt.I<CribCache>();

        final homophones = cache.calculate_homophones();

        homophones.forEach((key, value) {
          console.write_to_console('$key -> $value');
        });
      }),
  ConsoleCommand(
      name: 'cc_clear',
      args: [],
      help: 'Clears crib cache',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
        final cache = GetIt.I<CribCache>();

        cache.cache.clear();

        console.write_to_console('Cleared crib cache');
      }),
  ConsoleCommand(
      name: 'wordinfo',
      args: [],
      help: 'Shows information on a word',
      call: (List<dynamic> args) {
        final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

        final selectedRuneLetters = List<String>.generate((args.first as String).length, (index) => (args.first as String).characters.elementAt(index));

        final primes = List<int>.generate(selectedRuneLetters.length, (index) => Conversions.runeToPrime(selectedRuneLetters[index]));
        final primesMod29 = List<int>.generate(selectedRuneLetters.length, (index) => Conversions.runeToPrime(selectedRuneLetters[index]) % 29);
        final positions = List<int>.generate(selectedRuneLetters.length, (index) => runes.indexOf(selectedRuneLetters[index]));

        final primeSum = primes.sum;
        final positionsSum = positions.sum;

        console.write_to_console('=== Selection Info (${selectedRuneLetters.join()})');
        console.write_to_console('Length: ${selectedRuneLetters.length}');
        console.write_to_console('Prime Conversion: $primes');
        console.write_to_console('Prime(%29) Conversion: $primesMod29');
        console.write_to_console('Prime Conv. Sum: $primeSum');
        console.write_to_console('Position Conversion: $positions');
        console.write_to_console('Position Conv. Sum: $positionsSum');

        final word = List<String>.generate(positions.length, (index) => runeEnglish[positions[index]]);
        final atbashedWord = List<String>.generate(word.length, (index) => runeEnglish.reversed.toList()[positions[index]]);
        console.write_to_console('Word: ${word.join('')} | ${word.join('').reverse}');
        console.write_to_console('Atbash: ${atbashedWord.join('')} | ${atbashedWord.join('').reverse}');

        //

        final gp_word = <List<String>>[];

        final reversed_map = {for (var e in runePrimes.entries) int.parse(e.value): e.key};

        for (final rune in selectedRuneLetters) {
          final gp_possibilities = get_gp_modulos(runes.indexOf(rune));

          final poss = <String>[];
          for (final p in gp_possibilities) {
            poss.add(runeToEnglish[reversed_map[p]]);
          }

          gp_word.add(poss);
        }
        console.write_to_console('GP: $gp_word');

        final flat_gp = gp_word.expand((element) => element).toList();
        final flat_gp_to_indexes = List<int>.generate(flat_gp.length, (index) {
          int idx = runeEnglish.indexOf(flat_gp[index].toLowerCase());
          if (idx == -1) idx = altRuneEnglish.indexOf(flat_gp[index].toLowerCase());

          return idx;
        });
      }),
];
