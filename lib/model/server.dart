import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'InfoAcc.dart';

class Account {
  static var url =
      Uri.parse('https://handworke.000webhostapp.com/Database/Databases.php');

  static const _CREATE_TABLE_ACTION = 'CREATE_TABLES_Accounts';
  static const _ADD_USER_ACTION = 'ADD_USER';
  static const String _CHECK_USER_ACTION = "CHAKE_USER";
  static const  _GET_INFO_ACC_ACTION = "GIT_INFO";
  static const _EDIT_ACC_ACTION = "EDIT_ACC";
  static const _DISABLE_USER_ACTION = 'DISABLE_USER';
  static const String _CHECK_FORGET_ACTION = "CHAKE_FORGET";

  // Method to create table
  static Future<String> createTable() async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _CREATE_TABLE_ACTION;
      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Create table response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating table: $e');
      }
      return 'error';
    }
  }

  // Method to add user
  static Future<String> addUser(String firstName, String lastName, String email,
      String password, String nationalId, String userType,String image) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _ADD_USER_ACTION;
      map['first_name'] = firstName;
      map['last_name'] = lastName;
      map['email'] = email;
      map['password'] = password;
      map['nationalid'] = nationalId;
      map['user_type'] = userType;
      map['image'] = image;

      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('ADD User Response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding user: $e');
      }
      return 'error';
    }
  }

  static Future<Map<String, dynamic>> checkUser(
      String nationalid, String password) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _CHECK_USER_ACTION;
      map['nationalid'] = nationalid;
      map['password'] = password;

      final response = await http.post(url, body: map);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        bool isAuthenticated = data['status'] == 'success';
        String userType = data['user_type'];
        return {'authenticated': isAuthenticated, 'user_type': userType};
      } else {
        return {'authenticated': false, 'user_type': ''};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return {'authenticated': false, 'user_type': ''};
    }
  }

static Future<List<InfoAcc>> getInfoAcc(String nationalid, String password) async {
  try {
    var map = <String, dynamic>{};
    map['action'] = _GET_INFO_ACC_ACTION;
    map['nationalid'] = nationalid;
    map['password'] = password;

    final response = await http.post(url, body: map);
    if (kDebugMode) {
      print('Get information user: ${response.body.length}');
    }
    if (response.statusCode == 200) {
      List<InfoAcc> list = parseResponse(response.body);
      return list;
    } else {
      return <InfoAcc>[];
    }
  } catch (e) {
    if (kDebugMode) {
      print('Exception in informationUser: $e');
    }
    return <InfoAcc>[];
  }
}


  static List<InfoAcc> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<InfoAcc>((json) => InfoAcc.fromJson(json)).toList();
  }

  static Future<String> editAcc(String nationalId, String newPassword) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _EDIT_ACC_ACTION;
      map['nationalid'] = nationalId;
      map['new_password'] = newPassword;

      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Edit Account Response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error editing account: $e');
      }
      return 'error';
    }
  }


  static Future<bool> checkNationalID(String nationalID) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = 'CHECK_NATIONAL_ID';
      map['nationalid'] = nationalID;

      final response = await http.post(url, body: map);
      if (response.statusCode == 200) {
        return response.body == 'exists';
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking National ID: $e');
      }
      return false;
    }
  }

  static Future<String> disableUser(String nationalId, String email, String password) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _DISABLE_USER_ACTION;
      map['nationalid'] = nationalId;
      map['email'] = email;
      map['password'] = password;

      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Disable User Response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disabling user: $e');
      }
      return 'error';
    }
  }

  static Future<Map<String, dynamic>> checkforget(
      String nationalid, String email) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _CHECK_FORGET_ACTION;
      map['nationalid'] = nationalid;
      map['email'] = email;

      final response = await http.post(url, body: map);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        bool isAuthenticated = data['status'] == 'success';
        String userType = data['user_type'];
        return {'authenticated': isAuthenticated, 'user_type': userType};
      } else {
        return {'authenticated': false, 'user_type': ''};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return {'authenticated': false, 'user_type': ''};
    }
  }
}