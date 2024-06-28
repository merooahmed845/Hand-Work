import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/Feedback.dart';
import '../model/posts.dart';
import '../model/server_post.dart';
import '../model/sever_feedback.dart';
import 'LoginPage.dart';
import 'MyAccount_user.dart';
import 'ShowCommentPage.dart'; // استيراد الشاشة الجديدة

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin {
  List<Posts> _posts = [];
  List<Posts> _filteredPosts = [];
  int _selectedIndex = 0;
  String _searchText = '';
  bool _isLoading = false;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _getPosts() async {
    if (_isRefreshing) return;
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
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
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
      await prefs.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
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
          MaterialPageRoute(builder: (context) => MyAccountUser()),
        );
      } else if (_selectedIndex == 2) {
        _logout();
      }
    });
  }

  void _filterPosts(String searchText) {
    final searchTextLower = searchText.toLowerCase();
    setState(() {
      _filteredPosts = searchText.isEmpty
          ? _posts
          : _posts.where((post) {
        return post.postText.toLowerCase().contains(searchTextLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _filterPosts,
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
              'There are no posts',
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
}

class PostItem extends StatefulWidget {
  final Posts post;
  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final TextEditingController _feedbackText = TextEditingController();
  List<feedbacks> _feedbackList = [];

  void sendWhatsapp() {
    String url = 'https://wa.me/+2${widget.post.phonenumber}?text=Hello';
    launchUrl(Uri.parse(url));
  }

  Future<void> _createTable() async {
    String result = await ServicesFeedback.createFeedbackTable();
    if (result != 'success') {
      _showSnackBar('Failed to create table', Colors.red);
    }
  }

  Future<void> _getFeedback() async {
    try {
      List<feedbacks> feedbackList = await ServicesFeedback.getFeedback(widget.post.id);
      setState(() {
        _feedbackList = feedbackList;
      });

      if (kDebugMode) {
        print('Length: ${_feedbackList.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching feedback: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCommentPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('post_id', widget.post.id);

    await _getFeedback(); // Retrieve feedback before navigating
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShowCommentPage(feedbackList: _feedbackList),
      ),
    );
  }

  void _showFeedbackPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShowCommentPage(feedbackList: _feedbackList),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackText.dispose();
    super.dispose();
  }

  Future<void> _addFeedback() async {
    String postId = widget.post.id;
    String feedbackText = _feedbackText.text.trim();

    if (feedbackText.isEmpty) {
      _showSnackBar('Please enter feedback', Colors.red);
      return;
    }

    try {
      String response = await ServicesFeedback.addFeedback(postId,feedbackText);
      if (response == 'success') {
        _showSnackBar('Feedback added successfully', Colors.green);
        await _getFeedback();
      } else {
        _showSnackBar('Failed to add feedback', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', Colors.red);
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Feedback'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: widget.post.id,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Post ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _feedbackText,
                    decoration: InputDecoration(
                      labelText: 'Feedback',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.comment),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your feedback';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    _createTable();
                    _addFeedback();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_list_numbered,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.post.id,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.post.city,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.post.phonenumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                  GestureDetector(
                    onTap: _showDetailsDialog,
                    child: CircleAvatar(
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
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.post.phonenumber));
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
                  Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'feedback') {
                        _showFeedbackDialog();
                      } else if (value == 'show_comment') {
                        _showCommentPage();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'feedback',
                          child: Text('Feedback'),
                        ),
                        const PopupMenuItem(
                          value: 'show_comment',
                          child: Text('Show comment'),
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.black87,
                          thickness: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.post.postTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Divider(
                          color: Colors.black87,
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.post.postText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                          const SnackBar(content: Text('Could not launch phone call')),
                        );
                      }
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call now'),
                  ),
                  ElevatedButton.icon(
                    onPressed: sendWhatsapp,
                    icon: const Icon(Icons.chat, color: Colors.green),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.green)),
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
