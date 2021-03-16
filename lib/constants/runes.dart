// ENGLISH RELATED
final List<String> alphabet = 'abcdefghijklmnopqrstuvwxyz'.toLowerCase().split('');

// CICADA RELATED
final gematriaRegex = RegExp('((th)|(ing)|(ea)|(oe)|(io)|(eo))|(.)', dotAll: true, caseSensitive: false);

const List<String> runes = ['ᚠ', 'ᚢ', 'ᚦ', 'ᚩ', 'ᚱ', 'ᚳ', 'ᚷ', 'ᚹ', 'ᚻ', 'ᚾ', 'ᛁ', 'ᛄ', 'ᛇ', 'ᛈ', 'ᛉ', 'ᛋ', 'ᛏ', 'ᛒ', 'ᛖ', 'ᛗ', 'ᛚ', 'ᛝ', 'ᛟ', 'ᛞ', 'ᚪ', 'ᚫ', 'ᚣ', 'ᛡ', 'ᛠ'];

const List<String> doubleRunes = ['ᛇ', 'ᛝ', 'ᛟ', 'ᚫ', 'ᛡ', 'ᛠ'];

const List<String> runeEnglish = ['f', 'u', 'th', 'o', 'r', 'c', 'g', 'w', 'h', 'n', 'i', 'j', 'eo', 'p', 'x', 's', 't', 'b', 'e', 'm', 'l', 'ing', 'oe', 'd', 'a', 'ae', 'y', 'io', 'ea'];

const List<String> altRuneEnglish = ['', 'v', '', '', '', 'k', '', '', '', '', '', '', '', '', '', 'z', 't', 'b', 'e', 'm', 'l', 'ing', 'oe', 'd', 'a', 'ae', 'y', 'io', 'ea'];

const List<String> englishDoubleRunes = ['th', 'eo', 'ing', 'oe', 'ae', 'ea'];

const Map<String, String> runeToEnglish = {'ᚠ': 'F', 'ᚢ': 'U', 'ᚦ': 'TH', 'ᚩ': 'O', 'ᚱ': 'R', 'ᚳ': 'CK', 'ᚷ': 'G', 'ᚹ': 'W', 'ᚻ': 'H', 'ᚾ': 'N', 'ᛁ': 'I', 'ᛄ': 'J', 'ᛇ': 'EO', 'ᛈ': 'P', 'ᛉ': 'X', 'ᛋ': 'S', 'ᛏ': 'T', 'ᛒ': 'B', 'ᛖ': 'E', 'ᛗ': 'M', 'ᛚ': 'L', 'ᛝ': 'ING', 'ᛟ': 'OE', 'ᛞ': 'D', 'ᚪ': 'A', 'ᚫ': 'AE', 'ᚣ': 'Y', 'ᛡ': 'IO', 'ᛠ': 'EA'};

const Map<String, int> letterToPrime = {'F': 2, 'U': 3, 'TH': 5, 'O': 7, 'R': 11, 'C': 13, 'G': 17, 'W': 19, 'H': 23, 'N': 29, 'I': 31, 'J': 37, 'EO': 41, 'P': 43, 'X': 47, 'S': 53, 'T': 59, 'B': 61, 'E': 67, 'M': 71, 'L': 73, 'ING': 79, 'OE': 83, 'D': 89, 'A': 97, 'AE': 101, 'Y': 103, 'IO': 107, 'EA': 109};

const Map<String, int> altLetterToPrime = {'F': 2, 'V': 3, 'TH': 5, 'O': 7, 'R': 11, 'K': 13, 'G': 17, 'W': 19, 'H': 23, 'N': 29, 'I': 31, 'J': 37, 'EO': 41, 'P': 43, 'X': 47, 'Z': 53, 'T': 59, 'B': 61, 'E': 67, 'M': 71, 'L': 73, 'ING': 79, 'OE': 83, 'D': 89, 'A': 97, 'AE': 101, 'Y': 103, 'IO': 107, 'EA': 109};

