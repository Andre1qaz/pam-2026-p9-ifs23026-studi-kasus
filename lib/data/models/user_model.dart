class User {
  final int id;
  final String username;

  const User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> j) =>
      User(id: j['id'] as int, username: j['username'] as String);
}
