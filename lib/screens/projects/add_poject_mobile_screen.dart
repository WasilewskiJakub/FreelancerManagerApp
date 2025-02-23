import 'package:flutter/material.dart';
import '../../services/projects/project_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/task_input_field.dart';
import 'package:intl/intl.dart';
import '../../domain/project.dart';


class AddProjectScreen extends StatefulWidget {
  final User user;

  const AddProjectScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  String _description = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _priority = 'Średni';
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _validateStep() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    if (_currentStep == 1) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Wybierz daty rozpoczęcia i zakończenia projektu."),
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _nextStep() {
    if (!_validateStep()) return;
    _formKey.currentState!.save();
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProjectToFirebase();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveProjectToFirebase() async {
    try {
      final newProject = Project(
        id: null,
        userId: widget.user.uid,
        name: _projectName,
        description: _description,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
        priority: _priority,
        tasks: _tasks,
      );

      await ProjectService().addProject(newProject);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Błąd podczas dodawania projektu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dodaj projekt",
          style: const TextStyle(color: Colors.white)
          ),
        backgroundColor: const Color.fromARGB(255, 68, 20, 100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProgressBar(),
            Form(
              key: _formKey,
              child: Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _step1(),
                    _step2(),
                    _step3(),
                    _step4(),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LinearProgressIndicator(
        value: (_currentStep + 1) / 4,
        backgroundColor: Colors.grey[300],
        color: const Color.fromARGB(255, 68, 20, 100),
      ),
    );
  }

  Widget _step1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Krok 1: Informacje o projekcie",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nazwa projektu'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Podaj nazwę projektu' : null,
              onSaved: (value) => _projectName = value ?? '',
              onChanged: (value) => _projectName = value,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Opis projektu'),
              maxLines: 3,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Podaj opis projektu' : null,
              onSaved: (value) => _description = value ?? '',
              onChanged: (value) => _description = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _step2() {
  final DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Krok 2: Daty projektu",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildDatePickerField(
            label: 'Data rozpoczęcia',
            selectedDate: _startDate,
            onDatePicked: (picked) {
              setState(() {
                _startDate = picked;
                _endDate = null;
              });
            },
            dateFormat: dateFormat,
          ),
          const SizedBox(height: 16),

          _buildDatePickerField(
            label: 'Data zakończenia',
            selectedDate: _endDate,
            onDatePicked: (picked) => setState(() => _endDate = picked),
            dateFormat: dateFormat,
            enabled: _startDate != null,
            firstDate: _startDate,
          ),
        ],
      ),
    ),
  );
}



  Widget _step3() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Krok 3: Priorytet projektu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priorytet'),
              items: const ['Wysoki', 'Średni', 'Niski']
                  .map((label) => DropdownMenuItem<String>(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value ?? 'Średni'),
              onSaved: (value) => _priority = value ?? 'Średni',
            ),
          ],
        ),
      ),
    );
  }

  Widget _step4() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TaskInputField(
              projectStartDate: _startDate,
              projectEndDate: _endDate,
              onTaskAdded: (task) {
                setState(() {
                  _tasks.add(task);
                  _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
                });
              },
            ),
            const SizedBox(height: 10),
            Column(
              children: _tasks.map((task) {
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    "${task.description}\nTermin: ${DateFormat('dd.MM.yyyy').format(task.dueDate)}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _tasks.remove(task);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _prevStep,
              child: const Text('Wstecz'),
            ),
          ElevatedButton(
            onPressed: _nextStep,
            child: Text(_currentStep == 3 ? 'Zapisz' : 'Dalej'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDatePicked,
    required DateFormat dateFormat,
    bool enabled = true,
    DateTime? firstDate,
  }) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: selectedDate == null ? '' : dateFormat.format(selectedDate),
      ),
      onTap: enabled
          ? () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? (firstDate ?? DateTime.now()),
                firstDate: firstDate ?? DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                onDatePicked(picked);
              }
            }
          : null,
      validator: (value) {
        if ((selectedDate == null || value == null || value.isEmpty) && label.contains('rozpoczęcia')) {
          return 'Wybierz datę rozpoczęcia';
        }
        if ((selectedDate == null || value == null || value.isEmpty) && label.contains('zakończenia')) {
          return 'Wybierz datę zakończenia';
        }
        if (label.contains('zakończenia') && firstDate != null && selectedDate != null && selectedDate.isBefore(firstDate)) {
          return 'Data zakończenia nie może być wcześniejsza niż data rozpoczęcia';
        }
        return null;
      },
    );
  }


}
