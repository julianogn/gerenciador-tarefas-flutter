import 'package:flutter/material.dart';

import 'presentation/controllers/task_controller.dart';
import 'presentation/views/task_list_page.dart';

class TaskApp extends StatelessWidget {
  const TaskApp({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: TaskListPage(controller: controller),
    );
  }
}
