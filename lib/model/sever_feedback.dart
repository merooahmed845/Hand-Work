import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Feedback.dart';

class ServicesFeedback {
  static var url = Uri.parse('https://handworke.000webhostapp.com/Database/Databases.php');

  static const _CREATE_TABLE_ACTION = 'CREATE_TABLES_Feedback';
  static const _ADD_FEEDBACK_ACTION = 'ADD_FEEDBACK';
  static const _GET_FEEDBACK_ACTION = 'GET_FEEDBACK';

  // Method to create Feedback table
  static Future<String> createFeedbackTable() async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _CREATE_TABLE_ACTION;
      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Create Feedback table response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in createFeedbackTable: $e');
      }
      return 'error';
    }
  }

  // Method to add Feedback
  static Future<String> addFeedback(String postId,String name ,String feedbackText) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _ADD_FEEDBACK_ACTION;
      map['post_id'] = postId;
      map['name'] = name;
      map['feedbacktext'] = feedbackText;
      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Add Feedback Response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in addFeedback: $e');
      }
      return 'error';
    }
  }


  // Method to get Feedback for a specific post
  static Future<List<feedbacks>> getFeedback(String id) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _GET_FEEDBACK_ACTION;
      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Get Feedback response: Done');
      }
      if (200 == response.statusCode) {
        List<feedbacks> list = parseResponse(response.body);
        return list;
      } else {
        return <feedbacks>[];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in getFeedback: $e');
      }
      return <feedbacks>[];
    }
  }

  static List<feedbacks> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<feedbacks>((json) => feedbacks.fromJson(json)).toList();
  }
}
