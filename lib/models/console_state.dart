import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

import 'console_command.dart';

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

  void execute_command(Function setState, String execution) {
    if (execution.isEmpty) return;

    String commandName = execution.allBefore('(');
    if (commandName == null || commandName.isEmpty) commandName = execution;

    if (commandName == 'help') {
      final helpCommand = commands.where((cmd) => cmd.name == 'help').first;
      final allCommands = commands;

      helpCommand.call([allCommands]);
      return;
    }

    if (!is_valid_command(commandName)) return;

    final rawCommandArgs = execution.allBetween('(', ')').split(',');
    final commandArgs = List<String>.generate(rawCommandArgs.length, (index) => rawCommandArgs[index].trim());

    final command = commands.where((cmd) => cmd.name == commandName).first;

    command.call(commandArgs);
  }

  // UI

  final controller = TextEditingController();

  final inputGlobalKey = GlobalKey<FormFieldState>();
  final inputController = TextEditingController();
  final inputFocusNode = FocusNode();
  final textInputFocusNode = FocusNode();
}
