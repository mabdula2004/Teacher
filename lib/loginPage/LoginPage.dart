import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check user role
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      String role = userDoc['role'];

      if (role == 'teacher') {
        Navigator.of(context).pushReplacementNamed('/home'); // Navigate to teacher's home screen
      } else if (role == 'student') {
        Navigator.of(context).pushReplacementNamed('/studentHome'); // Navigate to student's home screen
      } else {
        // Handle unexpected role or case
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Error logging in: $e');
      // Show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Login failed. Please check your email or password and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple, // Purple app bar color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70,),
            Text(
              'Welcome',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // Center the text
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Background color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already not have an account?', style: TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registerTeacher'); // Ensure this route exists
                  },
                  child: Text('Sign up'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple, // Text color
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
