import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../constants/libertext.dart';
import '../../../widgets/rune_container.dart';
import '../analyze_state.dart';

class CipherContainer extends StatefulWidget {
  const CipherContainer({
    @required this.state,
  }) : super();

  final AnalyzeState state;

  @override
  _CipherContainerState createState() => _CipherContainerState();
}

class _CipherContainerState extends State<CipherContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        elevation: 2,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.50,
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.black.withOpacity(0.33),
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).cardColor, width: 0.5)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Cipher'),
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                                  widget.state.select_cipher_mode('sentences');
                                  break;

                                case 4:
                                  widget.state.select_cipher_mode('2x2');
                                  break;

                                case 5:
                                  widget.state.select_cipher_mode('3x3');
                                  break;

                                case 6:
                                  widget.state.select_cipher_mode('4x4');
                                  break;

                                case 7:
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
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('Sentences'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<int>(
                              value: 4,
                              child: Text('2x2'),
                            ),
                            const PopupMenuItem<int>(
                              value: 5,
                              child: Text('3x3'),
                            ),
                            const PopupMenuItem<int>(
                              value: 6,
                              child: Text('4x4'),
                            ),
                            const PopupMenuItem<int>(
                              value: 7,
                              child: Text('5x5'),
                            ),
                          ],
                          child: const Icon(
                            Icons.visibility,
                            size: 20,
                            semanticLabel: 'Cipher settings',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Observer(builder: (context) {
                    final cipher = widget.state.get_grid_cipher();

                    return GridView.builder(
                      cacheExtent: 214141414,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.state.get_grid_x_axis_count(),
                      ),
                      itemCount: cipher.length,
                      itemBuilder: (context, index) {
                        final character = cipher.characters.elementAt(index);
                        if (character == '%' || character == '&' || character == r'$') {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).cardColor, width: 0.5),
                              color: Colors.black.withOpacity(0.165),
                            ),
                          );
                        }

                        return RuneContainer(widget.state, index, LiberText(cipher.characters.elementAt(index)));
                      },
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
          ),
        ),
      ),
    );
  }
}
