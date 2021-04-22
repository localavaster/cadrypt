import 'dart:io';
import 'package:dio/dio.dart';

// A class containing functions relating to https://www.oeis.org
class OEISLookUp {
  OEISLookUp({this.localLookUp}) {
    if (!localLookUp) {
      final BaseOptions options = BaseOptions(
        baseUrl: 'https://www.oeis.org/',
        connectTimeout: 5000,
        receiveTimeout: 3000,
      );

      client = Dio(options);

      cacheFile = File('${Directory.current.path}/invalid_oeis_sequence_cache.txt');
      if (!cacheFile.existsSync()) {
        cacheFile.createSync();
      }
    } else {
      cacheFile = File('${Directory.current.path}/invalid_oeis_sequence_cache.txt');
      if (!cacheFile.existsSync()) {
        cacheFile.createSync();
      }

      localFile = File('${Directory.current.path}/mod29_oeis_sequences.txt');
      localSequences = localFile.readAsLinesSync().toSet().toList();
    }
  }

  final bool localLookUp;
  List<String> localSequences;

  List<List<int>> localSequencesList;

  File localFile;
  File cacheFile;
  Dio client;

  void cache_sequence_to_file(String sequence) {
    cacheFile.writeAsStringSync('$sequence\n', mode: FileMode.append);
  }

  int localOeisContainsSequnece(List<int> sequence) {
    final sequenceFormatted = ',${sequence.getRange(0, 6.clamp(0, sequence.length).toInt()).join(',')}';

    final invalidCacheFileLines = cacheFile.readAsLinesSync();
    final sequenceInInvalidCache = invalidCacheFileLines.where((element) => element == sequenceFormatted);
    if (sequenceInInvalidCache.isNotEmpty) return -1;

    int sequence_number = 1;
    for (final oeisSequence in localSequences) {
      if (oeisSequence.contains(sequenceFormatted)) return sequence_number;

      sequence_number++;
    }

    cache_sequence_to_file(sequenceFormatted);
    return -1;
  }
}
