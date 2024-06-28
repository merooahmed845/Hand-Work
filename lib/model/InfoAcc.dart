class InfoAcc {
  final String firstName;
  final String lastName;
  final String email;
  final String nationalId;
  final String userType;
  final String image;

  InfoAcc({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nationalId,
    required this.userType,
    required this.image,
  });

  factory InfoAcc.fromJson(Map<String, dynamic> json) {
    return InfoAcc(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      nationalId: json['nationalid'],
      userType: json['user_type'],
      image: json['image'],
    );
  }
}
