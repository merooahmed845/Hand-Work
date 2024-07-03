import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/server_post.dart';
import 'MyAccount_Worker.dart';
import 'home_worker.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _postTitleTD = TextEditingController();
  final TextEditingController _postTextTD = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _nationalID;
  int _selectedIndex = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNationalID();
  }

  Future<void> _loadNationalID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nationalID = prefs.getString('nationalID');
    });
  }

  void _clearTextInput() {
    _phoneNumber.clear();
    _city.clear();
    _postTitleTD.clear();
    _postTextTD.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      final bytes = await pickedFile.readAsBytes();
      final resizedImage = await _resizeImage(bytes, 800, 800);
      setState(() {
        _selectedImageBytes = resizedImage;
        _selectedImageName = pickedFile.name;
        _isLoading = false;
      });
    }
  }

  Future<Uint8List?> _resizeImage(Uint8List data, int maxWidth, int maxHeight) async {
    try {
      img.Image? image = img.decodeImage(data);
      if (image != null) {
        img.Image resizedImage = img.copyResize(image, width: maxWidth, height: maxHeight);
        return Uint8List.fromList(img.encodePng(resizedImage));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resizing image: $e');
      }
    }
    return null;
  }

  void _createTable() async {
    try {
      String result = await Services.createTable();
      if (result == 'success') {
        if (kDebugMode) {
          print('Success to create table');
        }
      } else {
        if (kDebugMode) {
          print('Failed to create table');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating table: $e');
      }
    }
  }

  void _addPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _createTable();
      String base64Image = base64Encode(_selectedImageBytes!);
      try {
        String result = await Services.addPost(
          _nationalID!,
          _phoneNumber.text,
          _city.text,
          _postTitleTD.text,
          _postTextTD.text,
          base64Image,
        );
        if (result == 'success') {
          _clearTextInput();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.blue,
              content: Row(
                children: [
                  Icon(Icons.thumb_up, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Post added',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Failed to add post',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WorkerPage()),
      );
    } else if (index == 1) {
      // لا حاجة إلى أي إجراء لأن المستخدم بالفعل في صفحة CreatePost
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyAccountWorker()),
      );
    }
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
        appBar: AppBar(
          title: const Text('Create a post'),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // حقل رقم الهاتف
                    _buildTextField(
                      controller: _phoneNumber,
                      hintText: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // حقل المدينة
                    _buildTextField(
                      controller: _city,
                      hintText: 'City',
                      icon: Icons.location_city,
                    ),
                    const SizedBox(height: 20),

                    // حقل عنوان المنشور
                    _buildTextField(
                      controller: _postTitleTD,
                      hintText: 'Title',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 20),

                    // حقل نص المنشور
                    _buildTextField(
                      controller: _postTextTD,
                      hintText: 'Text Post',
                      icon: Icons.text_fields,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 20),

                    // زر اختيار الصورة
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text(
                        'Choose Image',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 33, 189, 202), // لون الخلفية
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // زوايا مستديرة قليلاً
                        ),
                      ),
                    ),

                    // عرض اسم الصورة المحددة
                    if (_selectedImageName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('Selected Image: $_selectedImageName'),
                      ),
                    const SizedBox(height: 20),

                    // زر إرسال
                    ElevatedButton(
                      onPressed: _addPost,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 33, 189, 202), // لون الخلفية
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // زوايا مستديرة قليلاً
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
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
              label: 'My Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
    );
  }
}
