import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/project.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addProject(Project project) async {
    try {
      final projectData = project.toMap();
      final docRef = await _firestore.collection('projects').add(projectData);
      return docRef.id;
    } catch (e) {
      print("Błąd dodawania projektu: $e");
      throw Exception("Nie udało się dodać projektu");
    }
  }

  Stream<QuerySnapshot> getUserProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<List<Project>> getUserProjectsOnce(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => Project.fromDocument(doc)).toList();
    } catch (e) {
      print("Błąd pobierania projektów: $e");
      throw Exception("Nie udało się pobrać projektów.");
    }
  }

  Future<Project> getProjectById(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (!doc.exists) {
      throw Exception("Nie znaleziono projektu o ID: $projectId");
    }
    return Project.fromDocument(doc);
  }

  Future<void> updateProject(Project project) async {
    if (project.id == null) {
      throw Exception("Projekt nie ma ID, nie można go zaktualizować");
    }

    try {
      final data = project.toMap();
      data.remove('createdAt');

      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(data);
    } catch (e) {
      print("Błąd aktualizacji projektu: $e");
      throw Exception("Nie udało się zaktualizować projektu");
    }
  }

  Future<void> updateTask(String projectId, Task updatedTask) async {
    try {
      final projectRef = _firestore.collection('projects').doc(projectId);
      final projectDoc = await projectRef.get();

      if (!projectDoc.exists) {
        throw Exception("Projekt o ID $projectId nie istnieje.");
      }
      final projectData = projectDoc.data() as Map<String, dynamic>;
      List<dynamic> taskList = projectData['tasks'] ?? [];
      List<Task> tasks = taskList.map((taskMap) => Task.fromMap(taskMap as Map<String, dynamic>)).toList();
      int taskIndex = tasks.indexWhere((task) => task.title == updatedTask.title); // Możesz użyć innego identyfikatora

      if (taskIndex != -1) {
        tasks[taskIndex] = updatedTask;
        await projectRef.update({
          'tasks': tasks.map((task) => task.toMap()).toList(),
        });
      } else {
        throw Exception("Nie znaleziono zadania w projekcie.");
      }
    } catch (e) {
      print("Błąd podczas aktualizacji zadania: $e");
      throw Exception("Nie udało się zaktualizować zadania.");
    }
  }



  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
    } catch (e) {
      print("Błąd usuwania projektu: $e");
      throw Exception("Nie udało się usunąć projektu");
    }
  }
  Future<int> getUserTasksCount(String userId) async {
    final snapshot = await _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .get();

    int totalTasks = 0;

    for (var doc in snapshot.docs) {
      final projectData = doc.data();
      if (projectData.containsKey('tasks') && projectData['tasks'] is List) {
        totalTasks += (projectData['tasks'] as List).length;
      }
    }

    return totalTasks;
  }

  Future<int> getUserProjectsCount(String userId) async {
    final snapshot = await _firestore.collection('projects').where('userId', isEqualTo: userId).get();
    return snapshot.docs.length;
  }

  Future<double> getAverageTasksPerProject(String userId) async {
    int totalTasks = await getUserTasksCount(userId);
    int totalProjects = await getUserProjectsCount(userId);
    if (totalProjects == 0) return 0.0;
    return totalTasks / totalProjects;
  }

  Future<Map<String, int>> getUserProjectsPerMonth(String userId) async {
    final snapshot = await _firestore.collection('projects')
        .where('userId', isEqualTo: userId)
        .get();

    Map<String, int> projectsPerMonth = {};

    for (var doc in snapshot.docs) {
      DateTime date = (doc['createdAt'] as Timestamp).toDate();
      String monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";

      if (projectsPerMonth.containsKey(monthKey)) {
        projectsPerMonth[monthKey] = projectsPerMonth[monthKey]! + 1;
      } else {
        projectsPerMonth[monthKey] = 1;
      }
    }

    return projectsPerMonth;
  }
}
