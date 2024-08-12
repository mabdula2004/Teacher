import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:firebase_core/firebase_core.dart'; // For Firebase initialization

class CourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var courses = snapshot.data.docs;
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
