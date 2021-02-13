import 'package:cicadrypt/models/console_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConsoleContainer extends StatefulWidget {
  ConsoleContainer({
    Key key,
    this.name,
  }) : super(key: key);

  final String name;

  @override
  _ConsoleContainerState createState() => _ConsoleContainerState();
}

class _ConsoleContainerState extends State<ConsoleContainer> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ConsoleState get_console_state() {
    return GetIt.I.get<ConsoleState>(instanceName: 'analyze');
  }

  @override
  void initState() {
    GetIt.I.registerSingleton(ConsoleState(), instanceName: 'analyze');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
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
                            labelText: 'Console Output',
                            labelStyle: const TextStyle(height: 1.0, fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          ),
                          style: const TextStyle(fontSize: 12),
                          textAlignVertical: TextAlignVertical.top,
                          cursorWidth: 1,
                          cursorColor: Colors.cyan,
                          maxLines: null,
                          expands: true,
                          controller: get_console_state().controller,
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Material(
                            child: TextButton(
                                onPressed: () {
                                  get_console_state().clear_console();
                                },
                                child: const Text('Clear', style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            child: TextButton(
                                onPressed: () {
                                  get_console_state().copy_buffer_to_clipboard();
                                },
                                child: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
