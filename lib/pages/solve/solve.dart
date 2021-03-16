import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'solve_state.dart';

class SolvePage extends StatefulWidget {
  const SolvePage({Key key}) : super(key: key);

  @override
  _SolvePageState createState() => _SolvePageState();
}

class _SolvePageState extends State<SolvePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final SolveState state = SolveState();

  final inputGlobalKey = GlobalKey<FormFieldState>();
  final inputFocusNode = FocusNode();
  final textInputFocusNode = FocusNode();

  @override
  void initState() {
    state.initializeControllers();
    if (state.plaintext.text.isEmpty) {
      state.load_cipher_into_controller();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.66,
                    child: Material(
                      elevation: 2,
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration().copyWith(
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                                  labelText: 'Cipher',
                                  labelStyle: const TextStyle(height: 1.0, fontSize: 18),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                ),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'RobotoMono'),
                                textAlignVertical: TextAlignVertical.top,
                                cursorWidth: 1,
                                cursorColor: Colors.cyan,
                                maxLines: null,
                                expands: true,
                                readOnly: true,
                                controller: state.plaintext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.66,
                    child: Material(
                      elevation: 2,
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration().copyWith(
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                                  labelText: 'Command Console',
                                  labelStyle: const TextStyle(height: 1.0, fontSize: 18),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                ),
                                style: const TextStyle(fontSize: 14),
                                textAlignVertical: TextAlignVertical.top,
                                cursorWidth: 1,
                                cursorColor: Colors.cyan,
                                maxLines: null,
                                expands: true,
                                readOnly: true,
                                controller: state.console.controller,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RawKeyboardListener(
                              onKey: (event) {
                                final event_type = event.runtimeType;
                                final key_id = event.logicalKey.keyId;

                                if (key_id == 4295426088 && event_type == RawKeyDownEvent) // enter
                                {
                                  inputGlobalKey.currentState.save();
                                }
                              },
                              focusNode: inputFocusNode,
                              child: TextFormField(
                                key: inputGlobalKey,
                                decoration: const InputDecoration().copyWith(
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                                  labelText: 'Command Input',
                                  labelStyle: const TextStyle(height: 1.0, fontSize: 18),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                ),
                                style: const TextStyle(fontSize: 14),
                                textAlignVertical: TextAlignVertical.top,
                                cursorWidth: 1,
                                cursorColor: Colors.cyan,
                                maxLines: null,
                                controller: state.commandInput,
                                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
                                onSaved: (value) {
                                  // ghetto, but flutter desktop is still alpha
                                  state.execute_command(value);

                                  state.commandInput.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
