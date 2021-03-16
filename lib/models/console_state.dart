import 'dart:io';

import 'package:cicadrypt/models/console_command.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import 'package:flutter/services.dart';

class ConsoleState {
  ConsoleState();

  final StringBuffer _buffer = StringBuffer();

  void write_to_console(String string) {
    _buffer.writeln(string);

    controller.text = _buffer.toString();
  }

  void clear_console() {
    _buffer.clear();

    controller.text = _buffer.toString();
  }

  void copy_buffer_to_clipboard() {
    Clipboard.setData(ClipboardData(text: _buffer.toString()));

    write_to_console('Copied output to clipboard');
  }

  void save_buffer_to_file(String fullPath) {
    final file = File(fullPath);

    if (file.existsSync()) {
      file.deleteSync();
      file.createSync();
    } else {
      file.createSync();
    }

    file.writeAsStringSync(_buffer.toString());
  }

  // COMMANDS
  dynamic previousResult;

  final List<ConsoleCommand> commands = [];

  bool is_valid_command(String command) {
    if (commands.where((cmd) => cmd.name == command).isEmpty) {
      return false;
    }

    return true;
  }

  void execute_command(String execution) {
    if (execution.isEmpty) return;

    String command_name = execution.allBefore('(');
    if (command_name == null || command_name.isEmpty) command_name = execution;

    if (command_name == 'help') {
      final help_command = commands.where((cmd) => cmd.name == 'help').first;
      final allCommands = commands;

      help_command.call([allCommands]);
      return;
    }

    if (!is_valid_command(command_name)) return;

    final raw_command_args = execution.allBetween('(', ')').split(',');
    final command_args = List<String>.generate(raw_command_args.length, (index) => raw_command_args[index].trim());

    final command = commands.where((cmd) => cmd.name == command_name).first;

    command.call(command_args);
  }

  // UI

  final controller = TextEditingController();

  final inputGlobalKey = GlobalKey<FormFieldState>();
  final inputController = TextEditingController();
  final inputFocusNode = FocusNode();
  final textInputFocusNode = FocusNode();
}
