import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanager/model/task_model.dart';

class TaskService {
  final DatabaseReference _taskRef;

  TaskService(FirebaseDatabase database, String projectId)
      : _taskRef = database.ref('projects/$projectId/tasks');

  Stream<DatabaseEvent> getTasksStream() {
    return _taskRef.onValue;
  }

  Future<void> addTask(Task task) async {
    try {
      final newTaskRef = _taskRef.push();
      await newTaskRef.set(task.toMap());
    } catch (error) {
      throw Exception('Error adding task: $error');
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _taskRef.child(taskId).update({'status': newStatus});
    } catch (error) {
      throw Exception('Error updating task status: $error');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskRef.child(taskId).remove();
    } catch (error) {
      throw Exception('Error deleting task: $error');
    }
  }

  Stream<List<Task>> getFilteredTasksStream(String filter, DateTime selectedDate) {
    return getTasksStream().map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final tasks = data.entries.map((entry) {
        final task = entry.value as Map<dynamic, dynamic>;
        final taskId = entry.key as String;
        return Task.fromMap(task, taskId);
      }).toList();

      DateTime now = selectedDate;

      List<Task> filteredTasks;

      switch (filter) {
        case 'this_week':
          filteredTasks = tasks.where((task) {
            final dueDate = DateTime.parse(task.dueDate);
            return isThisWeek(dueDate, now);
          }).toList();
          break;
        case 'this_month':
          filteredTasks = tasks.where((task) {
            final dueDate = DateTime.parse(task.dueDate);
            return isThisMonth(dueDate, now);
          }).toList();
          break;
        case 'today':
        default:
          filteredTasks = tasks.where((task) {
            final dueDate = DateTime.parse(task.dueDate);
            return isSameDay(dueDate, now);
          }).toList();
          break;
      }

      return filteredTasks;
    });
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isThisWeek(DateTime date, DateTime now) {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  bool isThisMonth(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month;
  }
}
