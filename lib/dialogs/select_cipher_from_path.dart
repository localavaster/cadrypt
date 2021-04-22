import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../global/cipher.dart';
import '../pages/analyze/analyze_state.dart';

Future<void> selectCipherFromPath(BuildContext context, Function globalSetState) {
  return showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Builder(
        builder: (context) {
          // ignore: strict_raw_type
          final pathKey = GlobalKey<FormFieldState>();
          final pathTextController = TextEditingController();
          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.30;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Load cipher from path'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: pathKey,
                            controller: pathTextController,
                            decoration: const InputDecoration().copyWith(hintText: 'C:/Users/null/Desktop/cipher_0.txt'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Must not be empty.';
                              }

                              if (!value.endsWith('.txt')) {
                                return 'Must be a .txt file';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () {
                            final isValid = pathKey.currentState.validate();
                            if (!isValid) return;

                            globalSetState(() {
                              final AnalyzeState state = GetIt.I<AnalyzeState>();
                              state.clear_selected_runes();
                              state.highlighedRunes.clear();

                              GetIt.I<Cipher>().load_from_file(pathTextController.text);
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Load', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
