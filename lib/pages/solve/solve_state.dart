import 'package:cicadrypt/global/cipher.dart';
import 'package:cicadrypt/models/console_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import '../../constants/runes.dart' as c;
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
          buffer.write(c.rune_english[c.runes.indexOf(character)]);
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
      this.cipher.text += line.trim() + '\n';
    }
  }

  // console related

  final TextEditingController commandInput = TextEditingController();

  ConsoleState console = ConsoleState();

  // list of valid commands and their valid argument types
  final Map<String, List<Type>> valid_commands = {
    'help': [],
    'clear': [],
    'reset': [],
    'shift': [int],
    'stream': [],
    'skip_stream': [],
    'reverse': [],
  };

  final Map<String, String> command_help = {
    'clear': 'Clears the console',
    'reset': 'Resets the cipher to its original state',
    'shift': 'Caesar shift the cipher, example "shift(5)"',
    'stream': 'A stream of shifts, 1, 3, 5 would shift the ciphers characters by 1, 3 and 5 repeatedly, example "stream(1, 3, 5)"',
    'skip_stream': 'The same as stream, but will not continue the key if it passes over an invalid runephabet character',
    'reverse': 'Reverses the alphabet and shifts accordingly, similar to Atbash, or inversing',
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
            console.write_to_console('Commands below');
            command_help.keys.forEach((element) {
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
            console.write_to_console('ERROR: Invalid command -> $command');
            return false;
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

      case 'skip_stream':
        {
          List<int> streams = [];
          try {
            streams = List<int>.generate(command_args.split(', ').length, (index) => int.parse(command_args.split(', ')[index]));
          } catch (e) {
            console.write_to_console('ERROR: Invalid command -> $command');
            return false;
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

      case 'reverse':
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
    }

    console.write_to_console('Executed $command_name with args: $command_args');
    return true;
  }
}
