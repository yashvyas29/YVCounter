class Mala implements Comparable<Mala> {
  String date;
  int count;
  int japs;

  static const String key = "Mala";
  static const japsPerMala = 108;

  Mala(this.date, this.count, this.japs);

  Mala.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        count = json['count'],
        japs = json['japs'];

  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        'japs': japs,
      };

  @override
  int compareTo(Mala other) => other.date.compareTo(date);

  @override
  bool operator ==(Object other) => other is Mala && other.date == date;

  @override
  int get hashCode => date.hashCode;
}
