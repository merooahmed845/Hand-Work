import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/InfoAcc.dart';
import '../model/server.dart';
import 'DeletAccount.dart';
import 'LoginPage.dart';
import 'CreatePost.dart';
import 'MyAccount_Worker.dart';
import 'home_worker.dart';

class EditAccountWorker extends StatefulWidget {
  @override
  _EditAccountWorkerState createState() => _EditAccountWorkerState();
}

class _EditAccountWorkerState extends State<EditAccountWorker> {
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  InfoAcc? _infoAcc;
  String _errorMessage = '';
  bool _loading = true;

  int _selectedIndex = 2; // تأكد من أن العنصر المحدد هو Profile

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNationalId = prefs.getString('nationalID');
    String? savedPassword = prefs.getString('password');

    if (savedNationalId != null && savedPassword != null) {
      _nationalIdController.text = savedNationalId;
      _passwordController.text = savedPassword;
      await _getInfo();
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _getInfo() async {
    String nationalId = _nationalIdController.text;
    String password = _passwordController.text;

    try {
      List<InfoAcc> infoList = await Account.getInfoAcc(nationalId, password);
      if (infoList.isNotEmpty) {
        setState(() {
          _infoAcc = infoList[0];
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'No user found with provided credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('nationalID');
    prefs.remove('password');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(); // Call the logout method
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WorkerPage()),
        );
      } else if (_selectedIndex == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CreatePost()),
        );
      } else if (_selectedIndex == 2) {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyAccountWorker()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Account'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // تنفيذ الإجراء عند الضغط على زر الإعدادات
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (_loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage, style: TextStyle(color: Colors.red)),
                    if (_infoAcc != null) ...[
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _infoAcc!.image.isNotEmpty
                            ? MemoryImage(base64Decode(_infoAcc!.image))
                            : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        child: _infoAcc!.image.isEmpty
                            ? Icon(Icons.person, size: 50)
                            : null,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _infoAcc!.firstName,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              readOnly: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: _infoAcc!.lastName,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: _infoAcc!.email,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        readOnly: true,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: _infoAcc!.nationalId,
                        decoration: InputDecoration(
                          labelText: 'National ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                        readOnly: true,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: _infoAcc!.userType,
                        decoration: InputDecoration(
                          labelText: 'Type/User',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_pin),
                        ),
                        readOnly: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => DeleteAccount()),
                          );
                        },
                        child: Text('Delete My Account'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Create Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
