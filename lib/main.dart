import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:desktop_window/desktop_window.dart';

import 'global/cipher.dart';
import 'models/console_state.dart';
import 'pages/analyze/analyze.dart';
import 'pages/solve/solve.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DesktopWindow.setWindowSize(const Size(880, 880));

  GetIt.instance.registerSingleton(Cipher([]));
  GetIt.instance<Cipher>().load_from_file('${Directory.current.path}/solved_liberprimus_pages/lossofdivinity0.txt');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadrypt',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SegoeUISymbol',
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(width: double.infinity, height: 20, child: Center(child: Text('Current Cipher ― ${GetIt.I<Cipher>().current_cipher_file.split('/').last}', style: const TextStyle(height: 1.0)))),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: Material(
                elevation: 2,
                //color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    PopupMenuButton<int>(
                      onSelected: (int result) {
                        switch (result) {
                          case 0:
                            {
                              showDialog<void>(
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
                                      return Container(
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

                                                        setState(() {
                                                          print(pathTextController.text);
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
                            break;

                          case 1:
                            {
                              showDialog<void>(
                                barrierColor: Colors.black.withOpacity(0.30),
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Builder(
                                    builder: (context) {
                                      final width = MediaQuery.of(context).size.width * 0.30;
                                      final height = MediaQuery.of(context).size.height * 0.80;
                                      return Container(
                                        width: width,
                                        height: height,
                                        child: Material(
                                          color: Theme.of(context).cardColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Liber Primus Pages'),
                                                Builder(builder: (_) {
                                                  final basePath = Directory('${Directory.current.path}/liberprimus_pages/');

                                                  final rawFileList = basePath.listSync();

                                                  List<String> pagesSortedByNum;

                                                  try {
                                                    print('a');
                                                    final pages = List<String>.generate(rawFileList.length, (index) => rawFileList[index].path.split('/').last).sortedByString((element) => element);
                                                    pages.removeWhere((element) => !element.endsWith('.txt'));
                                                    print('b');

                                                    final numberRegex = RegExp('[^0-9]');
                                                    print('c');
                                                    pagesSortedByNum = pages.sortedByNum((element) {
                                                      //print('parsing $element');
                                                      return int.parse(element.replaceAll(numberRegex, ''));
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                  }

                                                  return Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: Material(
                                                        color: Theme.of(context).scaffoldBackgroundColor,
                                                        child: ListView.builder(
                                                          itemCount: pagesSortedByNum.length,
                                                          itemBuilder: (context, index) {
                                                            final rawPageName = pagesSortedByNum[index];
                                                            final pageName = pagesSortedByNum[index].replaceAll('.txt', '');

                                                            return Material(
                                                              color: Theme.of(context).scaffoldBackgroundColor,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  print('loading ${basePath.path + rawPageName}');
                                                                  setState(() {
                                                                    GetIt.I<Cipher>().load_from_file(basePath.path + rawPageName);
                                                                  });

                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(4.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [Text(pageName), const Icon(Icons.arrow_right)],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Material(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                              'Close',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
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
                            break;

                          case 2:
                            {
                              showDialog<void>(
                                barrierColor: Colors.black.withOpacity(0.30),
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Builder(
                                    builder: (context) {
                                      final width = MediaQuery.of(context).size.width * 0.30;
                                      final height = MediaQuery.of(context).size.height * 0.80;
                                      return Container(
                                        width: width,
                                        height: height,
                                        child: Material(
                                          color: Theme.of(context).cardColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Solved Liber Primus Pages'),
                                                Builder(builder: (_) {
                                                  final basePath = Directory('${Directory.current.path}/solved_liberprimus_pages/');

                                                  final rawFileList = basePath.listSync();

                                                  List<String> pagesSortedByNum;

                                                  try {
                                                    print('a');
                                                    final pages = List<String>.generate(rawFileList.length, (index) => rawFileList[index].path.split('/').last).sortedByString((element) => element);
                                                    pages.removeWhere((element) => !element.endsWith('.txt'));
                                                    print('b');

                                                    final numberRegex = RegExp('[^0-9]');
                                                    print('c');
                                                    pagesSortedByNum = pages.sortedByNum((element) {
                                                      //print('parsing $element');
                                                      return int.parse(element.replaceAll(numberRegex, ''));
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                  }

                                                  return Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: Material(
                                                        color: Theme.of(context).scaffoldBackgroundColor,
                                                        child: ListView.builder(
                                                          itemCount: pagesSortedByNum.length,
                                                          itemBuilder: (context, index) {
                                                            final rawPageName = pagesSortedByNum[index];
                                                            final pageName = pagesSortedByNum[index].replaceAll('.txt', '');

                                                            return Material(
                                                              color: Theme.of(context).scaffoldBackgroundColor,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  print('loading ${basePath.path + rawPageName}');
                                                                  setState(() {
                                                                    GetIt.I<Cipher>().load_from_file(basePath.path + rawPageName);
                                                                  });

                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(4.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [Text(pageName), const Icon(Icons.arrow_right)],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Material(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                              'Close',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
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
                            break;

                          case 3:
                            {
                              showDialog<void>(
                                barrierColor: Colors.black.withOpacity(0.30),
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Builder(
                                    builder: (context) {
                                      final width = MediaQuery.of(context).size.width * 0.30;
                                      final height = MediaQuery.of(context).size.height * 0.80;
                                      return Container(
                                        width: width,
                                        height: height,
                                        child: Material(
                                          color: Theme.of(context).cardColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Challenge / Training pages'),
                                                Builder(builder: (_) {
                                                  final basePath = Directory('${Directory.current.path}/training_pages/');

                                                  final rawFileList = basePath.listSync();

                                                  List<String> pagesSortedByNum;

                                                  try {
                                                    print('a');
                                                    final pages = List<String>.generate(rawFileList.length, (index) => rawFileList[index].path.split('/').last).sortedByString((element) => element);
                                                    pages.removeWhere((element) => !element.endsWith('.txt'));
                                                    print('b');

                                                    final numberRegex = RegExp('[^0-9]');
                                                    print('c');
                                                    pagesSortedByNum = pages.sortedByNum((element) {
                                                      //print('parsing $element');
                                                      return int.parse(element.replaceAll(numberRegex, ''));
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                  }

                                                  return Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: Material(
                                                        color: Theme.of(context).scaffoldBackgroundColor,
                                                        child: ListView.builder(
                                                          itemCount: pagesSortedByNum.length,
                                                          itemBuilder: (context, index) {
                                                            final rawPageName = pagesSortedByNum[index];
                                                            final pageName = pagesSortedByNum[index].replaceAll('.txt', '');

                                                            return Material(
                                                              color: Theme.of(context).scaffoldBackgroundColor,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  print('loading ${basePath.path + rawPageName}');
                                                                  setState(() {
                                                                    GetIt.I<Cipher>().load_from_file(basePath.path + rawPageName);
                                                                  });

                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(4.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [Text(pageName), const Icon(Icons.arrow_right)],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Material(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                              'Close',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
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
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text('Load Cipher'),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Load page from LP'),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: Text('Load solved page from LP'),
                        ),
                        const PopupMenuItem<int>(
                          value: 3,
                          child: Text('Load challenge/training page'),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'File',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: Material(
                elevation: 2,
                color: Theme.of(context).cardColor,
                child: TabBar(
                  onTap: (index) {},
                  controller: tabController,
                  tabs: const [Tab(text: 'Analyze'), Tab(text: 'Solve'), Tab(text: 'Train')],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AnalyzePage(),
                  SolvePage(),
                  Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
