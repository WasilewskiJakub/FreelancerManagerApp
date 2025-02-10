// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../../services/projects/project_service.dart';
// import '../../domain/project.dart';
// import '../homepage_dashboard/user_profile_mobile_card.dart';

// class ProjectsScreen extends StatefulWidget {
//   const ProjectsScreen({Key? key}) : super(key: key);

//   @override
//   State<ProjectsScreen> createState() => _ProjectsScreenState();
// }

// class _ProjectsScreenState extends State<ProjectsScreen> {
//   final ProjectService _projectService = ProjectService();
//   final User? _user = FirebaseAuth.instance.currentUser;

//   Map<String, bool> expandedProjects = {};

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const UserProfileCard(), // KARTA UŻYTKOWNIKA TYLKO W TEJ ZAKŁADCE
//         Expanded(
//           child: _buildProjectSection(),
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectSection() {
//     if (_user == null) {
//       return const Center(child: Text("Nie znaleziono użytkownika"));
//     }

//     return StreamBuilder(
//       stream: _projectService.getUserProjects(_user!.uid),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final projects = snapshot.data!.docs
//             .map((doc) => Project.fromDocument(doc))
//             .toList();

//         if (projects.isEmpty) {
//           return _buildEmptyProjectsView();
//         } else {
//           return ListView.builder(
//             padding: const EdgeInsets.only(top: 16, bottom: 100),
//             itemCount: projects.length,
//             itemBuilder: (context, index) {
//               final project = projects[index];
//               final int totalTasks = project.tasks.length;
//               final int completedTasks = _countCompletedTasks(project);

//               return _buildProjectCard(project, totalTasks, completedTasks);
//             },
//           );
//         }
//       },
//     );
//   }

//   Widget _buildEmptyProjectsView() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: const [
//           Text(
//             "Dodaj pierwszy projekt!",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 15),
//         ],
//       ),
//     );
//   }

//   Widget _buildProjectCard(Project project, int totalTasks, int completedTasks) {
//     bool isExpanded = expandedProjects[project.id] ?? false;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       elevation: 3,
//       child: Column(
//         children: [
//           ListTile(
//             title: Text(
//               project.name,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Zadania: $completedTasks / $totalTasks"),
//                 Text(
//                   "Priorytet: ${project.priority}",
//                   style: TextStyle(
//                     color: _getPriorityColor(project.priority),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   "Termin: ${_formatDate(project.startDate!)} - ${_formatDate(project.endDate!)}",
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 Text(
//                   "Łączne manDays: ${_calculateTotalManDays(project)}",
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
//               onPressed: () {
//                 setState(() {
//                   expandedProjects[project.id!] = !isExpanded;
//                 });
//               },
//             ),
//           ),

//           if (isExpanded)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildTaskList(project),
//                   const Divider(),
//                   _buildActionButtons(project.id!, completedTasks == totalTasks),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTaskList(Project project) {
//     final sortedTasks = List.from(project.tasks)
//       ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: sortedTasks.map((task) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       task.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text("Termin: ${_formatDate(task.dueDate)}"),
//                     if (task.isCompleted)
//                       Text("Czas pracy: ${task.manDay} manDays"),
//                   ],
//                 ),
//               ),
//               Checkbox(
//                 value: task.isCompleted,
//                 onChanged: (bool? newValue) {
//                   setState(() {
//                     task.isCompleted = newValue ?? false;
//                   });

//                   if (task.isCompleted) {
//                     _showManDaysDialog(task, project.id!);
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildActionButtons(String projectId, bool allTasksCompleted) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton.icon(
//           onPressed: () => _showDeleteConfirmationDialog(projectId),
//           icon: const Icon(Icons.delete, color: Colors.white),
//           label: const Text("Usuń projekt", style: TextStyle(color: Colors.white)),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//         ),
//         ElevatedButton.icon(
//           onPressed: allTasksCompleted ? () => _issueInvoiceForProject(projectId) : null,
//           icon: const Icon(Icons.receipt_long),
//           label: const Text("Wystaw fakturę"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: allTasksCompleted ? Colors.green : Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   void _showDeleteConfirmationDialog(String projectId) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Usuń projekt"),
//           content: const Text("Czy na pewno chcesz usunąć ten projekt?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Anuluj"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await _projectService.deleteProject(projectId);
//                 Navigator.pop(context);
//                 setState(() {});
//               },
//               child: const Text("Usuń", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showManDaysDialog(Task task, String projectId) {
//     final TextEditingController _manDaysController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Ile MD zajęło wykonanie zadania?"),
//           content: TextField(
//             controller: _manDaysController,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: "Liczba MD",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Anuluj"),
//             ),
//             TextButton(
//               onPressed: () {
//                 final int manDays =
//                     int.tryParse(_manDaysController.text) ?? 0;
//                 setState(() {
//                   task.manDay = manDays;
//                 });
//                 // Zapis do bazy
//                 _projectService.updateTask(projectId, task);
//                 Navigator.pop(context);
//               },
//               child: const Text("Zapisz"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Metoda przykładowa do wystawienia faktury
//   void _issueInvoiceForProject(String projectId) async {
//     try {
//       // np. await _invoiceService.generateInvoiceForProject(projectId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Faktura została wystawiona!")),
//       );
//     } catch (e) {
//       debugPrint("Błąd wystawiania faktury: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Nie udało się wystawić faktury.")),
//       );
//     }
//   }

//   /// Liczba ukończonych zadań w projekcie
//   int _countCompletedTasks(Project project) {
//     return project.tasks.where((t) => t.isCompleted).length;
//   }

//   /// Zliczanie łącznych manDays
//   int _calculateTotalManDays(Project project) {
//     return project.tasks.fold(0, (sum, task) => sum + task.manDay);
//   }

//   /// Formatowanie daty (dd.mm.rrrr)
//   String _formatDate(DateTime date) {
//     return "${date.day}.${date.month}.${date.year}";
//   }

//   /// Kolor priorytetu
//   Color _getPriorityColor(String priority) {
//     switch (priority) {
//       case 'Wysoki':
//         return Colors.red;
//       case 'Średni':
//         return Colors.orange;
//       case 'Niski':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer_manager_app/services/user/user_service.dart';
import '../../services/projects/project_service.dart';
import '../../domain/project.dart';
import '../../domain/user_details.dart';
import '../homepage_dashboard/user_profile_mobile_card.dart';
import '../../services/invoice/invoice_generator.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();
  final User? _user = FirebaseAuth.instance.currentUser;
  Map<String, bool> expandedProjects = {};
  
  // 🔹 Nowe zmienne do sortowania i ukrywania projektów
  String _sortBy = "Priorytet";
  bool _hideCompletedProjects = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const UserProfileCard(),
        _buildSortingOptions(),
        Expanded(
          child: _buildProjectSection(),
        ),
      ],
    );
  }

  Widget _buildSortingOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Sortowanie (zajmuje dostępne miejsce)
          Expanded(
            child: Row(
              children: [
                const Text("Sortuj:"),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: ["Priorytet", "Data zakończenia"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _sortBy = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Przełącznik ukrywania ukończonych projektów
          Row(
            children: [
              const Text("Ukryj ukończone"),
              Switch(
                value: _hideCompletedProjects,
                onChanged: (bool value) {
                  setState(() {
                    _hideCompletedProjects = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  /// 🔥 **Sekcja listy projektów**
  Widget _buildProjectSection() {
    if (_user == null) {
      return const Center(child: Text("Nie znaleziono użytkownika"));
    }

    return StreamBuilder(
      stream: _projectService.getUserProjects(_user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Project> projects = snapshot.data!.docs
            .map((doc) => Project.fromDocument(doc))
            .toList();

        // 🔹 Filtracja - ukrywanie ukończonych projektów
        if (_hideCompletedProjects) {
          projects = projects
              .where((project) => _countCompletedTasks(project) < project.tasks.length)
              .toList();
        }

        // 🔹 Sortowanie
        if (_sortBy == "Priorytet") {
          projects.sort((a, b) => _priorityValue(b.priority).compareTo(_priorityValue(a.priority)));
        } else if (_sortBy == "Data zakończenia") {
          projects.sort((a, b) => b.endDate!.compareTo(a.endDate!));
        }

        if (projects.isEmpty) {
          return _buildEmptyProjectsView();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final int totalTasks = project.tasks.length;
            final int completedTasks = _countCompletedTasks(project);

            return _buildProjectCard(project, totalTasks, completedTasks);
          },
        );
      },
    );
  }

  /// 🔹 Mapowanie priorytetu na wartość liczbową dla sortowania
  int _priorityValue(String priority) {
    switch (priority) {
      case 'Wysoki':
        return 3;
      case 'Średni':
        return 2;
      case 'Niski':
        return 1;
      default:
        return 0;
    }
  }

  /// 🔹 Liczba ukończonych zadań
  int _countCompletedTasks(Project project) {
    return project.tasks.where((t) => t.isCompleted).length;
  }

  Widget _buildProjectCard(Project project, int totalTasks, int completedTasks) {
    bool isExpanded = expandedProjects[project.id] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            title: Text(
              project.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Zadania: $completedTasks / $totalTasks"),
                Text(
                  "Priorytet: ${project.priority}",
                  style: TextStyle(
                    color: _getPriorityColor(project.priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Termin: ${_formatDate(project.endDate!)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "Łączne manDays: ${_calculateTotalManDays(project)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  expandedProjects[project.id!] = !isExpanded;
                });
              },
            ),
          ),

          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskList(project),
                  const Divider(),
                  _buildActionButtons(project.id!, completedTasks == totalTasks),
                ],
              ),
            ),
        ],
      ),
    );
  }
  int _calculateTotalManDays(Project project) {
    return project.tasks.fold(0, (sum, task) => sum + task.manDay);
  }
  Widget _buildEmptyProjectsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Dodaj pierwszy projekt!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildTaskList(Project project) {
    final sortedTasks = List.from(project.tasks)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedTasks.map((task) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Termin: ${_formatDate(task.dueDate)}"),
                    if (task.isCompleted)
                      Text("Czas pracy: ${task.manDay} manDays"),
                  ],
                ),
              ),
              Checkbox(
                value: task.isCompleted,
                onChanged: (bool? newValue) {
                  setState(() {
                    task.isCompleted = newValue ?? false;
                  });

                  if (task.isCompleted) {
                    _showManDaysDialog(task, project.id!);
                  }
                  else{
                    task.manDay = 0; // Jeśli odznaczony, MD wraca do 0
                  _projectService.updateTask(project.id!, task);
                  }
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  void _showManDaysDialog(Task task, String projectId) {
    final TextEditingController _manDaysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ile MD zajęło wykonanie zadania?"),
          content: TextField(
            controller: _manDaysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Liczba MD",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () {
                final int manDays =
                    int.tryParse(_manDaysController.text) ?? 0;
                setState(() {
                  task.manDay = manDays;
                });
                // Zapis do bazy
                _projectService.updateTask(projectId, task);
                Navigator.pop(context);
              },
              child: const Text("Zapisz"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(String projectId, bool allTasksCompleted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showDeleteConfirmationDialog(projectId),
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text("Usuń projekt", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        ElevatedButton.icon(
          onPressed: allTasksCompleted ? () => _issueInvoiceForProject(projectId) : null,
          icon: const Icon(Icons.receipt_long),
          label: const Text("Wystaw fakturę"),
          style: ElevatedButton.styleFrom(
            backgroundColor: allTasksCompleted ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _issueInvoiceForProject(String projectId) async {
    try {
      Project project = await _projectService.getProjectById(projectId);
      UserDetails userDetails = (await _userService.getCurrentUserDetails())!;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceFormScreen(project: project, userDetails: userDetails),
        ),
      );
    } catch (e) {
      debugPrint("Błąd wystawiania faktury: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie udało się wystawić faktury.")),
      );
    }
  }


  void _showDeleteConfirmationDialog(String projectId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Usuń projekt"),
          content: const Text("Czy na pewno chcesz usunąć ten projekt?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () async {
                await _projectService.deleteProject(projectId);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Usuń", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Wysoki':
        return Colors.red;
      case 'Średni':
        return Colors.orange;
      case 'Niski':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
