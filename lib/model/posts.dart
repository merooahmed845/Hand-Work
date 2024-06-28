class Posts {
  String id;
  String username;
  String phonenumber;
  String city;
  String postTitle;
  String postText;
  String image;

  Posts({
    required this.id,
    required this.username,
    required this.phonenumber,
    required this.city,
    required this.postTitle,
    required this.postText,
    required this.image,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      id: json['id'] as String,
      username: json['username'] as String,
      phonenumber: json['phonenumber'] as String,
      city: json['city'] as String,
      postTitle: json['posttitle'] as String,
      postText: json['posttext'] as String,
      image: json['image'] as String,
    );
  }
}
