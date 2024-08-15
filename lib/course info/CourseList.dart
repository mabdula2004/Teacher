import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ManageTopicsScreen.dart';

class CourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        var courses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            var course = courses[index];
            return ListTile(
              title: Text(course['name']),
              subtitle: Text('Week: ${course['week']}'),
              onLongPress: () {
                _showDeleteDialog(context, course.id);
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageTopicsScreen(
                      courseId: course.id,
                      courseTitle: 'Manage ${course['name']} Topics',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Course'),
          content: Text('Are you sure you want to delete this course?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the course from Firestore
                await FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
