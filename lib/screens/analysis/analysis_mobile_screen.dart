import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/projects/project_service.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ProjectService _projectService = ProjectService();

  String? _userId;

  int _userProjects = 0;
  int _userTasks = 0;
  double _avgTasksPerProject = 0.0;
  Map<String, int> _projectsPerMonth = {};
  Map<String, int> _priorityCounts = {};

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text("Brak zalogowanego użytkownika!")),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: _projectService.getUserProjects(_userId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Błąd Firestore: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                _userProjects = docs.length;

                int totalTasks = 0;
                Map<String, int> projectsPerMonth = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (data['tasks'] != null && data['tasks'] is List) {
                    totalTasks += (data['tasks'] as List).length;
                  }

                  if (data['startDate'] != null && data['startDate'] is Timestamp) {
                    DateTime date = (data['startDate'] as Timestamp).toDate();
                    String monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";
                    projectsPerMonth[monthKey] = (projectsPerMonth[monthKey] ?? 0) + 1;
                  }
                }

                Map<String, int> priorityCounts = {"Niski": 0, "Średni": 0, "Wysoki": 0};
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  if (data['priority'] != null) {
                    String priority = data['priority'];
                    if (priorityCounts.containsKey(priority)) {
                      priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
                    }
                  }
                }
                _userTasks = totalTasks;
                _avgTasksPerProject = _userProjects == 0 ? 0.0 : (totalTasks / _userProjects);
                _projectsPerMonth = projectsPerMonth;
                _priorityCounts = priorityCounts;
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildStatCard("Liczba Twoich projektów", "$_userProjects", Icons.folder),
                    _buildStatCard("Łączna liczba tasków", "$_userTasks", Icons.check_circle),
                    _buildStatCard("Średnia liczba tasków na projekt",
                        _avgTasksPerProject.toStringAsFixed(2), Icons.bar_chart),
                    const SizedBox(height: 20),
                    _buildProjectsPerMonthChart(_projectsPerMonth),
                    buildPriorityPieChart(_priorityCounts),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProjectsPerMonthChart(Map<String, int> projectsPerMonth) {
    if (projectsPerMonth.isEmpty) {
      return const Center(child: Text("Brak danych do wyświetlenia"));
    }

    List<String> months = projectsPerMonth.keys.toList();
    months.sort();

    List<BarChartGroupData> barGroups = [];
    int index = 0;

    for (String month in months) {
      int value = projectsPerMonth[month] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: Colors.deepPurple,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    }

    Map<int, String> monthLabels = {};
    for (int i = 0; i < months.length; i++) {
      DateTime parsedDate = DateTime.parse("${months[i]}-01");
      monthLabels[i] = DateFormat.MMM().format(parsedDate);
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Liczba projektów na miesiąc",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(monthLabels[value] ?? "", style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPriorityPieChart(Map<String, int> priorityCounts) {
    if (priorityCounts.isEmpty) {
      return const Center(child: Text("Brak danych do wyświetlenia"));
    }

    int totalProjects = priorityCounts.values.fold(0, (sum, value) => sum + value);

    List<PieChartSectionData> sections = [];
    List<Color> colors = [Colors.green, Colors.orange, Colors.red];
    List<String> priorityLabels = ["Niski", "Średni", "Wysoki"];

    int index = 0;
    priorityCounts.forEach((priority, count) {
      final double percentage = (count / totalProjects) * 100;

      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          color: colors[index % colors.length],
          title: "${percentage.toStringAsFixed(1)}%",
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rozkład priorytetów projektów",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(priorityLabels.length, (i) {
                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[i],
                    ),
                    const SizedBox(width: 4),
                    Text(priorityLabels[i]),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

}
