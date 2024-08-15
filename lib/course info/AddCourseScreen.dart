import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'courseid_page/CourseIdPage.dart'; // Import the CourseIdPage

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
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weekController,
                decoration: InputDecoration(labelText: 'Week'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the week';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _topicsController,
                decoration: InputDecoration(labelText: 'Topics (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the topics';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      // Add the course and get the generated DocumentReference
                      DocumentReference courseRef = await FirebaseFirestore.instance.collection('courses').add({
                        'name': _nameController.text,
                        'week': _weekController.text,
                        'topics': _topicsController.text.split(',').map((e) => e.trim()).toList(),
                      });

                      // Update the course with its generated ID
                      String courseId = courseRef.id;
                      await courseRef.update({'courseId': courseId});

                      // Add the courseId to a separate collection for Course IDs
                      await FirebaseFirestore.instance.collection('courseIds').add({
                        'name': _nameController.text,
                        'courseId': courseId,
                      });

                      // Show a success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Success'),
                            content: Text('Course successfully added!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CourseIdPage()),
                                  );
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      // Handle any errors that occur during the Firestore operations
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('An error occurred while adding the course. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
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
