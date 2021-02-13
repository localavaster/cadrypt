import 'package:cicadrypt/widgets/rune_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../analyze_state.dart';

class CipherContainer extends StatefulWidget {
  const CipherContainer({
    Key key,
    @required this.state,
  }) : super(key: key);

  final AnalyzeState state;

  @override
  _CipherContainerState createState() => _CipherContainerState();
}

class _CipherContainerState extends State<CipherContainer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        elevation: 2,
        child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cipher'),
                      Center(
                        child: PopupMenuButton<int>(
                          onSelected: (int result) {
                            setState(() {
                              switch (result) {
                                case 0:
                                  widget.state.select_cipher_mode('regular');
                                  break;

                                case 1:
                                  widget.state.select_cipher_mode('flat');
                                  break;

                                case 2:
                                  widget.state.select_cipher_mode('true');
                                  break;

                                case 3:
                                  widget.state.select_cipher_mode('3x3');
                                  break;

                                case 4:
                                  widget.state.select_cipher_mode('4x4');
                                  break;

                                case 5:
                                  widget.state.select_cipher_mode('5x5');
                                  break;
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                            const PopupMenuItem<int>(
                              value: 0,
                              child: Text('Regular'),
                            ),
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text('Flat'),
                            ),
                            const PopupMenuItem<int>(
                              value: 2,
                              child: Text('True'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('3x3'),
                            ),
                            const PopupMenuItem<int>(
                              value: 4,
                              child: Text('4x4'),
                            ),
                            const PopupMenuItem<int>(
                              value: 5,
                              child: Text('5x5'),
                            ),
                          ],
                          child: const Icon(
                            Icons.visibility,
                            size: 16,
                            semanticLabel: 'Cipher settings',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Observer(builder: (_) {
                      final cipher = widget.state.get_grid_cipher();

                      return GridView.count(
                        crossAxisCount: widget.state.get_grid_x_axis_count(),
                        children: List.generate(cipher.length, (index) => RuneContainer(widget.state, index, cipher.characters.elementAt(index))),
                      );
                    }),
                  ),
                ),
                Material(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('rune');
                          },
                          child: const Text(
                            'Runes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('english');
                          },
                          child: const Text(
                            'English',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('value');
                          },
                          child: const Text(
                            'Value',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('prime');
                          },
                          child: const Text(
                            'Prime',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('index');
                          },
                          child: const Text(
                            'Index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.state.select_reading_mode('color');
                          },
                          child: const Text(
                            'Color',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
