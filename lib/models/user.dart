class User {
  User({this.email, this.firstName, this.lastName});

  String firstName, lastName, email;

  String getFirstName() => this.firstName;
  String getLastName() => this.lastName;
  String getEmail() => this.email;
}
