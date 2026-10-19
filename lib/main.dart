import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'application/task_service.dart';
import 'infrastructure/shared_preferences_task_repository.dart';
import 'presentation/controllers/task_controller.dart';

/// Composition root: the only place that knows the concrete classes.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = SharedPreferencesTaskRepository(SharedPreferencesAsync());
  final controller = TaskController(TaskService(repository));
  runApp(TaskApp(controller: controller));
}
