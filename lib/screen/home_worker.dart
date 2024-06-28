import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hand2/model/posts.dart';
import 'package:hand2/screen/CreatePost.dart';
import 'package:hand2/screen/LoginPage.dart';
import 'package:hand2/screen/MyAccount_Worker.dart';


import '../model/server_post.dart';

class WorkerPage extends StatefulWidget {
  const WorkerPage({Key? key}) : super(key: key);

  @override
  _WorkerPageState createState() => _WorkerPageState();
}

class _WorkerPageState extends State<WorkerPage> {
  List<Posts> _posts = [];
  List<Posts> _filteredPosts = [];
  int _selectedIndex = 0;
  String _searchText = '';
  bool _isLoading = false;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _getPosts();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _getPosts() async {
    if (_isRefreshing) return; // منع التحديث المتكرر
    setState(() {
      _isLoading = true;
      _isRefreshing = true;
    });
    try {
      List<Posts> posts = await Services.getAllPosts();
      setState(() {
        _posts = posts;
        _filteredPosts = posts;
      });
      if (kDebugMode) {
        print('Length: ${_posts.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching posts: $e');
      }
    }
    setState(() {
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmLogout) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // إزالة جميع البيانات
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _getPosts();
      } else if (_selectedIndex == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CreatePost()),
        );
      } else if (_selectedIndex == 2) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyAccountWorker()),
        );
      } else if (_selectedIndex == 3) {
        _logout();
      }
    });
  }


  void _filterPosts(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _filteredPosts = _posts;
      });
      return;
    }

    final searchTextLower = searchText.toLowerCase();
    setState(() {
      _filteredPosts = _posts.where((post) {
        final postTextLower = post.postText.toLowerCase();
        return postTextLower.contains(searchTextLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _filterPosts(value);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
          ? buildHomeContent()
          : buildProfileContent(),
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
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildHomeContent() {
    return Row(
      children: [
        Expanded(
          child: _filteredPosts.isEmpty
              ? const Center(
            child: Text(
              'There is no post',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : ListView.builder(
            controller: _scrollController,
            itemCount: _filteredPosts.length,
            itemBuilder: (BuildContext context, int index) {
              return PostItem(post: _filteredPosts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget buildProfileContent() {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PostItem extends StatefulWidget {
  final Posts post;
  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 20,
                    child: Text(
                      widget.post.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_city,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.post.city,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.post.phonenumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number copied successfully'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.post.phonenumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.post.postText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            widget.post.image.isNotEmpty
                ? Image.memory(
              base64Decode(widget.post.image),
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final phoneUrl = 'tel:${widget.post.phonenumber}';
                      if (await canLaunch(phoneUrl)) {
                        await launch(phoneUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch phone call')),
                        );
                      }
                    },
                    icon: Icon(Icons.call),
                    label: Text('Call now'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final whatsappUrl = 'https://wa.me/2${widget.post.phonenumber}?text=Hello';
                      if (await canLaunch(whatsappUrl)) {
                        await launch(whatsappUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch WhatsApp')),
                        );
                      }
                    },
                    icon: Icon(Icons.chat, color: Colors.green),
                    label: Text('WhatsApp', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}