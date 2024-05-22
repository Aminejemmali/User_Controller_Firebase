import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_crud/models/user.dart';
import 'package:user_crud/screens/user_screen.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _nameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _addUser() async {
    if (_nameController.text.isEmpty || _image == null) return;

    // Upload image to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('avatars/${DateTime.now().toIso8601String()}');
    final uploadTask = storageRef.putFile(_image!);
    final snapshot = await uploadTask;
    final avatarUrl = await snapshot.ref.getDownloadURL();

    // Add user to Firestore
    final newUser = User(
      id: '',
      name: _nameController.text,
      avatarUrl: avatarUrl,
    );
    await FirebaseFirestore.instance.collection('users').add(newUser.toMap());

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _addUser,
              child: Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }
}
