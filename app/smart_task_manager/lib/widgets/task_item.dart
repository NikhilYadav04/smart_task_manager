import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_task_manager/models/task.dart';
import 'package:smart_task_manager/providers/task_provider.dart';
import '../utils/task_utils.dart';
import '../screens/tasks/task_detail_bottom_sheet.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.015),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _handleStatusChange(context),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: _getNextStatusIcon(),
              label: _getNextStatusLabel(),
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => _handleDelete(context),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showTaskDetail(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: TaskUtils.getPriorityColor(task.priority),
                    width: isTablet ? 3 : 4,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Title and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.022 : sw * 0.042,
                              fontWeight: FontWeight.w600,
                              decoration: task.status == 'completed'
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        _StatusBadge(
                          status: task.status,
                          sw: sw,
                          isTablet: isTablet,
                        ),
                      ],
                    ),

                    //* Description
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      SizedBox(height: sh * 0.01),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: sh * 0.015),

                    //* Category and Priority Chips
                    Row(
                      children: [
                        _CategoryChip(
                          category: task.category,
                          sw: sw,
                          isTablet: isTablet,
                        ),
                        SizedBox(width: sw * 0.02),
                        _PriorityChip(
                          priority: task.priority,
                          sw: sw,
                          isTablet: isTablet,
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.015),

                    //* Due Date and Assigned To
                    Row(
                      children: [
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: isTablet ? sw * 0.018 : sw * 0.032,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            DateFormat('MMM dd, yyyy').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.016 : sw * 0.03,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: sw * 0.04),
                        ],
                        if (task.assignedTo != null) ...[
                          Icon(
                            Icons.person,
                            size: isTablet ? sw * 0.018 : sw * 0.032,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: sw * 0.01),
                          Expanded(
                            child: Text(
                              task.assignedTo!,
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.016 : sw * 0.03,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNextStatusIcon() {
    switch (task.status) {
      case 'pending':
        return Icons.play_arrow;
      case 'in_progress':
        return Icons.check;
      default:
        return Icons.restart_alt;
    }
  }

  String _getNextStatusLabel() {
    switch (task.status) {
      case 'pending':
        return 'Start';
      case 'in_progress':
        return 'Complete';
      default:
        return 'Reopen';
    }
  }

  Future<void> _handleStatusChange(BuildContext context) async {
    String newStatus;
    switch (task.status) {
      case 'pending':
        newStatus = 'in_progress';
        break;
      case 'in_progress':
        newStatus = 'completed';
        break;
      default:
        newStatus = 'pending';
    }

    final provider = context.read<TaskProvider>();
    final success = await provider.updateTask(task.id, status: newStatus);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task ${_formatStatus(newStatus)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update task'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final sw = MediaQuery.of(context).size.width;
    final bool isTablet = sw > 600;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: TextStyle(
            fontSize: isTablet ? sw * 0.025 : sw * 0.045,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(
            fontSize: isTablet ? sw * 0.02 : sw * 0.038,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: isTablet ? sw * 0.02 : sw * 0.036,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: isTablet ? sw * 0.02 : sw * 0.036,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<TaskProvider>();
      final success = await provider.deleteTask(task.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to delete task'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showTaskDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailBottomSheet(task: task),
    );
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final double sw;
  final bool isTablet;

  const _StatusBadge({
    required this.status,
    required this.sw,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaskUtils.getStatusColor(status);
    final icon = TaskUtils.getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.012 : sw * 0.02,
        vertical: isTablet ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? sw * 0.016 : sw * 0.028,
            color: color,
          ),
          SizedBox(width: sw * 0.01),
          Text(
            TaskUtils.formatStatus(status),
            style: TextStyle(
              fontSize: isTablet ? sw * 0.014 : sw * 0.026,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final double sw;
  final bool isTablet;

  const _CategoryChip({
    required this.category,
    required this.sw,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaskUtils.getCategoryColor(category);
    final icon = TaskUtils.getCategoryIcon(category);

    return Chip(
      avatar: Icon(
        icon,
        size: isTablet ? sw * 0.018 : sw * 0.035,
        color: color,
      ),
      label: Text(
        TaskUtils.capitalize(category),
        style: TextStyle(
          fontSize: isTablet ? sw * 0.016 : sw * 0.028,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  final double sw;
  final bool isTablet;

  const _PriorityChip({
    required this.priority,
    required this.sw,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaskUtils.getPriorityColor(priority);

    return Chip(
      label: Text(
        TaskUtils.capitalize(priority),
        style: TextStyle(
          fontSize: isTablet ? sw * 0.016 : sw * 0.028,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
      visualDensity: VisualDensity.compact,
    );
  }
}

//* Task card Shimmer

class TaskItemShimmer extends StatelessWidget {
  const TaskItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: Colors.white, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16,
                margin: const EdgeInsets.only(right: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskListShimmer extends StatelessWidget {
  const TaskListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: 8,
      itemBuilder: (context, index) {
        return const TaskItemShimmer();
      },
    );
  }
}
