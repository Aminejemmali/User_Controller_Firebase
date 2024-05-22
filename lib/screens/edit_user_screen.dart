import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:user_crud/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  EditUserScreen({required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _nameController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _editUser() async {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl = widget.user.avatarUrl;
      if (_image != null) {
        // Upload new image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('avatars/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(_image!);
        final snapshot = await uploadTask;
        avatarUrl = await snapshot.ref.getDownloadURL();
      }

      // Update user in Firestore
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        avatarUrl: avatarUrl!,
      );
      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update(updatedUser.toMap());

      Navigator.of(context).pop();
    } catch (e) {
      print('Error editing user: $e');
      // Show error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            SizedBox(height: 16),
            _image == null
                ? widget.user.avatarUrl.isNotEmpty
                ? Image.network(widget.user.avatarUrl)
                : Text('No image selected.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _editUser,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
