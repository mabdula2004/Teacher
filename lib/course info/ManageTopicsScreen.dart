import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTopicsScreen extends StatefulWidget {
  final String courseId;

  ManageTopicsScreen({required this.courseId});

  @override
  _ManageTopicsScreenState createState() => _ManageTopicsScreenState();
}

class _ManageTopicsScreenState extends State<ManageTopicsScreen> {
  final _topicController = TextEditingController();

  void _addTopic() async {
    final topic = _topicController.text;

    if (topic.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'topics': FieldValue.arrayUnion([topic]),
      });
      _topicController.clear();
    }
  }

  void _removeTopic(String topic) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .update({
      'topics': FieldValue.arrayRemove([topic]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Topics')),
      body: Column(
        children: [
          TextField(
            controller: _topicController,
            decoration: InputDecoration(labelText: 'Add Topic'),
          ),
          ElevatedButton(
            onPressed: _addTopic,
            child: Text('Add Topic'),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(widget.courseId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var courseData = snapshot.data!.data() as Map<String, dynamic>;
                var topics = List<String>.from(courseData['topics'] ?? []);

                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(topics[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeTopic(topics[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
