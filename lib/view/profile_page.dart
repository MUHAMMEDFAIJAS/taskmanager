import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          SizedBox(height: 16),
          Text('User Name'),
          Text('user@example.com'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
