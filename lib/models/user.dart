class User {
  final String fullname;
  final String email;
  final String username;
  final String password;

  User({
    required this.fullname,
    required this.email,
    required this.username,
    required this.password,
  });
}

final List<User> userList = [
  User(
    fullname: 'Fakhira Zahra',
    email: 'Fakhirazahra88@gmail.com',
    username: 'Vhirazhr',
    password: '12345678',
  ),
  User(
    fullname: 'Berliana Nada',
    email: 'Nadaber12@gmail.com',
    username: 'Nadaber22',
    password: '12345678',
  ),
];
