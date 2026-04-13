import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});

  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _category = 'Class';
  DateTime _date = DateTime.now();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  double _urgency = 3, _importance = 3, _effort = 1.0;
  String _energy = 'Medium';

  final List<String> _cats = ['Class', 'Org Work', 'Study', 'Rest', 'Other'];
  final List<String> _energies = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = now;
    _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_endTime.hour < _startTime.hour ||
          (_endTime.hour == _startTime.hour &&
              _endTime.minute <= _startTime.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End time must be after start time")),
        );
        return;
      }

      _formKey.currentState!.save();

      Provider.of<ScheduleProvider>(context, listen: false).addTask(
        title: _title,
        category: _category,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        urgency: _urgency.toInt(),
        importance: _importance.toInt(),
        estimatedEffortHours: _effort,
        energyLevel: _energy,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1EB),
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard(
                child: TextFormField(
                  decoration: _inputDecoration('Task Title'),
                  onSaved: (value) => _title = value ?? '',
                ),
              ),
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDecoration('Category'),
                  items: _cats
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
              ),
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _timeButton(
                        label: "Start",
                        time: _startTime.format(context),
                        onTap: () => _pickTime(true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _timeButton(
                        label: "End",
                        time: _endTime.format(context),
                        onTap: () => _pickTime(false),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCard(
                child: Column(
                  children: [
                    _sliderRow("Urgency", _urgency),
                    Slider(
                      value: _urgency,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: const Color(0xFF6C63FF),
                      onChanged: (val) => setState(() => _urgency = val),
                    ),
                    _sliderRow("Importance", _importance),
                    Slider(
                      value: _importance,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: const Color(0xFF6C63FF),
                      onChanged: (val) => setState(() => _importance = val),
                    ),
                  ],
                ),
              ),
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _energy,
                  decoration: _inputDecoration('Energy Level'),
                  items: _energies
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _energy = val!),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Add Task to Timeline'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _timeButton(
      {required String label,
        required String time,
        required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFF6C63FF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6C63FF))),
          Text(time,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF))),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value.toInt().toString()),
      ],
    );
  }
}