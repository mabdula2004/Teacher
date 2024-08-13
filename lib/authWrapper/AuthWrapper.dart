import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '';
import '../LoginPage/LoginPage.dart';
import '../home/HomeScreen.dart';
import '../home/StudentHomeScreen.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          User? user = snapshot.data;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data != null) {
                var userData = snapshot.data!;
                if (userData['role'] == 'teacher') {
                  return HomeScreen(); // Teacher's Home Screen
                } else if (userData['role'] == 'student') {
                  return StudentHomeScreen(studentId: user.uid); // Student's Home Screen
                } else {
                  return LoginPage(); // Fallback to Login Screen
                }
              } else {
                return LoginPage(); // Fallback to Login Screen
              }
            },
          );
        } else {
          return LoginPage(); // User is not logged in, show Login Screen
        }
      },
    );
  }
}
