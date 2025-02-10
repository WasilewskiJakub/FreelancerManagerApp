import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/projects/project_service.dart';
import '../../domain/project.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final ProjectService _projectService = ProjectService();
  User? _user;
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Task>> _tasksByDate = {};
  List<Task> _selectedDayTasks = [];
  bool _groupByProjects = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _projectService.getUserProjects(_user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data!.docs
              .map((doc) => Project.fromDocument(doc))
              .toList();

          _tasksByDate = _mapTasksByDate(projects);
          _selectedDayTasks = _tasksByDate[_normalizeDate(_selectedDay)] ?? [];

          return Column(
            children: [
              _buildCalendar(),
              _buildToggleView(),
              Expanded(
                child: _groupByProjects
                    ? _buildTasksByProject(projects)
                    : _buildTaskList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<Task>> _mapTasksByDate(List<Project> projects) {
    Map<DateTime, List<Task>> taskMap = {};

    for (var project in projects) {
      for (var task in project.tasks) {
        DateTime taskDate = _normalizeDate(task.dueDate);
        if (!taskMap.containsKey(taskDate)) {
          taskMap[taskDate] = [];
        }
        taskMap[taskDate]!.add(task);
      }
    }
    return taskMap;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _selectedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Miesiąc',
        CalendarFormat.week: 'Tydzień',
      },
      eventLoader: (day) => _tasksByDate[_normalizeDate(day)] ?? [],
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _selectedDayTasks = _tasksByDate[_normalizeDate(selectedDay)] ?? [];
        });
      },
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 68, 20, 100),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildToggleView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Grupuj:"),
          ToggleButtons(
            isSelected: [_groupByProjects, !_groupByProjects],
            onPressed: (index) {
              setState(() {
                _groupByProjects = index == 0;
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: const Color.fromARGB(255, 68, 20, 100),
            children: const [
              Padding(padding: EdgeInsets.all(8.0), child: Text("Po projektach")),
              Padding(padding: EdgeInsets.all(8.0), child: Text("Brak")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _selectedDayTasks.length,
      itemBuilder: (context, index) {
        final task = _selectedDayTasks[index];
        return _buildTaskTile(task);
      },
    );
  }

  Widget _buildTasksByProject(List<Project> projects) {
    Map<String, List<Task>> groupedTasks = {};

    for (var project in projects) {
      for (var task in project.tasks) {
        if (_normalizeDate(task.dueDate) == _normalizeDate(_selectedDay)) {
          if (!groupedTasks.containsKey(project.name)) {
            groupedTasks[project.name] = [];
          }
          groupedTasks[project.name]!.add(task);
        }
      }
    }

    return ListView(
      children: groupedTasks.entries.map((entry) {
        return ExpansionTile(
          title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: entry.value.map((task) => _buildTaskTile(task)).toList(),
        );
      }).toList(),
    );
  }

  void _showTaskDetails(Task task, String projectName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Projekt: $projectName"),
              Text("Termin: ${_formatDate(task.dueDate)}"),
              Text("Opis: ${task.description}"),
              Text("Czy ukończone: ${task.isCompleted ? "Tak" : "Nie"}"),
              if (task.isCompleted) Text("Czas pracy: ${task.manDay} ManDays"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(Task task) {
    return ListTile(
      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Termin: ${_formatDate(task.dueDate)}"),
      trailing: Checkbox(
        value: task.isCompleted,
        onChanged: (bool? newValue) {
          setState(() {
            task.isCompleted = newValue ?? false;
          });
          _projectService.updateTask(task.title, task);
        },
      ),
      onTap: () => _showTaskDetails(task, task.title),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
