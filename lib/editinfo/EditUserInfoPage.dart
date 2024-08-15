import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserInfoPage extends StatefulWidget {
  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _nameController.text = userDoc['name'];
        _emailController.text = user.email!;
      });
    }
  }

  Future<void> _updateUserInfo() async {
    User? user = _auth.currentUser;

    try {
      // Update name in Firestore
      await _firestore.collection('users').doc(user!.uid).update({
        'name': _nameController.text,
      });

      // Update email
      if (_emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
        await _firestore.collection('users').doc(user.uid).update({
          'email': _emailController.text,
        });
      }

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      // Show success message and update UI
      _showSuccessDialog('Successfully updated');
      _updateHomeScreenInfo(_nameController.text, _emailController.text);

    } catch (e) {
      // Show error message if something goes wrong
      _showErrorDialog('Failed to update your information. Please try again.');
      print(e);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateHomeScreenInfo(String name, String email) {
    // You can use a state management solution like Provider, Bloc, etc.,
    // to update the HomeScreen with the new information or pass the new data directly to the HomeScreen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User Information', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password (Optional)'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserInfo,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
