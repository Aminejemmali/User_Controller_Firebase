import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user_crud/models/user.dart';
import 'package:user_crud/screens/add_user_screen.dart';
import 'package:user_crud/screens/edit_user_screen.dart';

class UserListScreen extends StatelessWidget {
  Future<void> _deleteUser(BuildContext context, String userId) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User deleted successfully')));
    }
  }

  Future<void> _callUser(BuildContext context, String phoneNumber) async {
    final status = await Permission.phone.request();
    if (status == PermissionStatus.granted) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (launchUri!=0) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $launchUri')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Phone permission not granted')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddUserScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userDocs = snapshot.data!.docs;
          final users = userDocs.map((doc) => User.fromDocument(doc)).toList();

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.phone, color: Colors.green),
                        onPressed: () => _callUser(context, user.phoneNumber),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditUserScreen(user: user),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(context, user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
