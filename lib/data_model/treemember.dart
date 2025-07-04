class TreeMember {
  String name;
  int? c;
  final int? id;

  TreeMember(this.name, this.c, [this.id]);

  TreeMember.fromJson(Map<dynamic, dynamic> json)
    : id = json['id'],
      name = json['name'],
      c = json['c'];

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'c': c};
}
