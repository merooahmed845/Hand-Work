class Posts {
  String id;
  String firstName;
  String phonenumber;
  String city;
  String postTitle;
  String postText;
  String image;
  String imageU; // Add this line

  Posts({
    required this.id,
    required this.firstName,
    required this.phonenumber,
    required this.city,
    required this.postTitle,
    required this.postText,
    required this.image,
    required this.imageU, // Add this line
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      phonenumber: json['phonenumber'] as String,
      city: json['city'] as String,
      postTitle: json['posttitle'] as String,
      postText: json['posttext'] as String,
      image: json['image'] as String,
      imageU: json['imageU'] as String, // Add this line
    );
  }
}
