import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTopicsScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle; // Holds the course title

  ManageTopicsScreen({required this.courseId, required this.courseTitle});

  @override
  _ManageTopicsScreenState createState() => _ManageTopicsScreenState();
}

class _ManageTopicsScreenState extends State<ManageTopicsScreen> {
  final _topicController = TextEditingController();
  String? _editingTopicId;

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

  void _editTopic(String oldTopic, String newTopic) async {
    if (newTopic.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'topics': FieldValue.arrayRemove([oldTopic]),
      });
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'topics': FieldValue.arrayUnion([newTopic]),
      });
      _topicController.clear();
      setState(() {
        _editingTopicId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.courseTitle,
          style: TextStyle(color: Colors.white),
        ), // Displaying dynamic title
      ),
      body: Column(
        children: [
          TextField(
            controller: _topicController,
            decoration: InputDecoration(labelText: 'Add/Edit Topic'),
          ),
          ElevatedButton(
            onPressed: _editingTopicId == null
                ? _addTopic
                : () {
              _editTopic(_editingTopicId!, _topicController.text);
            },
            child: Text(_editingTopicId == null ? 'Add Topic' : 'Update Topic'),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _editingTopicId = topics[index];
                                _topicController.text = topics[index];
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeTopic(topics[index]),
                          ),
                        ],
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
