import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:firebase_core/firebase_core.dart'; // For Firebase initialization



class StudentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student List')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var students = snapshot.data.docs;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              return ListTile(
                title: Text(student['name']),
                subtitle: Text('Class: ${student['class']}'),
                onTap: () {
                  // Navigate to student details page
                },
              );
            },
          );
        },
      ),
    );
  }
}
