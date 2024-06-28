import 'package:flutter/material.dart';
import 'package:hand2/screen/MyAccount_Worker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/server.dart';
import 'LoginPage.dart';
import 'home_worker.dart'; // تأكد من استيراد صفحة WorkerPage

class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _confirmDeleteAccount() async {
    String nationalId = _nationalIdController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (nationalId.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    String response = await Account.disableUser(nationalId, email, password);
    print('Response from server: $response');
    if (response == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account deleted successfully'),
        ),
      );
      _logout();
    } else {
      setState(() {
        _errorMessage = 'Failed to disable account. Please try again.';
      });
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => WorkerPage()),
                );
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('nationalID');
      prefs.remove('password');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyAccountWorker()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Delete Account'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: TextStyle(color: Colors.red)),
              TextField(
                controller: _nationalIdController,
                decoration: InputDecoration(
                  labelText: 'National ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.perm_identity),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Delete My Account'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: _showDeleteConfirmationDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
