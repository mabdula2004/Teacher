import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student/student%20info/StudentPerformanceScreen.dart';

class StudentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student List')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          // Group students by course
          Map<String, List<QueryDocumentSnapshot>> studentsByCourse = {};
          var students = snapshot.data!.docs;
          for (var student in students) {
            // Safely get the data as a Map
            Map<String, dynamic> studentData = student.data() as Map<String, dynamic>;

            // Ensure the field exists and is not null
            String? courseId = studentData['courseId'] as String?;
            if (courseId != null && courseId.isNotEmpty) {
              if (!studentsByCourse.containsKey(courseId)) {
                studentsByCourse[courseId] = [];
              }
              studentsByCourse[courseId]!.add(student);
            } else {
              // Optionally, handle students with missing or empty courseId
              print('Missing or empty courseId for student: ${student.id}');
            }
          }

          return ListView(
            children: studentsByCourse.keys.map((courseId) {
              var courseStudents = studentsByCourse[courseId]!;
              return ExpansionTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('courses')
                      .doc(courseId)
                      .get(),
                  builder: (context, courseSnapshot) {
                    if (!courseSnapshot.hasData || courseSnapshot.data == null) {
                      return Text('Course: Unknown');
                    }
                    var courseData = courseSnapshot.data!.data() as Map<String, dynamic>;
                    return Text('Course: ${courseData['name']}');
                  },
                ),
                children: courseStudents.map((student) {
                  var studentData = student.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(studentData['name'] ?? 'Unknown'),
                    subtitle: Text('Class: ${studentData['class'] ?? 'Unknown'}'),
                    onTap: () {
                      // Navigate to student performance details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentPerformanceScreen(
                            studentId: student.id,
                            studentName: studentData['name'] ?? 'Unknown',
                            courseId: courseId,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
