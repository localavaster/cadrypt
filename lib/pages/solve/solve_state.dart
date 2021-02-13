import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/models/console_command.dart';
import 'package:cicadrypt/models/console_state.dart';
import 'package:cicadrypt/models/crib_settings.dart';
import 'package:cicadrypt/services/crib.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../../constants/runes.dart' as c;
import '../../constants/runes.dart';
import '../../constants/runes.dart';

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

    this.cipher.clear();
    for (final line in cipher.raw_cipher) {
      if (['%', r'$', '&'].contains(line[0])) continue;
      this.cipher.text += '${line.trim()}\n';
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
  };

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
    String command_name = command.trim().allBefore('(');
    if (command_name == '') {
      command_name = command;
    }

    final command_args = command.trim().allBetween('(', ')');

    print('executing $command_name with $command_args');

    bool is_valid = is_valid_command(command_name, command_args);

    if (!is_valid) {
      console.write_to_console('ERROR: Invalid command -> $command');
      return false;
    }

    switch (command_name) {
      case 'help': // redundant code below, written at 6 am
        {
          if (command_args == '') {
            console.write_to_console('Executing commands');
            console.write_to_console('To execute a command simply type in the command name and the arguments for it, Some commands do not need args, such as reverse, so you can type "reverse" or "reverse()", however some commands do need arguments.');
            console.write_to_console('For more information on a command, execute help(command_name)');
            console.write_to_console('Commands below');
            valid_commands.keys.forEach((element) {
              console.write_to_console('$element : ${command_help[element]}');
            });
            console.write_to_console('...with many more to come');
          } else {
            if (!command_help.keys.contains(command_args)) {
              console.write_to_console('Invalid command used with help');
              return true;
            }

            console.write_to_console('${command_args} : ${command_help[command_args]}');
          }

          return true; // no output for this one
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
          this.load_cipher_into_controller();
        }
        break;

      case 'crib':
        {
          final buffer = StringBuffer();

          final List<String> cipherWords = GetIt.I<Cipher>().raw_cipher.join('').replaceAll('-', ' ').replaceAll('.', ' . ').replaceAll('%', '').replaceAll('&', '').replaceAll(r'$', '').split(' ');
          //cipherWords.removeWhere((element) => ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(element));

          //print(cipherWords);
          final List<String> realWords = [];
          final cribSettings = CribSettings();
          cribSettings.filters.add('onlypuregpshifts');
          cribSettings.filters.add('hasplaintext');
          cribSettings.wordFilters.add('onlylp');

          for (final word in cipherWords) {
            if (word == '.') {
              realWords.add('.');
              continue;
            }

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

            cribber.matches = cribber.matches.sortedByNum((element) => element.shift_sum);

            realWords.add(cribber.matches.first.crib);
          }

          this.cipher.text = realWords.join(' ');
        }
        break;

      case 'shift':
        {
          final buffer = StringBuffer();

          for (final character in this.cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final shifted_letter_index = (runes.indexOf(character) - int.parse(command_args)) % 29;

            final shifted_letter = runes[shifted_letter_index];
            buffer.write(shifted_letter);
          }

          this.cipher.text = buffer.toString();
        }
        break;
      case 'stream':
        {
          List<int> streams = [];
          try {
            streams = List<int>.generate(command_args.split(', ').length, (index) => int.parse(command_args.split(', ')[index]));
          } catch (e) {
            print('$e');
            final copyPossibilities = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]..shuffle();
            streams = copyPossibilities.sublist(0, 16);
            console.write_to_console('Streaming with a random value -> $streams');
          }

          final buffer = StringBuffer();

          int stream_position = 0;
          for (final character in this.cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final shifted_letter_index = (runes.indexOf(character) - (streams[stream_position % streams.length]) % 29) % 29;

            final shifted_letter = runes[shifted_letter_index];
            buffer.write(shifted_letter);
            stream_position++;
          }

          this.cipher.text = buffer.toString();
        }
        break;

      case 'vigenere':
        {
          List<int> streams = [];
          try {
            final splitEnglishWord = gematriaRegex.allMatches(command_args).map((e) => e.group(0)).toList(); // slow
            streams = List<int>.generate(splitEnglishWord.length, (index) => c.runeEnglish.indexOf(splitEnglishWord[index].toLowerCase()));
          } catch (e) {
            final copyPossibilities = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]..shuffle();
            streams = copyPossibilities.sublist(0, 16);
            console.write_to_console('Streaming with a random value -> $streams');
          }

          print(streams);

          final buffer = StringBuffer();

          int stream_position = 0;
          for (final character in this.cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);

              continue;
            }

            final shifted_letter_index = (runes.indexOf(character) - (streams[stream_position % streams.length]) % 29) % 29;

            final shifted_letter = runes[shifted_letter_index];
            buffer.write(shifted_letter);
            stream_position++;
          }

          this.cipher.text = buffer.toString();
        }
        break;

      case 'skip_stream':
        {
          List<int> streams = [];
          try {
            streams = List<int>.generate(command_args.split(', ').length, (index) => int.parse(command_args.split(', ')[index]));
          } catch (e) {
            final copyPossibilities = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]..shuffle();
            streams = copyPossibilities.sublist(0, 16);
            console.write_to_console('Streaming with a random value -> $streams');
          }

          final buffer = StringBuffer();

          int stream_position = 0;
          for (final character in this.cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              stream_position--;
              continue;
            }

            final shifted_letter_index = (runes.indexOf(character) - (streams[stream_position % streams.length]) % 29) % 29;

            final shifted_letter = runes[shifted_letter_index];
            buffer.write(shifted_letter);
            stream_position++;
          }

          this.cipher.text = buffer.toString();
        }
        break;

      case 'atbash':
        {
          final reversedRuneAlphabet = List<String>.from(c.runes).reversed.toList();

          final buffer = StringBuffer();

          for (final character in this.cipher.text.characters) {
            if (!runes.contains(character)) {
              buffer.write(character);
              continue;
            }

            final reversed_letter_index = (reversedRuneAlphabet.indexOf(character));

            final shifted_letter = runes[reversed_letter_index];
            buffer.write(shifted_letter);
          }

          this.cipher.text = buffer.toString();
        }
        break;

      // statistics

      case 'ioc':
        {
          Map<String, int> get_character_frequencies({bool runeOnly = true}) {
            final Map<String, int> seen = {};

            for (final character in this.cipher.text.characters) {
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
            final flat_cipher = this.cipher.text.replaceAll(' ', '').replaceAll('.', '').replaceAll('\n', '');

            print(flat_cipher);

            final length = flat_cipher.length;

            final frequency = get_character_frequencies();

            final List<String> alphabet = runeToEnglish.keys.toList();

            double frequency_sum = 0.0;

            alphabet.forEach((rune) {
              if (frequency.containsKey(rune)) {
                frequency_sum += frequency[rune] * (frequency[rune] - 1);
              }
            });

            if (frequency_sum == 0.0) return 0.0;

            return frequency_sum / (length * (length - 1));
          }

          console.write_to_console('IoC: ${get_index_of_coincidence().toStringAsFixed(8)}');
        }
        break;
    }

    console.write_to_console('Executed $command_name with args: $command_args');
    return true;
  }
}
