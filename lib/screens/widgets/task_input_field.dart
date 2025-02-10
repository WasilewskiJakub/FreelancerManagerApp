import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/project.dart';
// Model danych zadania:


class TaskInputField extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final DateTime? projectStartDate; // minimalna data
  final DateTime? projectEndDate;   // maksymalna data

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
  // Kontrolery pól tekstowych
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Data wybrana w kalendarzu
  DateTime? _selectedDueDate;

  // Pomocniczy format daty (np. dd.MM.yyyy)
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Funkcja do dodawania zadania
  void _addTask() {
    // Walidacja podstawowa – czy nazwa i data są wypełnione
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

    // Utworzenie obiektu Task
    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate!,
    );

    // Wywołanie callbacku przekazanego z rodzica
    widget.onTaskAdded(task);

    // Wyczyść pola po dodaniu
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDueDate = null;
    });
  }

  // Funkcja pokazująca kalendarz do wyboru daty
  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? widget.projectStartDate ?? now,
      firstDate: widget.projectStartDate ?? DateTime(now.year - 1), // fallback
      lastDate: widget.projectEndDate ?? DateTime(now.year + 1),    // fallback
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

        // Przycisk „Dodaj”
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
