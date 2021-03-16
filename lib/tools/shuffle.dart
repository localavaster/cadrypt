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

                          final List<int> repeated_counts = [];

                          for (int i = 0; i < iterations; i++) {
                            final flat_cipher = GetIt.I<Cipher>().get_flat_cipher();
                            final chunked_flat_cipher = StringSplitter.chunk(flat_cipher, chunks);
                            final shuffled_chunked_flat_cipher = <String>[];

                            for (final chunk in chunked_flat_cipher) {
                              final split_chunk = chunk.split('');
                              split_chunk.shuffle();

                              shuffled_chunked_flat_cipher.add(split_chunk.join());
                            }

                            final repeated_bigrams = GetIt.I<Cipher>().get_repeated_ngrams(2, text: shuffled_chunked_flat_cipher.join());

                            final total_repeats = repeated_bigrams.values.sum;

                            repeated_counts.add(total_repeats);
                          }

                          print('Chunk Size: $chunks');
                          print('Iterations: $iterations');
                          print('Regular: ${GetIt.I<Cipher>().get_repeated_ngrams(2, text: GetIt.I<Cipher>().get_flat_cipher()).values.sum}');
                          print('Shuffled Min: ${repeated_counts.min()}');
                          print('Shuffled Max: ${repeated_counts.max()}');
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
