import 'package:flutter/material.dart';

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

  final TextEditingController controller = TextEditingController();
}
