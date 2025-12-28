import 'package:flutter/material.dart';

class TaskUtils {
  //* Status Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  //* Status Icons
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;
      case 'in_progress':
        return Icons.autorenew;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  //* Priority Colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  //* Category Colors
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'scheduling':
        return Colors.purple;
      case 'finance':
        return Colors.teal;
      case 'technical':
        return Colors.indigo;
      case 'safety':
        return Colors.red;
      case 'general':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  //* Category Icons
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'scheduling':
        return Icons.calendar_today;
      case 'finance':
        return Icons.attach_money;
      case 'technical':
        return Icons.build;
      case 'safety':
        return Icons.shield;
      case 'general':
        return Icons.task;
      default:
        return Icons.category;
    }
  }

  //* Format Status
  static String formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  //* Get relative time
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  //* Check if date is overdue
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  //* Get days until due
  static int? getDaysUntilDue(DateTime? dueDate) {
    if (dueDate == null) return null;
    return dueDate.difference(DateTime.now()).inDays;
  }
}
