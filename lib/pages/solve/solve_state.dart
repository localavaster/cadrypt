import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../../constants/libertext.dart';
import '../../constants/runes.dart' as c;
import '../../constants/runes.dart';
import '../../global/cipher.dart';
import '../../models/console_state.dart';
import '../../services/crib.dart';
import '../../services/crib_cache.dart';
import '../analyze/analyze_state.dart';

part 'solve_state.g.dart';

class SolveState = _SolveStateBase with _$SolveState;

abstract class _SolveStateBase with Store {
  String originalCipher = '';

  TextEditingController cipher = TextEditingController();
  TextEditingController plaintext = TextEditingController();

  void initializeControllers() {
    if (originalCipher.isEmpty) {
      originalCipher = GetIt.I<Cipher>().raw_cipher.join('').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '');
    }

    cipher.addListener(() {
      final text = cipher.text;

      final StringBuffer buffer = StringBuffer();

      for (final character in text.characters) {
        if (!c.runes.contains(character)) {
          buffer.write(character);
        } else {
          buffer.write(c.runeEnglish[c.runes.indexOf(character)]);
        }
      }

      plaintext.text = buffer.toString();
    });
  }

  void load_cipher_into_controller() {
    final cipher = GetIt.I<Cipher>();

    final formattedCipher = cipher.raw_cipher.join('').replaceAll('%', '').replaceAll(r'$', '').replaceAll('&', '').replaceAll(' ', '-').replaceAll('.', '-');
    final splitCipher = formattedCipher.split('-').chunked(8);

    this.cipher.clear();

    for (final chunk in splitCipher) {
      this.cipher.text += '${chunk.join('-').trim()}\n';
    }
  }

  // console related

  final TextEditingController commandInput = TextEditingController();

  ConsoleState console = ConsoleState();

  // list of commands

  final Map<String, List<Type>> valid_commands = {
    'test': [],
    'help': [],
    'clear': [],
    'reset': [],
    'crib': [],
    'shift': [int],
    'stream': [],
    'skip_stream': [],
    'vigenere': [String],
    'atbash': [],
    'homophones': [],
    // utils
    'skip_index': [],
    // statistics
    'ioc': [],
  };

  final Map<String, String> command_help = {
    'clear': 'Clears the console',
    'reset': 'Resets the cipher to its original state',
    'shift': 'Caesar shift the cipher, example "shift(5)"',
    'stream': 'A stream of shifts, 1, 3, 5 would shift the ciphers characters by 1, 3 and 5 repeatedly, example "stream(1, 3, 5)"',
    'skip_stream': 'The same as stream, but will not continue the key if it passes over an invalid runephabet character',
    'atbash': 'Reverses the alphabet and shifts accordingly, similar to Atbash, or inversing',
    'homophones': 'Uses homophones from the crib cache and applies them to words',
  };

  final List<int> indexes_to_skip = [];

  bool is_valid_command(String command, String args) {
    if (!valid_commands.keys.contains(command)) {
      return false;
    }

    if (args == '' && valid_commands[command].isEmpty) {
      return true;
    }

    return true;
  }

  bool execute_command(String command) {
    String commandName = command.trim().allBefore('(');
    if (commandName == '') {
      commandName = command;
    }

    final commandArgs = command.trim().allBetween('(', ')');

    final bool isValid = is_valid_command(commandName, commandArgs);

    if (!isValid) {
      console.write_to_console('ERROR: Invalid command -> $command');
      return false;
    }

    switch (commandName) {
      case 'help': // redundant code below, written at 6 am
        {
          if (commandArgs == '') {
            console.write_to_console('Executing commands');
            console.write_to_console('To execute a command simply type in the command name and the arguments for it, Some commands do not need args, such as reverse, so you can type "reverse" or "reverse()", however some commands do need arguments.');
            console.write_to_console('For more information on a command, execute help(command_name)');
            console.write_to_console('Commands below');
            valid_commands.keys.forEach((element) {
              console.write_to_console('$element : ${command_help[element]}');
            });
            console.write_to_console('...with many more to come');
          } else {
            if (!command_help.keys.contains(commandArgs)) {
              console.write_to_console('Invalid command used with help');
              return true;
            }

            console.write_to_console('$commandArgs : ${command_help[commandArgs]}');
          }

          return true; // no output for this one
        }
        break;

      case 'skip_index':
        {
          final indexes = List<int>.generate(commandArgs.split(', ').length, (index) => int.parse(commandArgs.split(', ')[index]));

          indexes.forEach(indexes_to_skip.add);
        }
        break;
      case 'clear':
        {
          console.clear_console();
          return true;
        }
        break;

      case 'reset':
        {
          load_cipher_into_controller();
        }
        break;

      case 'crib':
        {
          final List<String> cipherWords = GetIt.I<Cipher>().raw_cipher.join('').replaceAll('-', ' ').replaceAll('.', ' ').replaceAll('%', '').replaceAll('&', '').replaceAll(r'$', '').replaceAll(RegExp("[^${runes.join('')} ]"), ' ').split(' ');

          print(cipherWords);

          final List<String> realWords = [];
          final cribSettings = GetIt.I<AnalyzeState>().cribSettings;

          for (final word in cipherWords) {
            if (word.contains(RegExp(r'\d'))) {
              realWords.add(word);
              continue;
            }

            final cribber = Crib(cribSettings, word);

            cribber.wordCrib();

            if (cribber.matches.isEmpty) {
              realWords.add(word);
              continue;
            }

            if (cribber.matches.length != 1) {
              final sameLengthMatches = cribber.matches.where((element) => LiberText(word).rune.length == LiberText(element.cribbed_word).rune.length).length;
              if (sameLengthMatches != 0 && sameLengthMatches <= 8) {
                final sameLength = cribber.matches.where((element) => LiberText(word).rune.length == LiberText(element.cribbed_word).rune.length).toList();
                final strings = List<String>.generate(sameLength.length, (index) => sameLength[index].cribbed_word);
                realWords.add(strings.join('_').toUpperCase());

                continue;
              }

              if (cribber.matches.length <= 8) {
                final strings = List<String>.generate(cribber.matches.length, (index) => cribber.matches[index].cribbed_word);
                realWords.add(strings.join('_').toUpperCase());
                continue;
              }

              realWords.add(word);
              continue;
            }

            cribber.matches.sortedBy<num>((element) => element.shift_sum);

            realWords.add(cribber.matches.first.cribbed_word.toUpperCase());
          }

          cipher.text = LiberText(realWords.join(' ')).rune;
        }
        break;

      case 'shift':
        {
          final buffer = StringBuffer();

          for (final character in cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final shiftedLetterIndex = (runes.indexOf(character) - int.parse(commandArgs)) % 29;

            final shiftedLetter = runes[shiftedLetterIndex];
            buffer.write(shiftedLetter);
          }

          cipher.text = buffer.toString();
        }
        break;
      case 'stream':
        {
          List<int> streams = [];
          try {
            streams = List<int>.generate(commandArgs.split(', ').length, (index) => int.parse(commandArgs.split(', ')[index]));
          } catch (e) {
            print('$e');
            final copyPossibilities = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]..shuffle();
            streams = copyPossibilities.sublist(0, 16);
            console.write_to_console('Streaming with a random value -> $streams');
          }

          final buffer = StringBuffer();

          int streamPosition = 0;
          for (final character in cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final shiftedLetterIndex = (runes.indexOf(character) - (streams[streamPosition % streams.length]) % 29) % 29;

            final shiftedLetter = runes[shiftedLetterIndex];
            buffer.write(shiftedLetter);
            streamPosition++;
          }

          cipher.text = buffer.toString();
        }
        break;

      case 'vigenere':
        {
          List<int> streams = [];
          try {
            final splitEnglishWord = gematriaRegex.allMatches(commandArgs).map((e) => e.group(0)).toList(); // slow
            streams = List<int>.generate(splitEnglishWord.length, (index) => c.runeEnglish.indexOf(splitEnglishWord[index].toLowerCase()));
          } catch (e) {
            final copyPossibilities = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]..shuffle();
            streams = copyPossibilities.sublist(0, 16);
            console.write_to_console('Streaming with a random value -> $streams');
          }

          final testBuffer = StringBuffer();

          final buffer = StringBuffer();

          int streamPosition = 0;
          for (final character in cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);

              continue;
            }

            if (indexes_to_skip.contains(streamPosition)) {
              continue;
            }

            final keyPart = streams[streamPosition % streams.length] % runes.length;

            if (keyPart == 0) {
              testBuffer.write(c.runeToEnglish[character]);
            }

            final shiftedLetterIndex = (runes.indexOf(character) - keyPart) % 29;

            final shiftedLetter = runes[shiftedLetterIndex];
            buffer.write(shiftedLetter);
            streamPosition++;
          }

          cipher.text = buffer.toString();
        }
        break;

      case 'skip_stream':
        {
          List<int> streams = [];
          try {
            streams = List<int>.generate(commandArgs.split(', ').length, (index) => int.parse(commandArgs.split(', ')[index]));
          } catch (e) {
            final copyPossibilities = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]..shuffle();
            streams = copyPossibilities.sublist(0, 16);
            console.write_to_console('Streaming with a random value -> $streams');
          }

          final buffer = StringBuffer();

          int streamPosition = 0;
          for (final character in cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              streamPosition--;
              continue;
            }

            final shiftedLetterIndex = (runes.indexOf(character) - (streams[streamPosition % streams.length]) % 29) % 29;

            final shiftedLetter = runes[shiftedLetterIndex];
            buffer.write(shiftedLetter);
            streamPosition++;
          }

          cipher.text = buffer.toString();
        }
        break;

      case 'homophones':
        {
          final homophones = GetIt.I<CribCache>().calculate_homophones();

          final buffer = StringBuffer();

          for (final character in cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final letterHomophones = homophones[character].toSet().toList();

            if (letterHomophones.isEmpty) {
              buffer.write(character.toLowerCase());
              continue;
            }

            if (letterHomophones.length == 1) {
              buffer.write(letterHomophones.join().toUpperCase());
            } else {
              buffer.write('(${letterHomophones.join().toUpperCase()})');
            }
          }

          cipher.text = buffer.toString();
        }
        break;

      case 'atbash':
        {
          final reversedRuneAlphabet = List<String>.from(c.runes).reversed.toList();

          final buffer = StringBuffer();

          for (final character in cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final reversedLetterIndex = reversedRuneAlphabet.indexOf(character);

            final shiftedLetter = runes[reversedLetterIndex];
            buffer.write(shiftedLetter);
          }

          cipher.text = buffer.toString();
        }
        break;

      // statistics

      case 'ioc':
        {
          Map<String, int> get_character_frequencies({bool runeOnly = true}) {
            final Map<String, int> seen = {};

            for (final character in cipher.text.characters) {
              if (runeOnly) {
                if (!runeToEnglish.containsKey(character)) continue;
              }

              if (seen.containsKey(character)) {
                seen[character] += 1;
              } else {
                seen[character] = 1;
              }
            }

            return seen;
          }

          double get_index_of_coincidence() {
            final flatCipher = cipher.text.replaceAll(' ', '').replaceAll('.', '').replaceAll('\n', '');

            final length = flatCipher.length;

            final frequency = get_character_frequencies();

            final List<String> alphabet = runeToEnglish.keys.toList();

            double frequencySum = 0.0;

            alphabet.forEach((rune) {
              if (frequency.containsKey(rune)) {
                frequencySum += frequency[rune] * (frequency[rune] - 1);
              }
            });

            if (frequencySum == 0.0) return 0.0;

            return frequencySum / (length * (length - 1));
          }

          console.write_to_console('IoC: ${get_index_of_coincidence().toStringAsFixed(8)}');
        }
        break;
    }

    console.write_to_console('Executed $commandName with args: $commandArgs');
    return true;
  }
}
