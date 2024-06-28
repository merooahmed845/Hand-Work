import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../model/server.dart';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _nationalID = TextEditingController();
  String _userType = 'User';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Uint8List? _selectedImageBytes;
  String? _nationalIDError;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _createTable();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _nationalID.dispose();
    super.dispose();
  }

  Future<void> _createTable() async {
    String result = await Account.createTable();
    if (result != 'success') {
      _showSnackBar('Failed to create table', Colors.red);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final resizedImage = await _resizeImage(bytes, 800, 800);

      setState(() {
        _selectedImageBytes = resizedImage;
      });
    }
  }

  Future<Uint8List> _resizeImage(Uint8List data, int maxWidth, int maxHeight) async {
    final image = img.decodeImage(data);
    if (image != null) {
      final resizedImage = img.copyResize(image, width: maxWidth, height: maxHeight);
      return Uint8List.fromList(img.encodePng(resizedImage));
    }
    return data;
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      bool nationalIDExists = await Account.checkNationalID(_nationalID.text);

      if (nationalIDExists) {
        setState(() {
          _nationalIDError = 'National ID already exists';
        });
      } else {
        setState(() {
          _nationalIDError = null;
        });

        if (_selectedImageBytes == null) {
          _showSnackBar('No image selected', Colors.red);
          return;
        }

        final imageBytes = _selectedImageBytes!;
        final resizedImageBytes = await _resizeImage(imageBytes, 300, 300);
        final base64Image = base64Encode(resizedImageBytes);

        String result = await Account.addUser(
          _firstName.text,
          _lastName.text,
          _email.text,
          _password.text,
          _nationalID.text,
          _userType,
          base64Image,
        );

        if (result == 'success') {
          _showSnackBar('Account created successfully', Colors.blue);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          _showSnackBar('Failed to create account', Colors.red);
        }
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.isNotEmpty) {
      if (password.length >= 6) strength += 1;
      if (RegExp(r'(?=.*?[A-Z])').hasMatch(password)) strength += 1;
      if (RegExp(r'(?=.*?[a-z])').hasMatch(password)) strength += 1;
      if (RegExp(r'(?=.*?[0-9])').hasMatch(password)) strength += 1;
      if (RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(password)) strength += 1;
    }
    setState(() {
      _passwordStrength = strength / 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/BCK.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // SizedBox(height: 5), // Adjusted to avoid overlapping with the back button
                      Text(
                        'Register',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: _selectedImageBytes != null
                                    ? MemoryImage(_selectedImageBytes!)
                                    : AssetImage('images/personal.png') as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstName,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _lastName,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nationalID,
                        decoration: InputDecoration(
                          labelText: 'National ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.perm_identity),
                          errorText: _nationalIDError,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(14),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your National ID';
                          }
                          if (value.length != 14) {
                            return 'National ID must be exactly 14 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: _checkPasswordStrength,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          // Check if the password contains at least one letter, one number, and one special character
                          if (!RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[@#$%^&+=])').hasMatch(value)) {
                            return 'Password must contain at least one letter, one number, and one special character';
                          }
                          // Check if the password length is at least 6 characters
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _passwordStrength <= 1 / 3
                              ? Colors.red
                              : _passwordStrength <= 2 / 3
                              ? Colors.yellow
                              : Colors.green,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _password.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _userType,
                        decoration: InputDecoration(
                          labelText: 'Type/User',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_pin),
                        ),
                        items: <String>['User', 'Worker'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _userType = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a Type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _addUser();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')),
                            );
                          }
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 33, 189, 202), // text color
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // slightly round corners
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
