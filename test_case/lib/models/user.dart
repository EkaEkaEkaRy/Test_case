class User {
  final int id;
  String name;
  String surname;
  String image;

  User(
      {required this.id,
      required this.name,
      required this.surname,
      required this.image});

  factory User.parseJson(Map<String, dynamic> json) {
    return User(
        id: json['ID'],
        name: json['Name'],
        surname: json['Surname'],
        image: json['Image']);
  }
}
