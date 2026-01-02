// Dart checkout suggestion helper
// - Input: remaining score (int)
// - Output: list of throw suggestions like ["T20", "T20", "D20"]
//   where T=triple, D=double, S=single, Bull=50, OBull=25
// Notes:
// - Prioritizes finishing on a double for checkouts (<= 170).
// - Includes well-known pro routes.
// - If checkout isn't possible (e.g., 169), suggests setup shots.

class DartThrow {
  final String label; // e.g., "T20", "D16", "Bull", "OBull", "S19"
  final int value;
  const DartThrow(this.label, this.value);
}

String suggestDartsString(int score) {
  final throwsList = suggestDarts(score);
  if (throwsList.isEmpty) return '';
  return throwsList.join(' + ');
}

List<String> suggestDarts(int score) {
  if (score <= 0 || score > 170) return [];

  // Impossible finishes in standard 501 when you must finish on a double
  const Set<int> deadEnds = {169, 168, 166, 165, 163, 162, 159, 1};

  // Build common singles, doubles, triples
  final List<DartThrow> singles = [
    for (int n = 1; n <= 20; n++) DartThrow('$n', n),
    const DartThrow('OBull', 25),
  ];
  final List<DartThrow> doubles = [
    for (int n = 1; n <= 20; n++) DartThrow('D$n', 2 * n),
    const DartThrow('Bull', 50), // Bull counts as double bull (50)
  ];
  final List<DartThrow> triples = [
    for (int n = 1; n <= 20; n++) DartThrow('T$n', 3 * n),
  ];

  // Known optimal pro checkout routes (partial but solid)
  final Map<int, List<String>> known = {
    170: ['T20', 'T20', 'Bull'],
    167: ['T20', 'T19', 'Bull'],
    164: ['T20', 'T18', 'Bull'],
    161: ['T20', 'T17', 'Bull'],
    160: ['T20', 'T20', 'D20'],
    158: ['T20', 'T20', 'D19'],
    157: ['T20', 'T19', 'D20'],
    156: ['T20', 'T20', 'D18'],
    155: ['T20', 'T19', 'D19'],
    154: ['T20', 'T18', 'D20'],
    153: ['T20', 'T19', 'D18'],
    152: ['T20', 'T20', 'D16'],
    151: ['T20', 'T17', 'D20'],
    150: ['T20', 'T18', 'D18'],
    149: ['T20', 'T19', 'D16'],
    148: ['T20', 'T16', 'D20'],
    147: ['T20', 'T17', 'D18'],
    146: ['T20', 'T18', 'D16'],
    145: ['T20', 'T15', 'D20'],
    144: ['T20', 'T20', 'D12'],
    143: ['T20', 'T17', 'D16'],
    142: ['T20', 'T14', 'D20'],
    141: ['T20', 'T19', 'D12'],
    140: ['T20', 'T20', 'D10'],
    139: ['T19', 'T14', 'D20'], // alt: T20 T13 D20
    138: ['T20', 'T18', 'D12'],
    137: ['T19', 'T16', 'D16'], // alt: T20 T15 D16
    136: ['T20', 'T20', 'D8'],
    135: ['Bull', 'T15', 'D20'], // alt: T20 T17 D12
    134: ['T20', 'T14', 'D16'],
    133: ['T20', 'T19', 'D8'],
    132: ['Bull', 'Bull', 'D16'], // alt: T20 T12 D20
    131: ['T20', 'T13', 'D16'], // alt: T19 T16 D12
    130: ['T20', 'T20', 'D5'], // alt: Bull T20 D20 (risky)
    129: ['T19', 'T16', 'D12'], // alt: T19 T12 D18
    128: ['T18', 'T14', 'D16'], // alt: T20 T20 D4
    127: ['T20', 'T17', 'D8'],
    126: ['T19', 'T19', 'D6'], // alt: T20 T20 D3
    125: ['Bull', 'T20', 'D20'], // alt: 25 T20 D20
    124: ['T20', 'T16', 'D8'],
    123: ['T19', 'T16', 'D9'], // alt: T19 T10 D18
    122: ['T18', 'T18', 'D7'], // alt: T20 T12 D13
    121: ['T20', 'T11', 'D14'], // alt: T17 T10 D20
    120: ['T20', 'S20', 'D20'],
    119: ['T19', 'S12', 'D14'], // alt: T19 S20 D20
    118: ['T20', 'S18', 'D20'],
    117: ['T20', 'S17', 'D20'],
    116: ['T20', 'S16', 'D20'],
    115: ['T20', 'S15', 'D20'],
    114: ['T20', 'S14', 'D20'],
    113: ['T20', 'S13', 'D20'],
    112: ['T20', 'S12', 'D20'],
    111: ['T20', 'S11', 'D20'],
    110: ['T20', 'S10', 'D20'],
    109: ['T20', 'S9', 'D20'],
    108: ['T20', 'S16', 'D16'],
    107: ['T19', 'S18', 'D16'],
    106: ['T20', 'S14', 'D16'],
    105: ['T20', 'S13', 'D16'],
    104: ['T18', 'S18', 'D16'], // alt: T20 S12 D16
    103: ['T20', 'S3', 'D20'], // alt: T19 S14 D16
    102: ['T20', 'S10', 'D16'],
    101: ['T20', 'S9', 'D16'],
    100: ['T20', 'D20'],
    99: ['T19', '10', 'D16'], // using S10
    98: ['T20', 'D19'],
    97: ['T19', 'D20'],
    96: ['T20', 'D18'],
    95: ['T19', 'D19'],
    94: ['T18', 'D20'],
    93: ['T19', 'D18'],
    92: ['T20', 'D16'],
    91: ['T17', 'D20'],
    90: ['T18', 'D18'], // alt: Bull D20
    89: ['T19', 'D16'],
    88: ['T16', 'D20'],
    87: ['T17', 'D18'],
    86: ['T18', 'D16'],
    85: ['T15', 'D20'], // alt: Bull D17
    84: ['T20', 'D12'],
    83: ['T17', 'D16'],
    82: ['Bull', 'D16'], // alt: T14 D20
    81: ['T19', 'D12'],
    80: ['T20', 'D10'],
    79: ['T19', 'D11'],
    78: ['T18', 'D12'],
    77: ['T19', 'D10'],
    76: ['T20', 'D8'],
    75: ['T17', 'D12'],
    74: ['T14', 'D16'], // alt: T18 D10
    73: ['T19', 'D8'],
    72: ['T16', 'D12'], // alt: T12 D18
    71: ['T13', 'D16'], // alt: T17 D10
    70: ['T18', 'D8'], // alt: S20 Bull
    69: ['T19', 'D6'], // alt: S19 Bull
    68: ['T20', 'D4'], // alt: S18 Bull
    67: ['T17', 'D8'], // alt: S17 Bull
    66: ['T10', 'D18'], // alt: S16 Bull
    65: ['T19', 'D4'], // alt: S15 Bull
    64: ['T16', 'D8'], // alt: S14 Bull
    63: ['T13', 'D12'], // alt: S13 Bull
    62: ['T10', 'D16'], // alt: S12 Bull
    61: ['T15', 'D8'], // alt: S11 Bull
    60: ['S20', 'D20'], // or T20 for 1-dart finish
    59: ['S19', 'D20'], // alt: S19 D20
    58: ['S18', 'D20'], // alt: S20 D19
    57: ['S17', 'D20'],
    56: ['S16', 'D20'], // or T16 D4
    55: ['S15', 'D20'], // or T15 D5
    54: ['S14', 'D20'], // or T14 D6
    53: ['S13', 'D20'], // or T13 D7
    52: ['S12', 'D20'], // or 12, D20
    51: ['S19', 'D16'], // or 11, D20
    50: ['D25'], // treat 50 as Bull double
    49: ['S17', 'D16'],
    48: ['S16', 'D16'],
    47: ['S15', 'D16'],
    46: ['S6', 'D20'], // or S14 D16
    45: ['S13', 'D16'],
    44: ['S12', 'D16'],
    43: ['S3', 'D20'], // or S11 D16
    42: ['S10', 'D16'],
    41: ['S9', 'D16'],
    40: ['D20'],
    39: ['S7', 'D16'],
    38: ['D19'],
    37: ['S5', 'D16'],
    36: ['D18'],
    35: ['S3', 'D16'],
    34: ['D17'],
    33: ['S1', 'D16'],
    32: ['D16'],
    31: ['S15', 'D8'],
    30: ['D15'],
    29: ['S13', 'D8'],
    28: ['D14'],
    27: ['S11', 'D8'],
    26: ['D13'],
    25: ['S9', 'D8'], // or S1 D12 depending preference
    24: ['D12'],
    23: ['S7', 'D8'],
    22: ['D11'],
    21: ['S5', 'D8'],
    20: ['D10'],
    19: ['S3', 'D8'],
    18: ['D9'],
    17: ['S1', 'D8'],
    16: ['D8'],
    15: ['S7', 'D4'],
    14: ['D7'],
    13: ['S5', 'D4'],
    12: ['D6'],
    11: ['S3', 'D4'],
    10: ['D5'],
    9: ['S1', 'D4'],
    8: ['D4'],
    7: ['S3', 'D2'],
    6: ['D3'],
    5: ['S1', 'D2'],
    4: ['D2'],
    3: ['S1', 'D1'],
    2: ['D1'],
  };

  // If in known table and <= 170, return it
  if (score <= 170 && known.containsKey(score)) {
    return known[score]!;
  }

  // If a direct double finishes it
  for (final d in doubles) {
    if (d.value == score) return [d.label];
  }

  // If two-dart finish available: triple + double or single + double
  if (score <= 170) {
    // Try triple + double highest first
    for (final t in triples.reversed) {
      for (final d in doubles.reversed) {
        if (t.value + d.value == score) {
          return [t.label, d.label];
        }
      }
    }
    // Try single + double
    for (final s in singles.reversed) {
      for (final d in doubles.reversed) {
        if (s.value + d.value == score) {
          return [s.label, d.label];
        }
      }
    }
  }

  // If three-dart finish possible: try T + T + D patterns greedily
  if (score <= 170) {
    for (final t1 in triples.reversed) {
      for (final t2 in triples.reversed) {
        for (final d in doubles.reversed) {
          if (t1.value + t2.value + d.value == score) {
            return [t1.label, t2.label, d.label];
          }
        }
      }
    }
  }

  // If checkout not possible this visit or score > 170:
  // Suggest best setup: aim big 20s/19s to leave an even number or a common finish.
  // Avoid dead-end leaves.
  if (deadEnds.contains(score)) {
    return [];
  }

  // Generic setup for >170 or awkward totals: prefer T20, then T19, then S20
  // but avoid busting past 170 if you can bring it into range.
  List<String> setup = [];
  int remain = score;

  for (int i = 0; i < 3 && remain > 170; i++) {
    // Try to bring it just under or at 170 using T20/T19 safely
    if (remain - 60 >= 170) {
      setup.add('T20');
      remain -= 60;
    } else if (remain - 57 >= 170) {
      setup.add('T19');
      remain -= 57;
    } else {
      // Last bring-down to reach <=170
      int toDrop = remain - 170;
      // Choose a safe single that matches toDrop if possible
      final sMatch = singles.where((s) => s.value == toDrop).toList();
      if (sMatch.isNotEmpty) {
        setup.add(sMatch.first.label);
        remain -= sMatch.first.value;
      } else {
        // Otherwise use highest safe single not busting
        final sSafe = singles.where((s) => remain - s.value >= 170).toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        if (sSafe.isNotEmpty) {
          final pick = sSafe.last;
          setup.add(pick.label);
          remain -= pick.value;
        } else {
          // fallback
          setup.add('S20');
          remain -= 20;
        }
      }
    }
  }

  // If now in known checkout range and we have darts left, append suggestion
  if (remain <= 170 && remain > 1 && setup.length < 3) {
    final rest = suggestDarts(remain);
    setup.addAll(rest.take(3 - setup.length));
  }

  // Ensure at most 3 throws
  if (setup.isEmpty) setup = ['S20', 'S20', 'S20'];
  return setup.take(3).toList();
}

// Example usage:
// final route = suggestDarts(170);  // ["T20", "T20", "Bull"]
// final route2 = suggestDarts(169); // setup like ["S19", "S20", "S20"]
