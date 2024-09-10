import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanager/model/project_model.dart';
import 'package:taskmanager/service/project_service.dart';
import 'package:taskmanager/view/task_page.dart';

class ProjectPage extends StatefulWidget {
  final ProjectService projectService;

  ProjectPage({required this.projectService});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late Stream<DatabaseEvent> _projectStream;
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Project>> _searchStream;

  @override
  void initState() {
    super.initState();
    _projectStream = widget.projectService.getProjectsStream();
    _searchStream = widget.projectService.searchProjects('');

    _searchController.addListener(() {
      setState(() {
        _searchStream =
            widget.projectService.searchProjects(_searchController.text);
      });
    });
  }

  Future<void> _deleteProject(BuildContext context, String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project'),
        content: Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.projectService.deleteProject(projectId);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete project: $error')),
        );
      }
    }
  }

  Future<void> _addProject() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final description = descriptionController.text;
              final date = dateController.text;

              if (name.isNotEmpty &&
                  description.isNotEmpty &&
                  date.isNotEmpty) {
                try {
                  final newProject = Project(
                    id: '',
                    name: name,
                    description: description,
                    date: date,
                  );
                  await widget.projectService.addProject(newProject);
                  Navigator.of(context).pop();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add project: $error')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by project name',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.green),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Project>>(
        stream: _searchStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Projects Found'));
          }

          final projects = snapshot.data!;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(202, 101, 224, 110),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    project.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(project.description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProject(context, project.id),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TaskPage(
                        database: FirebaseDatabase.instance,
                        projectId: project.id,
                      ),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: Icon(Icons.add),
        tooltip: 'Add Project',
        backgroundColor: Color.fromARGB(202, 101, 224, 117),
      ),
    );
  }
}
