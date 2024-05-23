import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_crud/models/user.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  EditUserScreen({required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _phoneNumberController.text = widget.user.phoneNumber;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _updateUser() async {
    if (_nameController.text.isEmpty || _phoneNumberController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    String avatarUrl = widget.user.avatarUrl;

    // Upload new image to Firebase Storage if selected
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('avatars/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      avatarUrl = await snapshot.ref.getDownloadURL();
    }

    // Update user in Firestore
    final updatedUser = User(
      id: widget.user.id,
      name: _nameController.text,
      avatarUrl: avatarUrl,
      phoneNumber: _phoneNumberController.text,
    );
    await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update(updatedUser.toMap());

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16),
            _image == null
                ? Image.network(widget.user.avatarUrl)
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateUser,
              child: Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
