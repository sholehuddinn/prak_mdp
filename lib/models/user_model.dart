class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String createdAt;
  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.createdAt,
  });
// Melakukan parsing data pengguna dari format JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
// Mengubah data pengguna menjadi JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'created_at': createdAt,
    };
  }
}