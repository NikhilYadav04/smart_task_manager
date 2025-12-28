import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_task_manager/models/task.dart';

class TaskHistory {
  final String id;
  final String taskId;
  final String action;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? changedBy;
  final DateTime changedAt;

  TaskHistory({
    required this.id,
    required this.taskId,
    required this.action,
    this.oldValue,
    this.newValue,
    this.changedBy,
    required this.changedAt,
  });

  factory TaskHistory.fromMap(Map<String, dynamic> map) {
    return TaskHistory(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? map['task_id'] ?? '',
      action: map['action'] ?? '',
      oldValue: map['oldValue'] is Map
          ? Map<String, dynamic>.from(map['oldValue'])
          : null,
      newValue: map['newValue'] is Map
          ? Map<String, dynamic>.from(map['newValue'])
          : null,
      changedBy: map['changedBy'] is Map
          ? (map['changedBy']['name'] ?? map['changedBy'].toString())
          : map['changedBy']?.toString(),
      changedAt: (map['changedAt'] ?? map['changed_at']) != null
          ? DateTime.parse(map['changedAt'] ?? map['changed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'action': action,
      'oldValue': oldValue,
      'newValue': newValue,
      'changedBy': changedBy,
      'changedAt': changedAt.toIso8601String(),
    };
  }

  String get actionText {
    switch (action.toLowerCase()) {
      case 'created':
        return 'Task created';
      case 'updated':
        return 'Task updated';
      case 'status_changed':
        return 'Status changed';
      case 'completed':
        return 'Task completed';
      default:
        return action;
    }
  }

  IconData get actionIcon {
    switch (action.toLowerCase()) {
      case 'created':
        return Icons.add_circle;
      case 'updated':
        return Icons.edit;
      case 'status_changed':
        return Icons.sync_alt;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.history;
    }
  }

  Color get actionColor {
    switch (action.toLowerCase()) {
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      case 'status_changed':
        return Colors.orange;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getChangesSummary() {
    if (action.toLowerCase() == 'created') {
      return 'Task was created';
    }

    if (oldValue == null || newValue == null) {
      return 'Task was modified';
    }

    final List<String> changes = [];

    if (oldValue!['status'] != newValue!['status']) {
      changes.add(
        'Status: ${oldValue!['status']} → ${newValue!['status']}',
      );
    }

    if (oldValue!['priority'] != newValue!['priority']) {
      changes.add(
        'Priority: ${oldValue!['priority']} → ${newValue!['priority']}',
      );
    }

    if (oldValue!['category'] != newValue!['category']) {
      changes.add(
        'Category: ${oldValue!['category']} → ${newValue!['category']}',
      );
    }

    if (oldValue!['title'] != newValue!['title']) {
      changes.add('Title updated');
    }

    if (oldValue!['assignedTo'] != newValue!['assignedTo']) {
      changes.add(
        'Assigned to: ${newValue!['assignedTo'] ?? 'Unassigned'}',
      );
    }

    return changes.isEmpty ? 'Task was modified' : changes.join(', ');
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(changedAt);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class TaskWithHistory {
  final Task task;
  final List<TaskHistory> history;

  TaskWithHistory({
    required this.task,
    required this.history,
  });

  factory TaskWithHistory.fromMap(Map<String, dynamic> map) {
    
    final taskData = Task.fromJson(map);

    
    final historyData = map['history'] != null && map['history'] is List
        ? (map['history'] as List).map((e) => TaskHistory.fromMap(e)).toList()
        : <TaskHistory>[];

    return TaskWithHistory(
      task: taskData,
      history: historyData,
    );
  }

  Map<String, dynamic> toMap() {
    final map = task.toJson();
    map['history'] = history.map((e) => e.toMap()).toList();
    return map;
  }

  String toJson() => jsonEncode(toMap());

  factory TaskWithHistory.fromJson(String source) =>
      TaskWithHistory.fromMap(jsonDecode(source));
}
