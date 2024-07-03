import 'package:flutter/material.dart';
import 'package:hand2/screen/home_worker.dart';
import '../model/Feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_user.dart';

class ShowCommentPageW extends StatefulWidget {
  final List<feedbacks> feedbackList;

  const ShowCommentPageW({Key? key, required this.feedbackList}) : super(key: key);

  @override
  _ShowCommentPageWState createState() => _ShowCommentPageWState();
}

class _ShowCommentPageWState extends State<ShowCommentPageW> {
  List<feedbacks> _filteredFeedbackList = [];

  @override
  void initState() {
    super.initState();
    _getSavedPostId();
  }

  Future<void> _getSavedPostId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? postId = prefs.getString('post_id');
    if (postId != null && postId.isNotEmpty) {
      _filterFeedbacks(postId);
    }
  }

  void _filterFeedbacks(String postId) {
    setState(() {
      _filteredFeedbackList = widget.feedbackList
          .where((feedback) => feedback.post_id.contains(postId))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WorkerPage()),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredFeedbackList.isNotEmpty
                      ? ListView.builder(
                    itemCount: _filteredFeedbackList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 100, 200, 202),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _filteredFeedbackList[index].name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' : ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _filteredFeedbackList[index].feedback_text,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: const Text('No comments available'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
