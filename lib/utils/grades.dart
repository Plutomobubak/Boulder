import 'package:boulder/services/settings_sys.dart';

Future<Map<String, int>> getScale() async {
  final selectedScale = await Settings.get("gradeSystem", "V-Scale");
  switch (selectedScale) {
    case 'V-Scale':
      return VScale;
    case 'Yosemite':
      return YosemiteScale;
    case 'French':
      return FrenchScale;
    default:
      return VScale;
  }
}

Future<Map<int, String>> getReverseScale() async {
  final selectedScale = await Settings.get("gradeSystem", "V-Scale");
  switch (selectedScale) {
    case 'V-Scale':
      return ReverseVScale;
    case 'Yosemite':
      return ReverseYosemiteScale;
    case 'French':
      return ReverseFrenchScale;
    default:
      return ReverseVScale;
  }
}

final Map<String, int> VScale = {
  'V0': 1,
  'V1': 4,
  'V2': 7,
  'V3': 8,
  'V4': 9,
  'V5': 11,
  'V6': 13,
  'V7': 14,
  'V8': 15,
  'V9': 16,
  'V10': 18,
  'V11': 19,
  'V12': 20,
  'V13': 21,
  'V14' : 22,
  'V15': 23,
  'V16': 24,
};
final Map<int, String> ReverseVScale = {
  0: 'V0',
  1: 'V0',
  2: 'V0',
  3: 'V1',
  4: 'V1',
  5: 'V1',
  6: 'V2',
  7: 'V2',
  8: 'V3',
  9: 'V4',
  10: 'V5',
  11: 'V5',
  12: 'V6',
  13: 'V6',
  14: 'V7',
  15: 'V8',
  16: 'V9',
  17: 'V10',
  18: 'V10',
  19: 'V11',
  20: 'V12',
  21: 'V13',
  22: 'V14',
  23: 'V15',
  24: 'V16',
};

final Map<String, int> FrenchScale = {
  '4a': 0,
  '4b': 1,
  '4c': 2,
  '5a': 3,
  '5b': 4,
  '5c': 5,
  '6a': 6,
  '6a+': 8,
  '6b': 9,
  '6b+': 10,
  '6c': 11,
  '6c+': 12,
  '7a': 13,
  '7a+': 14,
  '7b': 15,
  '7b+': 16,
  '7c': 17,
  '7c+': 18,
  '8a': 19,
  '8a+': 20,
  '8b': 21,
  '8b+': 22,
  '8c': 23,
  '8c+': 24,
  '9a': 25,
  '9a+': 26,
  '9b': 27,
  '9b+': 28,
};
final Map<String, int> YosemiteScale = {
  '5.4': 0,
  '5.5': 1,
  '5.6': 2,
  '5.7': 3,
  '5.8': 4,
  '5.9': 5,
  '5.10a': 6,
  '5.10b': 7,
  '5.10c': 8,
  '5.10d': 9,
  '5.11a': 10,
  '5.11b': 11,
  '5.11c': 12,
  '5.11d': 13,
  '5.12a': 14,
  '5.12b': 15,
  '5.12c': 16,
  '5.12d': 17,
  '5.13a': 18,
  '5.13b': 19,
  '5.13c': 20,
  '5.13d': 21,
  '5.14a': 22,
  '5.14b': 23,
  '5.14c': 24,
  '5.14d': 25,
  '5.15a': 26,
  '5.15b': 27,
  '5.15c': 28,
};
final Map<int, String> ReverseFrenchScale = {
  0: '4a',
  1: '4b',
  2: '4c',
  3: '5a',
  4: '5b',
  5: '5c',
  6: '6a',
  7: '6a',  // closer to 6a (6) than 6a+ (8)
  8: '6a+',
  9: '6b',
  10: '6b+',
  11: '6c',
  12: '6c+',
  13: '7a',
  14: '7a+',
  15: '7b',
  16: '7b+',
  17: '7c',
  18: '7c+',
  19: '8a',
  20: '8a+',
  21: '8b',
  22: '8b+',
  23: '8c',
  24: '8c+',
  25: '9a',
  26: '9a+',
  27: '9b',
  28: '9b+',
};

final Map<int, String> ReverseYosemiteScale = {
  0: '5.4',
  1: '5.5',
  2: '5.6',
  3: '5.7',
  4: '5.8',
  5: '5.9',
  6: '5.10a',
  7: '5.10b',
  8: '5.10c',
  9: '5.10d',
  10: '5.11a',
  11: '5.11b',
  12: '5.11c',
  13: '5.11d',
  14: '5.12a',
  15: '5.12b',
  16: '5.12c',
  17: '5.12d',
  18: '5.13a',
  19: '5.13b',
  20: '5.13c',
  21: '5.13d',
  22: '5.14a',
  23: '5.14b',
  24: '5.14c',
  25: '5.14d',
  26: '5.15a',
  27: '5.15b',
  28: '5.15c',
};


