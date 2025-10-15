class UserModel {
  final String id;
  final String email;
  final String? name;

  UserModel({
    required this.id,
    required this.email,
    this.name,
  });

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
    };
  }
}