const Map<String, String> runePositions = {'ᚠ': '0', 'ᚢ': '1', 'ᚦ': '2', 'ᚩ': '3', 'ᚱ': '4', 'ᚳ': '5', 'ᚷ': '6', 'ᚹ': '7', 'ᚻ': '8', 'ᚾ': '9', 'ᛁ': '10', 'ᛄ': '11', 'ᛇ': '12', 'ᛈ': '13', 'ᛉ': '14', 'ᛋ': '15', 'ᛏ': '16', 'ᛒ': '17', 'ᛖ': '18', 'ᛗ': '19', 'ᛚ': '20', 'ᛝ': '21', 'ᛟ': '22', 'ᛞ': '23', 'ᚪ': '24', 'ᚫ': '25', 'ᚣ': '26', 'ᛡ': '27', 'ᛠ': '28'};

const Map<String, String> runePrimes = {'ᚠ': '2', 'ᚢ': '3', 'ᚦ': '5', 'ᚩ': '7', 'ᚱ': '11', 'ᚳ': '13', 'ᚷ': '17', 'ᚹ': '19', 'ᚻ': '23', 'ᚾ': '29', 'ᛁ': '31', 'ᛄ': '37', 'ᛇ': '41', 'ᛈ': '43', 'ᛉ': '47', 'ᛋ': '53', 'ᛏ': '59', 'ᛒ': '61', 'ᛖ': '67', 'ᛗ': '71', 'ᛚ': '73', 'ᛝ': '79', 'ᛟ': '83', 'ᛞ': '89', 'ᚪ': '97', 'ᚫ': '101', 'ᚣ': '103', 'ᛡ': '107', 'ᛠ': '109'};

const Map<String, String> englishToRune = {'ᚠ': 'F', 'ᚢ': 'U', 'ᚦ': 'TH', 'ᚩ': 'O', 'ᚱ': 'R', 'ᚳ': 'CK', 'ᚷ': 'G', 'ᚹ': 'W', 'ᚻ': 'H', 'ᚾ': 'N', 'ᛁ': 'I', 'ᛄ': 'J', 'ᛇ': 'EO', 'ᛈ': 'P', 'ᛉ': 'X', 'ᛋ': 'S', 'ᛏ': 'T', 'ᛒ': 'B', 'ᛖ': 'E', 'ᛗ': 'M', 'ᛚ': 'L', 'ᛝ': 'ING', 'ᛟ': 'OE', 'ᛞ': 'D', 'ᚪ': 'A', 'ᚫ': 'AE', 'ᚣ': 'Y', 'ᛡ': 'IO', 'ᛠ': 'EA'};

const List<int> primes = [0, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29];

const List<int> prime_with_totient = [0, 1, 2, 4, 6, 10, 12, 16, 18, 22, 28];

final List<int> gpPrimesMod29 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 0, 2, 8, 12, 14, 18, 24, 1, 3, 9, 13, 15, 21, 25, 2, 10, 14, 16, 20, 22];

//final List<int> square_sums = [272, 138, 341, 131, 151, 366, 199, 130, 320, 18, 226, 245, 91, 245, 226, 18, 320, 130, 199, 366, 151, 131, 341, 138, 272, 434, 1311, 312, 278, 966, 204, 812, 934, 280, 1071, 626, 620, 809, 620, 626, 1071, 280, 934, 812, 204, 966, 278, 312, 1311, 434].toSet().toList();

final List<int> square_sums = [
  272,
  138,
  341,
  131,
  151,
  366,
  199,
  130,
  320,
  18,
  226,
  245,
  91,
  245,
  226,
  18,
  320,
  130,
  199,
  366,
  151,
  131,
  341,
  138,
  272,
].toSet().toList();

class Conversions {
  static int runeToPrime(String rune) {
    return int.tryParse(runePrimes[rune]);
  }

  static String positionToRune(int position) {
    return runes.elementAt(position % runes.length);
  }

  static int runeToPosition(String rune) {
    return runes.indexOf(rune);
  }
}
