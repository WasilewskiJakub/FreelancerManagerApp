import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  int manDay;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.manDay = 0,
  });

  // Konwersja do mapy dla Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'manDay': manDay, 
    };
  }

  // Tworzenie obiektu `Task` na podstawie mapy Firestore
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      manDay: map['manDay'] ?? 0,
    );
  }
}

class Project {
  String? id;
  String userId;
  String name;
  String description;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;
  String priority;
  List<Task> tasks;

  Project({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    required this.priority,
    required this.tasks,
  });

  // Konwersja `Project` do mapy Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      'priority': priority,
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }

  // Tworzenie obiektu `Project` na podstawie dokumentu Firestore
  factory Project.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Project(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      priority: data['priority'] ?? 'Średni',
      tasks: data['tasks'] != null
          ? (data['tasks'] as List)
              .map((task) => Task.fromMap(task as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
