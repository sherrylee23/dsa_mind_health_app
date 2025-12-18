class UserModel {
  final int id;
  final String name;
  final String email;
  final String gender;
  final int age;
  final String password;
  final String createdOn;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.password,
    required this.createdOn,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) => UserModel(
    id: data['id'],
    name: data['name'],
    email: data['email'],
    gender: data['gender'],
    age: data['age'],
    password: data['password'],
    createdOn: data['createdOn'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'gender': gender,
    'age': age,
    'password': password,
    'createdOn': createdOn,
  };

  // For INSERT (no id → AUTOINCREMENT)
  Map<String, dynamic> toMapForInsert() => {
    'name': name,
    'email': email,
    'gender': gender,
    'age': age,
    'password': password,
    'createdOn': createdOn,
  };
}
