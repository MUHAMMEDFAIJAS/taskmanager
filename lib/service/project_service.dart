import 'package:firebase_database/firebase_database.dart';
import 'package:taskmanager/model/project_model.dart';

class ProjectService {
  final DatabaseReference _projectRef;

  ProjectService(FirebaseDatabase database)
      : _projectRef = database.ref('projects');

  Stream<DatabaseEvent> getProjectsStream() {
    return _projectRef.onValue.asBroadcastStream();
  }

  Future<void> addProject(Project project) async {
    try {
      final newProjectRef = _projectRef.push();
      await newProjectRef.set({
        'name': project.name,
        'description': project.description,
        'date': project.date,
      });
    } catch (error) {
      throw Exception('Error adding project: $error');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectRef.child(projectId).remove();
    } catch (error) {
      throw Exception('Error deleting project: $error');
    }
  }
  Stream<List<Project>> searchProjects(String searchTerm) {
    return _projectRef.orderByChild('name').startAt(searchTerm).endAt(searchTerm + '\uf8ff').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null || data.isEmpty) {
        return [];
      }

      return data.entries
          .map((entry) {
            final projectData = entry.value as Map<dynamic, dynamic>?;
            if (projectData == null || !projectData.containsKey('name')) {
              return null;
            }

            final projectId = entry.key as String;
            return Project.fromMap(projectData, projectId);
          })
          .whereType<Project>()
          .toList();
    });
  }
}

