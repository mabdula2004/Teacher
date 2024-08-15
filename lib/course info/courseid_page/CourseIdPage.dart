import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Import for Clipboard functionality

class CourseIdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Course IDs'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courseIds').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];
              return ListTile(
                title: Text('Course Name: ${course['name']}'),
                subtitle: Text('Course ID: ${course['courseId']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: course['courseId']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Course ID copied to clipboard')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(context, course.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Course ID'),
          content: Text('Are you sure you want to delete this course ID?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the course ID from Firestore
                await FirebaseFirestore.instance.collection('courseIds').doc(documentId).delete();

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
