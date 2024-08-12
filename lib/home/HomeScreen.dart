import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:firebase_core/firebase_core.dart'; // For Firebase initialization

// HomeScreen Widget
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
      ),
      body: Column(
        children: [
          // Row containing ADD and View buttons (ButtonRow1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addCourse');
                },
                child: Text('ADD'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle view action
                },
                child: Text('View'),
              ),
            ],
          ),
          // Row containing ADD STUDENT and STUDENTS buttons (ButtonRow2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addStudent');
                },
                child: Text('ADD STUDENT'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/students');
                },
                child: Text('STUDENTS'),
              ),
            ],
          ),
          // CourseList Widget to display courses (CourseList)
          Expanded(child: CourseList()),
        ],
      ),
    );
  }
}

// CourseList Widget - Displays the list of courses
class CourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available'));
        }

        var courses = snapshot.data!.docs; // Using null check with '!'
        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            var course = courses[index];
            return ListTile(
              title: Text(course['name']),
              subtitle: Text('Week: ${course['week']}'),
              onTap: () {
                // Handle course details view
              },
            );
          },
        );
      },
    );
  }
}
