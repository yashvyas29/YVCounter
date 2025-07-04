// import 'package:isar/isar.dart';
// part 'mala.g.dart';

// @collection
class Mala implements Comparable<Mala> {
  // final Id id = Isar.autoIncrement;
  // Id get isarId => fastHash(date);
  // @Index(unique: true, replace: true, caseSensitive: false)
  DateTime date;
  int count;
  int japs;

  static const String key = "Mala";
  static const japsPerMala = 108;

  Mala(this.date, this.count, this.japs);

  Mala.fromJson(Map<String, dynamic> json)
    : date = DateTime.parse(json['date']),
      count = json['count'],
      japs = json['japs'];

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'count': count,
    'japs': japs,
  };

  @override
  int compareTo(Mala other) => other.date.compareTo(date);

  @override
  bool operator ==(Object other) => other is Mala && other.date == date;

  @override
  int get hashCode => date.hashCode;

  /*
  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }
  */
}
