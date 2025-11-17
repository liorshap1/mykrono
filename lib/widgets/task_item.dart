import 'package:flutter/material.dart';
import 'package:forui/widgets/button.dart';
import 'package:forui/widgets/dialog.dart';
import 'package:mykrono/core/screens/space_screen.dart';
import 'package:mykrono/widgets/custom_badge.dart';

class TaskItem extends StatelessWidget {
  final int taskId;
  final String task;
  final Priority priority;
  final String taskDueDate;
  final BuildContext parentContext;
  final Future<void> Function(int) onRemoveTask;

  const TaskItem({
    super.key,
    required this.taskId,
    required this.task,
    required this.priority,
    required this.taskDueDate,
    required this.onRemoveTask, required this.parentContext,
  });

  Color _priorityColor() {
    return switch (priority) {
      Priority.low => const Color(0xFF4CAF50),
      Priority.medium => const Color(0xFFFF9800),
      Priority.high => const Color(0xFFF44336),
    };
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return "$day/$month";
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    await showFDialog(
      context: context,
      builder: (context, style, animation) => FDialog(
        style: style.call,
        animation: animation,
        title: const Text("Are you sure?"),
        body: const Text(
          "This action cannot be undone. This will permanently remove your task!",
        ),
        direction: Axis.horizontal,
        actions: [
          FButton(
            style: FButtonStyle.outline(),
            onPress: () {
              Navigator.of(context).pop(); 
            },
            child: const Text("Cancel"),
          ),
          FButton(
            onPress: () async {
              Navigator.of(context).pop();
              await onRemoveTask(taskId); 
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor();
    final formattedDate = _formatDate(taskDueDate);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        await _showDeleteDialog(parentContext);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(
              task,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                CustomBadge(text: priority.name.toUpperCase(), color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
