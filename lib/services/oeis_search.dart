import 'dart:io';
import 'package:dio/dio.dart';

// A class containing functions relating to https://www.oeis.org
class OEISLookUp {
  File cacheFile;
  Dio client;
  OEISLookUp() {
    BaseOptions options = BaseOptions(
      baseUrl: "https://www.oeis.org/",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );

    client = Dio(options);

    // cache file

    cacheFile = File('${Directory.current.path}/invalid_oeis_sequence_cache.txt');
    if (!cacheFile.existsSync()) {
      cacheFile.createSync();
    }
  }

  void cache_sequence_to_file(List<int> sequence) {
    cacheFile.writeAsStringSync('${sequence.join(',')}\n', mode: FileMode.append);
  }

  Future<bool> oeisContainsSequence(List<int> sequence) async {
    List<int> copySequence = List<int>.from(sequence);

    copySequence.removeWhere((element) => element == 0);

    copySequence = copySequence.getRange(0, 5.clamp(0, copySequence.length).toInt()).toList();

    final invalidCacheFileLines = cacheFile.readAsLinesSync();
    if (invalidCacheFileLines.contains(copySequence.join(','))) {
      return false;
    }

    final request = await client.get('search', queryParameters: {
      'q': copySequence.join(','),
      'language': 'english',
      'go': 'search',
    });

    final response_body = request.data.toString();

    if (response_body.contains('Sorry, but')) {
      // truly not the best, but is it worth parsing html? // TODO: find a keyword closer to the beginning of the HTML body or recode this entirely
      cache_sequence_to_file(copySequence);
      return false;
    } else {
      return true;
    }
  }
}
