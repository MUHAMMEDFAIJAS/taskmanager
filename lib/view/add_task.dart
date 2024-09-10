import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanager/model/task_model.dart';
import 'package:taskmanager/service/task_service.dart';

class AddTaskPage extends StatefulWidget {
  final FirebaseDatabase database;
  final String projectId;

  AddTaskPage({required this.database, required this.projectId});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime? _completionDate;
  bool _isLoading = false;

  Future<void> _addTask() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final dueDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final completionDate = _completionDate != null
        ? DateFormat('yyyy-MM-dd').format(_completionDate!)
        : '';

    if (title.isNotEmpty && description.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final task = Task(
        id: '', 
        title: title,
        description: description,
        dueDate: dueDate,
        status: 'pending', 
         completionDate: completionDate, 
      );

      try {
        final taskService = TaskService(widget.database, widget.projectId);
        await taskService.addTask(task);
        Navigator.of(context).pop(); // Close the page after adding the task
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $error')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null && selectedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = selectedDate;
                      });
                    }
                  },
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Completion Date: ${_completionDate != null ? DateFormat('yyyy-MM-dd').format(_completionDate!) : 'Not set'}'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _completionDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null && selectedDate != _completionDate) {
                      setState(() {
                        _completionDate = selectedDate;
                      });
                    }
                  },
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addTask,
                    child: Text('Add Task'),
                  ),
          ],
        ),
      ),
    );
  }
}
