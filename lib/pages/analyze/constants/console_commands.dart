import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../../../constants/libertext.dart';
import '../../../constants/runes.dart';
import '../../../constants/utils.dart';
import '../../../global/cipher.dart';
import '../../../models/console_command.dart';
import '../../../models/console_state.dart';
import '../../../services/crib_cache.dart';
import '../analyze_state.dart';

class AnalyzeConsoleCommands {
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

          final gematriaCharacters = gematriaRegex.allMatches(latin.toLowerCase()).map((e) => e.group(0)).toList(); // slow

          final gematria = List<String>.generate(gematriaCharacters.length, (index) {
            final character = gematriaCharacters.elementAt(index);
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
        help: 'Shows information on a word ( ex. t_wordinfo(ABC) )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

          final liberedString = LiberText(args.first as String);

          final selectedRuneLetters = List<String>.generate(liberedString.rune.length, (index) => liberedString.rune.characters.elementAt(index));

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

          final gpWord = <List<String>>[];

          final reversedMap = {for (var e in runePrimes.entries) int.parse(e.value): e.key};

          for (final rune in selectedRuneLetters) {
            final gpPossibilities = get_gp_modulos(runes.indexOf(rune));

            final poss = <String>[];
            for (final p in gpPossibilities) {
              poss.add(runeToEnglish[reversedMap[p]]);
            }

            gpWord.add(poss);
          }
          console.write_to_console('GP: $gpWord');
        }),
    ConsoleCommand(
        name: 't_atbash',
        args: [],
        help: 'Atbashes the current ciphertext ( ex. t_atbash() )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
          final cipher = GetIt.I<Cipher>();

          final reconstructedCipher = <String>[];
          final reversedRunes = List<String>.from(runes).reversed.toList();

          for (final cipher_chunk in cipher.raw_cipher) {
            final buffer = StringBuffer();

            for (final character in cipher_chunk.characters) {
              if (runes.contains(character)) {
                buffer.write(reversedRunes[runes.indexOf(character)]);
              } else {
                buffer.write(character);
              }
            }

            reconstructedCipher.add(buffer.toString());
          }

          GetIt.I<AnalyzeState>().global_key.currentState.setState(() {
            cipher.load_from_text(reconstructedCipher.join('\n'));
          });
        }),
    ConsoleCommand(
        name: 't_gpify',
        args: [],
        help: 'Applies rune GP values to ciphertext ( ex. t_gpify() )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
          final cipher = GetIt.I<Cipher>();

          final reconstructedCipher = <String>[];
          final reversedRunes = List<String>.from(runes).reversed.toList();

          for (final cipher_chunk in cipher.raw_cipher) {
            final buffer = StringBuffer();

            for (final character in cipher_chunk.characters) {
              final text = LiberText(character);

              if (runes.contains(character)) {
                buffer.write(runes[(text.prime.first) % 29]);
              } else {
                buffer.write(character);
              }
            }

            reconstructedCipher.add(buffer.toString());
          }

          GetIt.I<AnalyzeState>().global_key.currentState.setState(() {
            cipher.load_from_text(reconstructedCipher.join('\n'));
          });
        }),
    ConsoleCommand(
        name: 't_reverse',
        args: [],
        help: 'Reverses the ciphertext ( ex. t_reverse() )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

          final cipher = GetIt.I<Cipher>();

          final reconstructedCipher = <String>[];

          for (final cipher_chunk in cipher.raw_cipher) {
            final buffer = StringBuffer();

            for (final character in cipher_chunk.reverse.characters) {
              final text = LiberText(character);

              buffer.write(text.rune);
            }

            reconstructedCipher.add(buffer.toString());
          }

          GetIt.I<AnalyzeState>().global_key.currentState.setState(() {
            cipher.load_from_text(reconstructedCipher.join('\n'));
          });
        }),
    ConsoleCommand(
        name: 't_totientstream',
        args: [],
        help: 'Applies "An End" method on the ciphertext ( ex. t_totientstream() )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');
          List<int> primes = [];
          int amountOfPrimes = 0;
          int maxCount = 10;

          final cipher = GetIt.I<Cipher>();

          while (amountOfPrimes <= cipher.cipher_length) {
            primes = prime_sieve(maxCount);
            amountOfPrimes = primes.length;
            maxCount++;
          }

          primes.removeAt(0);
          primes.removeAt(0);

          // remove 0 and 1 ^

          print('total primes: ${primes.length}');
          print('first primes: ${primes.sublist(0, 5)}');

          final reconstructedCipher = <String>[];

          int keyPosition = 0;

          for (final cipher_chunk in cipher.raw_cipher) {
            final buffer = StringBuffer();

            for (final character in cipher_chunk.characters) {
              final text = LiberText(character);

              if (runes.contains(character)) {
                buffer.write(runes[(runes.indexOf(text.rune) - (primes[keyPosition] - 1)) % 29]);

                keyPosition++;
              } else {
                buffer.write(character);
              }
            }

            reconstructedCipher.add(buffer.toString());
          }

          GetIt.I<AnalyzeState>().global_key.currentState.setState(() {
            cipher.load_from_text(reconstructedCipher.join('\n'));
          });
        }),
    ConsoleCommand(
        name: 't_vigenere',
        args: [],
        help: 'Applies Vigenere on the ciphertext ( ex. t_vigenere(firfumferenfe) )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

          final vigenereKey = LiberText(args.first as String).index;
          final cipher = GetIt.I<Cipher>();

          final reconstructedCipher = <String>[];

          int keyPosition = 0;

          for (final cipher_chunk in cipher.raw_cipher) {
            final buffer = StringBuffer();

            for (final character in cipher_chunk.characters) {
              final text = LiberText(character);

              if (runes.contains(character)) {
                buffer.write(runes[(text.index.first - (vigenereKey[keyPosition % vigenereKey.length])) % 29]);

                keyPosition++;
              } else {
                buffer.write(character);
              }
            }

            reconstructedCipher.add(buffer.toString());
          }

          GetIt.I<AnalyzeState>().global_key.currentState.setState(() {
            cipher.load_from_text(reconstructedCipher.join('\n'));
          });
        }),
    ConsoleCommand(
        name: 't_shift',
        args: [],
        help: 'Applies a shift on the ciphertext ( ex. t_shift(5) )',
        call: (List<dynamic> args) {
          final console = GetIt.instance.get<ConsoleState>(instanceName: 'analyze');

          final vigenereKey = LiberText(args.first as String).index;
          final cipher = GetIt.I<Cipher>();

          final reconstructedCipher = <String>[];

          int keyPosition = 0;

          for (final cipher_chunk in cipher.raw_cipher) {
            final buffer = StringBuffer();

            for (final character in cipher_chunk.characters) {
              final text = LiberText(character);

              if (runes.contains(character)) {
                buffer.write(runes[(text.index.first - (vigenereKey[keyPosition % vigenereKey.length])) % 29]);

                keyPosition++;
              } else {
                buffer.write(character);
              }
            }

            reconstructedCipher.add(buffer.toString());
          }

          GetIt.I<AnalyzeState>().global_key.currentState.setState(() {
            cipher.load_from_text(reconstructedCipher.join('\n'));
          });
        }),
  ];
}
