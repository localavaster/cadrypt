import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:string_splitter/string_splitter.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:collection/collection.dart';

import '../global/cipher.dart';

void toolShuffleTest(BuildContext context) {
  showDialog<void>(
    barrierColor: Colors.black.withOpacity(0.30),
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (context, setState) {
          final chunkTextController = TextEditingController();
          final iterTextController = TextEditingController();
          final width = MediaQuery.of(context).size.width * 0.70;
          final height = MediaQuery.of(context).size.height * 0.80;
          return SizedBox(
            width: width,
            height: height,
            child: Material(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration().copyWith(labelText: 'Chunks'),
                        controller: chunkTextController,
                      ),
                      TextField(
                        decoration: const InputDecoration().copyWith(labelText: 'Iterations'),
                        controller: iterTextController,
                      ),
                      FlatButton(
                        onPressed: () async {
                          final chunks = int.tryParse(chunkTextController.value.text);
                          final iterations = int.tryParse(iterTextController.value.text);

                          if (chunks == null || iterations == null) return;

                          final List<int> repeatedCounts = [];

                          for (int i = 0; i < iterations; i++) {
                            final flatCipher = GetIt.I<Cipher>().get_flat_cipher();
                            final chunkedFlatCipher = StringSplitter.chunk(flatCipher, chunks);
                            final shuffledChunkedFlatCipher = <String>[];

                            for (final chunk in chunkedFlatCipher) {
                              final splitChunk = chunk.split('');
                              splitChunk.shuffle();

                              shuffledChunkedFlatCipher.add(splitChunk.join());
                            }

                            final repeatedBigrams = GetIt.I<Cipher>().get_repeated_ngrams(2, text: shuffledChunkedFlatCipher.join());

                            final totalRepeats = repeatedBigrams.values.sum;

                            repeatedCounts.add(totalRepeats);
                          }

                          print('Chunk Size: $chunks');
                          print('Iterations: $iterations');
                          print('Regular: ${GetIt.I<Cipher>().get_repeated_ngrams(2, text: GetIt.I<Cipher>().get_flat_cipher()).values.sum}');
                          print('Shuffled Min: ${repeatedCounts.min()}');
                          print('Shuffled Max: ${repeatedCounts.max()}');
                        },
                        child: const Text('Run Test'),
                      )
                    ],
                  )),
            ),
          );
        },
      ),
    ),
  );
}
