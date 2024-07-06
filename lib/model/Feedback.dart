class feedbacks {
  String id;
  String post_id;
  String firstName;
  String feedback_text;
  String imageU; // Add this line

  feedbacks({
    required this.id,
    required this.post_id,
    required this.firstName,
    required this.feedback_text,
    required this.imageU,

  });

  factory feedbacks.fromJson(Map<String, dynamic> json) {
    return feedbacks(
      id: json['id'] as String,
      post_id: json['post_id'] as String,
      firstName: json['firstName'] as String,
      feedback_text: json['feedback_text'] as String,
      imageU: json['imageU'] as String, // Add this line
    );
  }
}
