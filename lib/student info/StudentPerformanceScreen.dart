import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPerformanceScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  StudentPerformanceScreen({required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$studentName\'s Performance')),
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

          var topics = snapshot.data!.docs; // Performance data
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              var topic = topics[index];
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
