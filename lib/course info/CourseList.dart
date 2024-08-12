import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore

class CourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available'));
        }

        var courses = snapshot.data!.docs; // Use '!' to assert non-null
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
