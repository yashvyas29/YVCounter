class User implements Comparable<User> {
  final String? name;
  final String email;
  final String id;

  static String key = "User";

  const User(this.name, this.email, this.id);

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
