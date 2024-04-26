import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; // Import your login screen if you have one

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoginSuccessful = false;
  String _userData = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoginSuccessful = true;
      });
      _fetchUserData(FirebaseAuth.instance.currentUser?.email ??
          ''); // Pass user's email to fetch data
    }
  }

  Future<void> _fetchUserData(String email) async {
    try {
      DocumentSnapshot userDataSnapshot = await _firestore
          .collection('User')
          .doc(email)
          .get(); // Fetch using email
      if (userDataSnapshot.exists) {
        setState(() {
          String userEmail = userDataSnapshot['email'];
          String phoneNumber = userDataSnapshot['phoneNumber'];
          String username = userDataSnapshot['username'];
          _userData =
              'Email: $userEmail\nPhone Number: $phoneNumber\nUsername: $username';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage())); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Center(
        child: _isLoginSuccessful
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login to Firebase successful'),
                  SizedBox(height: 20),
                  Text('User Data: $_userData'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Menu(),
    );
  }
}
