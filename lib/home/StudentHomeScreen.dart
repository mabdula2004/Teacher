import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentHomeScreen extends StatelessWidget {
  final String studentId;

  StudentHomeScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Home'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .collection('performance')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No performance data available'));
          }

          var performanceData = snapshot.data!.docs;
          return ListView.builder(
            itemCount: performanceData.length,
            itemBuilder: (context, index) {
              var topic = performanceData[index];
              return ListTile(
                title: Text(topic['topicName']),
                subtitle: Text('Completed: ${topic['completed'] ? "Yes" : "No"}'),
              );
            },
          );
        },
      ),
    );
  }
}
