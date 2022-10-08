class Mala implements Comparable<Mala> {
  String date;
  int count;
  int japs;
  bool selected = false;

  static String key = "Mala";

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
}
