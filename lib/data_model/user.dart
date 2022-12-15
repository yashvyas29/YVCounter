class User implements Comparable<User> {
  String? name;
  String email;
  String id;

  static String key = "User";

  User(this.name, this.email, this.id);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'id': id,
      };

  @override
  int compareTo(User other) => other.id.compareTo(id);
}
