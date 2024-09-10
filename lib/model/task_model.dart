class Task {
  final String id;
  final String title;
  final String description;
  final String dueDate; 
  final String status;
  final String? completionDate; 

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.completionDate,
  });

  factory Task.fromMap(Map<dynamic, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] ?? '',
      status: map['status'] ?? '',
      completionDate: map['completiondate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
      'completiondate': completionDate, // Added
    };
  }
}
