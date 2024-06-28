class feedbacks {
  String id;
  String post_id;
  String feedback_text;

  feedbacks({
    required this.id,
    required this.post_id,
    required this.feedback_text,

  });

  factory feedbacks.fromJson(Map<String, dynamic> json) {
    return feedbacks(
      id: json['id'] as String,
      post_id: json['post_id'] as String,
      feedback_text: json['feedback_text'] as String,
    );
  }
}
