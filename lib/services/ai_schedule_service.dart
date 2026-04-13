import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  final String _apiKey = 'API Key';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || tasks.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      final taskList = tasks
          .map((t) =>
      "${t.title} (${t.category}) ${t.startTime.hour}:${t.startTime.minute.toString().padLeft(2, '0')}")
          .join("\n");

      _currentAnalysis = ScheduleAnalysis(
        conflicts: "No conflicts detected (Web mode)",
        rankedTasks: taskList,
        recommendedSchedule:
        "Tasks are listed in their current order. Adjust based on urgency and importance if needed.",
        explanation:
        "AI API is not available on web directly, so this fallback ensures the app continues to function.",
      );
    } catch (e) {
      _errorMessage = 'Failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}