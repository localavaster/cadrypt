import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'dialogs/select_challenge_cipher.dart';
import 'dialogs/select_cicada_message.dart';
import 'dialogs/select_cipher_from_path.dart';
import 'dialogs/select_liber_primus_page.dart';
import 'global/cipher.dart';
import 'global/keyboard_listener.dart';
import 'global/settings.dart';
import 'pages/analyze/analyze.dart';
import 'pages/analyze/analyze_state.dart';
import 'pages/misc/misc.dart';
import 'pages/solve/solve.dart';
import 'services/crib_cache.dart';
import 'services/oeis_scraper.dart';
import 'tools/comparepages.dart';
import 'tools/cribsmallwords.dart';
import 'tools/dumppages.dart';
import 'tools/factor.dart';
import 'tools/findcribs.dart';
import 'tools/frequencyanalysis.dart';
import 'tools/globalfindcribs.dart';
import 'tools/globalsentencematcher.dart';
import 'tools/ioc.dart';
import 'tools/largest_words.dart';
import 'tools/prime.dart';
import 'tools/sequence_finder.dart';
import 'tools/solvedwordcount.dart';
import 'tools/wordlist.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.instance.registerSingleton(Settings());

  GetIt.instance.registerSingleton(Cipher());

  // load a random unsolved page
  final basePath = Directory('${Directory.current.path}/liberprimus_pages/'.replaceAll(RegExp(r'[\/]'), '/'));

  // 3 shuffles the magic number baby
  final rawFileList = basePath.listSync()
    ..shuffle()
    ..shuffle()
    ..shuffle()
    ..removeWhere((element) => !element.path.contains(('chapter')));

  // remove the huge ones, loading takes way too long
  rawFileList.removeWhere((element) => element.path.contains('spiralbranch'));
  rawFileList.removeWhere((element) => element.path.contains('mobius') && !element.path.contains('number'));

  print('Loading Page: ${rawFileList.first.path}');
  GetIt.instance<Cipher>().load_from_file(rawFileList.first.path);

  GetIt.instance.registerSingleton(Keyboard());

  GetIt.instance.registerSingleton(CribCache());

  GetIt.instance.registerSingleton(AnalyzeState());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (event) {
        final keyboardListener = GetIt.I<Keyboard>();

        if (event.runtimeType == RawKeyDownEvent) {
          keyboardListener.onKeyDown(event.logicalKey.keyId);
        } else if (event.runtimeType == RawKeyUpEvent) {
          keyboardListener.onKeyUp(event.logicalKey.keyId);
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cadrypt',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'SegoeUISymbol',
          inputDecorationTheme: const InputDecorationTheme(filled: true),
        ),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

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
                              selectCipherFromPath(context, setState);
                            }
                            break;

                          case 1:
                            {
                              selectCicadaMessage(context, setState);
                            }
                            break;

                          case 2:
                            {
                              selectLiberPrimusPageDialog(context, setState);
                            }
                            break;

                          case 3:
                            {
                              selectChallengeCipher(context, setState);
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
                          child: Text('Load Cicada Message'),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: Text('Load Page from LP'),
                        ),
                        const PopupMenuItem<int>(
                          value: 3,
                          child: Text('Load Challenge/Training page'),
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
                    PopupMenuButton<int>(
                      onSelected: (int result) async {
                        switch (result) {
                          case 0:
                            {
                              toolIocAnalysis(context);
                            }
                            break;

                          case 1:
                            {
                              toolFrequencyAnalysis(context);
                            }
                            break;

                          case 2:
                            {
                              await OEISParser().parse_sequences();
                              //toolShuffleTest(context);
                            }
                            break;

                          case 3:
                            {
                              toolFactorAnalysis(context);
                            }
                            break;

                          case 4:
                            {
                              toolLargestWords(context);
                            }
                            break;

                          case 5:
                            {
                              toolSequenceFinder(context);
                            }
                            break;

                          case 6:
                            {
                              toolWordListViewer(context);
                            }
                            break;

                          case 7:
                            {
                              toolPrimeAnalysis(context);
                            }
                            break;

                          case 8:
                            {
                              toolCribSmallWords(context);
                            }
                            break;
                          case 9:
                            {
                              toolDumpPageInfo(context);
                            }
                            break;
                          case 10:
                            {
                              toolFindCribs(context);
                            }
                            break;

                          case 11:
                            {
                              toolGlobalFindCribs(context);
                            }
                            break;
                          case 12:
                            {
                              toolGlobalFindSentence(context);
                            }
                            break;
                          case 13:
                            {
                              toolSolvedWordCount(context);
                            }
                            break;
                          case 14:
                            {
                              toolComparePages(context);
                              //toolEnglishWordCount(context);
                            }
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(value: 0, child: Text('IoC Analysis')),
                        const PopupMenuItem<int>(value: 1, child: Text('Frequency Analysis')),
                        const PopupMenuItem<int>(value: 2, child: Text('Shuffle Test')),
                        const PopupMenuItem<int>(value: 3, child: Text('Factor Analysis')),
                        const PopupMenuItem<int>(value: 4, child: Text('Largest Words')),
                        const PopupMenuItem<int>(value: 5, child: Text('Sequence Finder')),
                        const PopupMenuItem<int>(value: 6, child: Text('Word List Viewer')),
                        const PopupMenuItem<int>(value: 7, child: Text('Prime Analysis')),
                        const PopupMenuItem<int>(value: 8, child: Text('Crib Small Words')),
                        const PopupMenuItem<int>(value: 9, child: Text('Dump Pages')),
                        const PopupMenuItem<int>(value: 10, child: Text('Find Cribs')),
                        const PopupMenuItem<int>(value: 11, child: Text('Global Find Cribs')),
                        const PopupMenuItem<int>(value: 12, child: Text('Global Find Sentence')),
                        const PopupMenuItem<int>(value: 13, child: Text('Solved Word Count')),
                        const PopupMenuItem<int>(value: 14, child: Text('Compare Pages')),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Tools',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    PopupMenuButton<int>(
                      onSelected: (int result) {
                        switch (result) {
                          case 0:
                            {
                              setState(() {
                                GetIt.instance<Settings>().switch_to_cicada_mode();
                              });
                            }
                            break;

                          case 1:
                            {
                              setState(() {
                                GetIt.instance<Settings>().switch_to_english_mode();
                              });
                            }
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text('Cicada'),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('English'),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Cipher Language',
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
                  tabs: const [Tab(text: 'Analyze'), Tab(text: 'Solve'), Tab(text: 'Misc')],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AnalyzePage(
                    key: GetIt.I<AnalyzeState>().global_key,
                  ),
                  SolvePage(),
                  MiscPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
