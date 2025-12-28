import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_task_manager/providers/task_provider.dart';
import 'package:smart_task_manager/screens/tasks/task_update_screen.dart';
import '../../models/task.dart';
import '../../utils/task_utils.dart';

class TaskDetailBottomSheet extends StatelessWidget {
  final Task task;

  const TaskDetailBottomSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //* Header
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.028 : sw * 0.052,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: isTablet ? sw * 0.025 : sw * 0.06,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          //* Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.03 : sw * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* Title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.048,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: sh * 0.02),

                  //* Status, Category, Priority
                  Wrap(
                    spacing: sw * 0.02,
                    runSpacing: sh * 0.01,
                    children: [
                      _buildStatusChip(context, sw, isTablet),
                      _buildCategoryChip(context, sw, isTablet),
                      _buildPriorityChip(context, sw, isTablet),
                    ],
                  ),
                  SizedBox(height: sh * 0.03),

                  //* Description
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.description,
                      title: 'Description',
                      sw: sw,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: sh * 0.01),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sh * 0.03),
                  ],

                  //* Due Date
                  if (task.dueDate != null) ...[
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Due Date',
                      value: DateFormat('EEEE, MMM dd, yyyy')
                          .format(task.dueDate!),
                      sw: sw,
                      sh: sh,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: sh * 0.015),
                  ],

                  //* Assigned To
                  if (task.assignedTo != null) ...[
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Assigned To',
                      value: task.assignedTo!,
                      sw: sw,
                      sh: sh,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: sh * 0.015),
                  ],

                  //* Created At
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Created',
                    value: DateFormat('MMM dd, yyyy hh:mm a')
                        .format(task.createdAt),
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: sh * 0.03),

                  //* Extracted Entities
                  if (task.extractedEntities != null &&
                      task.extractedEntities!.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.auto_awesome,
                      title: 'Extracted Information',
                      sw: sw,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: sh * 0.015),
                    _ExtractedEntitiesCard(
                      entities: task.extractedEntities!,
                      sw: sw,
                      sh: sh,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: sh * 0.03),
                  ],

                  //* Suggested Actions
                  if (task.suggestedActions != null &&
                      task.suggestedActions!.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.lightbulb_outline,
                      title: 'Suggested Actions',
                      sw: sw,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: sh * 0.015),
                    Wrap(
                      spacing: sw * 0.02,
                      runSpacing: sh * 0.01,
                      children: task.suggestedActions!.map((action) {
                        return Chip(
                          avatar: Icon(
                            Icons.check_circle_outline,
                            size: isTablet ? sw * 0.018 : sw * 0.035,
                          ),
                          label: Text(
                            action,
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                            ),
                          ),
                          backgroundColor: Colors.green.shade50,
                          side: BorderSide(color: Colors.green.shade200),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: sh * 0.03),

                  //* Edit and Delete Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    UpdateTaskBottomSheet(task: task),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? sh * 0.012 : sh * 0.015,
                                horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: isTablet ? sw * 0.02 : sw * 0.04,
                                    color: Colors.blue.shade700,
                                  ),
                                  SizedBox(width: sw * 0.02),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize:
                                          isTablet ? sw * 0.02 : sw * 0.038,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              //* Delete functionality
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.red.shade700,
                                          size:
                                              isTablet ? sw * 0.028 : sw * 0.06,
                                        ),
                                        SizedBox(width: sw * 0.02),
                                        Text(
                                          'Delete Task',
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? sw * 0.024
                                                : sw * 0.045,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this task? This action cannot be undone.',
                                      style: TextStyle(
                                        fontSize:
                                            isTablet ? sw * 0.02 : sw * 0.038,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? sw * 0.02
                                                : sw * 0.038,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          provider.deleteTask(task.id);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              content: Text('Deleting Task'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );

                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? sw * 0.02
                                                : sw * 0.038,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? sh * 0.012 : sh * 0.015,
                                horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: isTablet ? sw * 0.02 : sw * 0.04,
                                    color: Colors.red.shade700,
                                  ),
                                  SizedBox(width: sw * 0.02),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize:
                                          isTablet ? sw * 0.02 : sw * 0.038,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, double sw, bool isTablet) {
    final color = TaskUtils.getStatusColor(task.status);
    final icon = TaskUtils.getStatusIcon(task.status);

    return Chip(
      avatar: Icon(
        icon,
        size: isTablet ? sw * 0.018 : sw * 0.035,
        color: color,
      ),
      label: Text(
        TaskUtils.formatStatus(task.status),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: isTablet ? sw * 0.018 : sw * 0.032,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildCategoryChip(BuildContext context, double sw, bool isTablet) {
    final color = TaskUtils.getCategoryColor(task.category);
    final icon = TaskUtils.getCategoryIcon(task.category);

    return Chip(
      avatar: Icon(
        icon,
        size: isTablet ? sw * 0.018 : sw * 0.035,
        color: color,
      ),
      label: Text(
        TaskUtils.capitalize(task.category),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: isTablet ? sw * 0.018 : sw * 0.032,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildPriorityChip(BuildContext context, double sw, bool isTablet) {
    final color = TaskUtils.getPriorityColor(task.priority);

    return Chip(
      label: Text(
        '${TaskUtils.capitalize(task.priority)} Priority',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: isTablet ? sw * 0.018 : sw * 0.032,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final double sw;
  final bool isTablet;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.sw,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? sw * 0.022 : sw * 0.045,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: sw * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? sw * 0.022 : sw * 0.042,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double sw;
  final double sh;
  final bool isTablet;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isTablet ? sw * 0.022 : sw * 0.045,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: sh * 0.003),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExtractedEntitiesCard extends StatelessWidget {
  final Map<String, dynamic> entities;
  final double sw;
  final double sh;
  final bool isTablet;

  const _ExtractedEntitiesCard({
    required this.entities,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final dates = entities['dates'] as List? ?? [];
    final people = entities['people'] as List? ?? [];
    final locations = entities['locations'] as List? ?? [];
    final actions = entities['actions'] as List? ?? [];

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dates.isNotEmpty) ...[
              _EntityRow(
                icon: Icons.event,
                label: 'Dates',
                items: dates.cast<String>(),
                sw: sw,
                sh: sh,
                isTablet: isTablet,
              ),
              if (people.isNotEmpty ||
                  locations.isNotEmpty ||
                  actions.isNotEmpty)
                SizedBox(height: sh * 0.015),
            ],
            if (people.isNotEmpty) ...[
              _EntityRow(
                icon: Icons.person,
                label: 'People',
                items: people.cast<String>(),
                sw: sw,
                sh: sh,
                isTablet: isTablet,
              ),
              if (locations.isNotEmpty || actions.isNotEmpty)
                SizedBox(height: sh * 0.015),
            ],
            if (locations.isNotEmpty) ...[
              _EntityRow(
                icon: Icons.location_on,
                label: 'Locations',
                items: locations.cast<String>(),
                sw: sw,
                sh: sh,
                isTablet: isTablet,
              ),
              if (actions.isNotEmpty) SizedBox(height: sh * 0.015),
            ],
            if (actions.isNotEmpty) ...[
              _EntityRow(
                icon: Icons.bolt,
                label: 'Actions',
                items: actions.cast<String>(),
                sw: sw,
                sh: sh,
                isTablet: isTablet,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final double sw;
  final double sh;
  final bool isTablet;

  const _EntityRow({
    required this.icon,
    required this.label,
    required this.items,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isTablet ? sw * 0.018 : sw * 0.035,
              color: Colors.blue.shade700,
            ),
            SizedBox(width: sw * 0.015),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.008),
        Wrap(
          spacing: sw * 0.015,
          runSpacing: sh * 0.008,
          children: items.map((item) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.015 : sw * 0.025,
                vertical: sh * 0.005,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
