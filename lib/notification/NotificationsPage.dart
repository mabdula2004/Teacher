import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                leading: Icon(Icons.notifications),
                onTap: () {
                  // Handle notification tap if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
