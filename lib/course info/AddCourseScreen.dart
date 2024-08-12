import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:firebase_core/firebase_core.dart'; // For Firebase initialization

class AddCourseScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weekController = TextEditingController();
  final _topicsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Course')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) { // Null check added
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weekController,
                decoration: InputDecoration(labelText: 'Week'),
                validator: (value) {
                  if (value == null || value.isEmpty) { // Null check added
                    return 'Please enter the week';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _topicsController,
                decoration: InputDecoration(labelText: 'Topics'),
                validator: (value) {
                  if (value == null || value.isEmpty) { // Null check added
                    return 'Please enter the topics';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) { // Null check added
                    FirebaseFirestore.instance.collection('courses').add({
                      'name': _nameController.text,
                      'week': _weekController.text,
                      'topics': _topicsController.text.split(','),
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
