import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/project.dart';

class TaskInputField extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final DateTime? projectStartDate;
  final DateTime? projectEndDate;

  const TaskInputField({
    Key? key,
    required this.onTaskAdded,
    this.projectStartDate,
    this.projectEndDate,
  }) : super(key: key);

  @override
  _TaskInputFieldState createState() => _TaskInputFieldState();
}

class _TaskInputFieldState extends State<TaskInputField> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime? _selectedDueDate;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  void _addTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz nazwę zadania.')),
      );
      return;
    }
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz datę dla zadania.')),
      );
      return;
    }

    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate!,
    );

    widget.onTaskAdded(task);

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDueDate = null;
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? widget.projectStartDate ?? now,
      firstDate: widget.projectStartDate ?? DateTime(now.year - 1),
      lastDate: widget.projectEndDate ?? DateTime(now.year + 1),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      // Pole: Nazwa zadania
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: "Nazwa zadania",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),

        // Pole: Opis zadania
        TextField(
          controller: _descriptionController,
          maxLines: 2, // lub ile potrzebujesz
          decoration: const InputDecoration(
            labelText: "Opis zadania",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),

        // Pole: Data
        InkWell(
          onTap: _pickDueDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data zadania',
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDueDate == null
                      ? 'Wybierz datę'
                      : _dateFormat.format(_selectedDueDate!),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
            label: const Text('Dodaj zadanie'),
          ),
        ),
      ],
    );
  }
}
