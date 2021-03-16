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

  bool localOeisContainsSequnece(List<int> sequence) {
    final sequence_formatted = ',${sequence.getRange(0, 6.clamp(0, sequence.length).toInt()).join(',')}';

    final invalidCacheFileLines = cacheFile.readAsLinesSync();
    final sequenceInInvalidCache = invalidCacheFileLines.where((element) => element == sequence_formatted);
    if (sequenceInInvalidCache.isNotEmpty) return false;

    for (final oeisSequence in localSequences) {
      if (oeisSequence.contains(sequence_formatted)) return true;
    }

    cache_sequence_to_file(sequence_formatted);
    return false;
  }

  Future<bool> internetOeisContainsSequence(List<int> sequence) async {
    /*List<int> firstPartOfSequence = List<int>.from(sequence).sublist(0, 5.clamp(0, sequence.length).toInt());
    print('checking sequence $firstPartOfSequence');

    final invalidCacheFileLines = cacheFile.readAsLinesSync();
    if (invalidCacheFileLines.contains(firstPartOfSequence.join(','))) {
      return false;
    }

    final request = await client.get('search', queryParameters: {
      'q': firstPartOfSequence.join(','),
      'language': 'english',
      'go': 'search',
    });

    final response_body = request.data.toString();

    if (response_body.contains('Sorry, but')) {
      // truly not the best, but is it worth parsing html? // TODO: find a keyword closer to the beginning of the HTML body or recode this entirely
      cache_sequence_to_file(firstPartOfSequence);
      return false;
    } else {
      return true;
    }*/
  }
}
