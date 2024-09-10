import 'package:flutter/material.dart';
import 'package:taskmanager/view/profile_page.dart';
import 'package:taskmanager/view/project_page.dart'; 
import 'package:taskmanager/service/project_service.dart';
import 'package:firebase_database/firebase_database.dart';

final ProjectService projectService = ProjectService(FirebaseDatabase.instance);

class Homescreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  Homescreen({required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Task Manager')),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: toggleTheme,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Projects'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProjectPage(projectService: projectService),
            ProfileTab(),
          ],
        ),
      ),
    );
  }
}
