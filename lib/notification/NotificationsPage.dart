import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _notifiedRequestIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courseRequests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs;

          // Play notification sound for new requests
          for (var request in requests) {
            if (!_notifiedRequestIds.contains(request.id)) {
              _notifiedRequestIds.add(request.id);
              _audioPlayer.play(AssetSource('assets/sound/notification.mp3'));
            }
          }

          if (requests.isEmpty) {
            return Center(
              child: Text(
                'No pending course requests',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];

              String studentName = request['studentName'] ?? 'No name provided';
              String studentPhone = request['studentPhone'] ?? 'No phone number provided';
              String studentEmail = request['studentEmail'] ?? 'No email provided';
              String courseId = request['courseId'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
                builder: (context, courseSnapshot) {
                  if (!courseSnapshot.hasData) {
                    return ListTile(
                      title: Text(studentName),
                      subtitle: Text('Loading course information...'),
                    );
                  }

                  var courseData = courseSnapshot.data!;
                  String courseName = courseData['name'] ?? 'Unknown course';

                  return ListTile(
                    title: Text(studentName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Course: $courseName'),
                        Text('Phone: $studentPhone'),
                        Text('Email: $studentEmail'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveRequest(context, request.id, request['studentId'], courseId, studentName, studentPhone, studentEmail),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectRequest(context, request.id, request['studentId']),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveRequest(BuildContext context, String requestId, String studentId, String courseId, String studentName, String studentPhone, String studentEmail) async {
    try {
      // Update the course request status to 'approved'
      await FirebaseFirestore.instance.collection('courseRequests').doc(requestId).update({
        'status': 'approved',
      });

      // Save the student's information under the specific course in 'students'
      await FirebaseFirestore.instance.collection('courses').doc(courseId).collection('students').doc(studentId).set({
        'studentName': studentName,
        'studentPhone': studentPhone,
        'studentEmail': studentEmail,
        'courseId': courseId,
      });

      // Send a notification to the student about the approval
      await FirebaseFirestore.instance.collection('notifications').add({
        'studentId': studentId,
        'title': 'Course Registration Approved',
        'message': 'Your registration for the course has been approved. You can now access the tasks.',
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully approved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to approve request')));
    }
  }

  Future<void> _rejectRequest(BuildContext context, String requestId, String studentId) async {
    try {
      // Update the course request status to 'rejected'
      await FirebaseFirestore.instance.collection('courseRequests').doc(requestId).update({
        'status': 'rejected',
      });

      // Send a notification to the student about the rejection
      await FirebaseFirestore.instance.collection('notifications').add({
        'studentId': studentId,
        'title': 'Course Registration Rejected',
        'message': 'Your registration request has been rejected.',
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request rejected')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reject request')));
    }
  }
}
