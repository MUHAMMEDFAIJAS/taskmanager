class Project {
  final String id;
  final String name;
  final String description;
  final String date;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
  });

  factory Project.fromMap(Map<dynamic, dynamic> map, String id) {
    return Project(
      id: id,
      name: map['name'] ?? 'No Name',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
    );
  }
}
