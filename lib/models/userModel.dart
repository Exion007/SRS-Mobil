class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final List<String>? friends;
  final int v;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    this.friends,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      friends: json['friends'] != null ? List<String>.from(json['friends'].map((x) => x)) : null,
      v: json['__v'],
    );
  }
}
