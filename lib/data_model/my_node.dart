class MyNode {
  final int id;
  final String label;

  const MyNode(this.id, this.label);

  @override
  String toString() {
    return "$id---$label";
  }

  MyNode.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        label = json['label'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
      };
}
