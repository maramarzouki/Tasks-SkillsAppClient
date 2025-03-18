class User {
  int? id;
  String email, password;
  String? firstName, lastName;
  User({
    this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.password,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      'email': email,
      'password': password,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
    };
  }

  // Create a UserModel from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] ?? "",
      password: json['password'] ?? "",
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
    );
  }
}
