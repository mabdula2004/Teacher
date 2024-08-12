import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:firebase_core/firebase_core.dart'; // For Firebase initialization
import 'home/HomeScreen.dart'; // Import HomeScreen
import 'course info/AddCourseScreen.dart';
import 'student info/StudentListScreen.dart';
import 'student info/AddStudentScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher-Student App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      routes: {
        '/addCourse': (context) => AddCourseScreen(),
        '/addStudent': (context) => AddStudentScreen(),
        '/students': (context) => StudentListScreen(),
      },
    );
  }
}
