import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanager/model/task_model.dart';
import 'package:taskmanager/service/task_service.dart';
import 'package:taskmanager/view/add_task.dart';

class TaskPage extends StatefulWidget {
  final FirebaseDatabase database;
  final String projectId;

  TaskPage({required this.database, required this.projectId});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _filter = 'today';

  Future<void> _deleteTask(String taskId) async {
    final taskService = TaskService(widget.database, widget.projectId);
    try {
      await taskService.deleteTask(taskId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService(widget.database, widget.projectId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        backgroundColor: Color.fromARGB(202, 101, 224, 117), 
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: taskService.getFilteredTasksStream(_filter, _selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Tasks Found'));
                }

                final filteredTasks = snapshot.data!;

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3 / 3,
                  ),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      color: Color.fromARGB(
                          200, 136, 236, 142),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, 
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'start Date: ${task.dueDate}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'due date: ${task.completionDate}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: task.status,
                                  items: <String>[
                                    'inprogress',
                                    'completed',
                                    'pending'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      taskService.updateTaskStatus(
                                          task.id, newValue);
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTask(task.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddTaskPage(
              database: widget.database,
              projectId: widget.projectId,
            ),
          ));
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(202, 101, 224, 117),
      ),
    );
  }
}
