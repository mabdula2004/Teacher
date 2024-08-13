import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student/home/HomeScreen.dart';
import 'package:student/registers/RegisterStudentPage.dart';
import 'package:student/registers/RegisterTeacherPage.dart';
import 'package:student/student%20info/StudentListScreen.dart';
import 'LoginPage/StudentLoginPage.dart';
import 'course info/AddCourseScreen.dart';
import 'home/StudentHomeScreen.dart';
import 'LoginPage/LoginPage.dart';
import 'LoginPage/TeacherLoginPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teacher-Student App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
      routes: {
        '/addCourse': (context) => AddCourseScreen(),
        'Admin':(context) => LoginPage(),
        '/students': (context) => StudentListScreen(),
        '/loginTeacher': (context) => TeacherLoginPage(),
        '/registerTeacher': (context) => RegisterTeacherPage(), // Define RegisterTeacherPage route
        '/registerStudent': (context) => RegisterStudentPage(), // Define RegisterStudentPage route
        '/loginStudent': (context) => StudentLoginPage(), // Define StudentLoginPage route
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Center the loading indicator
        } else if (snapshot.hasData) {
          // User is logged in
          User? user = snapshot.data;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // Center the loading indicator
              } else if (snapshot.hasData && snapshot.data != null) {
                var userData = snapshot.data!;
                if (userData['role'] == 'teacher') {
                  return HomeScreen(); // Navigate to Teacher's Home Screen
                } else if (userData['role'] == 'student') {
                  return StudentHomeScreen(studentId: user.uid); // Navigate to Student's Home Screen with studentId
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
