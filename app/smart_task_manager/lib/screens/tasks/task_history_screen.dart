import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_task_manager/models/task.dart';
import 'package:smart_task_manager/models/task_history.dart';
import 'package:smart_task_manager/providers/task_provider.dart';

class TaskHistoryScreen extends StatefulWidget {
  final String taskId;

  const TaskHistoryScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTaskWithHistory(widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: isTablet ? sw * 0.025 : sw * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Task History',
          style: TextStyle(
            fontSize: isTablet ? sw * 0.028 : sw * 0.048,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade300,
            height: 1,
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistory) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: isTablet ? 3 : 4,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.1 : sw * 0.08,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isTablet ? sw * 0.08 : sw * 0.16,
                      color: Colors.red.shade300,
                    ),
                    SizedBox(height: sh * 0.02),
                    Text(
                      'Failed to load history',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: sh * 0.01),
                    Text(
                      provider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: sh * 0.03),
                    FilledButton.icon(
                      onPressed: () {
                        provider.loadTaskWithHistory(widget.taskId);
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: isTablet ? sw * 0.022 : sw * 0.045,
                      ),
                      label: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final taskWithHistory = provider.selectedTaskWithHistory;

          if (taskWithHistory == null) {
            return Center(
              child: Text(
                'No history available',
                style: TextStyle(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTaskWithHistory(widget.taskId),
            child: CustomScrollView(
              slivers: [
                //* Task Details Header
                SliverToBoxAdapter(
                  child: _TaskDetailsHeader(
                    task: taskWithHistory.task,
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                  ),
                ),

                //* History Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? sw * 0.025 : sw * 0.04,
                      sh * 0.02,
                      isTablet ? sw * 0.025 : sw * 0.04,
                      sh * 0.015,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: isTablet ? sw * 0.022 : sw * 0.045,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: sw * 0.02),
                        Text(
                          'Activity History',
                          style: TextStyle(
                            fontSize: isTablet ? sw * 0.022 : sw * 0.042,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? sw * 0.015 : sw * 0.025,
                            vertical: sh * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${taskWithHistory.history.length} events',
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // History Timeline
                if (taskWithHistory.history.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: isTablet ? sw * 0.08 : sw * 0.16,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: sh * 0.02),
                          Text(
                            'No history available',
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                      vertical: sh * 0.01,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final history = taskWithHistory.history[index];
                          final isLast =
                              index == taskWithHistory.history.length - 1;

                          return _HistoryTimelineItem(
                            history: history,
                            isLast: isLast,
                            sw: sw,
                            sh: sh,
                            isTablet: isTablet,
                          );
                        },
                        childCount: taskWithHistory.history.length,
                      ),
                    ),
                  ),

                // Bottom Spacing
                SliverToBoxAdapter(
                  child: SizedBox(height: sh * 0.02),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskDetailsHeader extends StatelessWidget {
  final Task task;
  final double sw;
  final double sh;
  final bool isTablet;

  const _TaskDetailsHeader({
    required this.task,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: TextStyle(
              fontSize: isTablet ? sw * 0.025 : sw * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            SizedBox(height: sh * 0.01),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: sh * 0.015),
          Wrap(
            spacing: sw * 0.02,
            runSpacing: sh * 0.01,
            children: [
              _InfoChip(
                icon: Icons.circle,
                label: task.status.replaceAll('_', ' ').toUpperCase(),
                color: _getStatusColor(task.status),
                sw: sw,
                isTablet: isTablet,
              ),
              _InfoChip(
                icon: Icons.flag,
                label: task.priority.toUpperCase(),
                color: _getPriorityColor(task.priority),
                sw: sw,
                isTablet: isTablet,
              ),
              _InfoChip(
                icon: Icons.category,
                label: task.category.toUpperCase(),
                color: Colors.blue,
                sw: sw,
                isTablet: isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  Color _getPriorityColor(String priority) {
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double sw;
  final bool isTablet;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.sw,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.015 : sw * 0.025,
        vertical: isTablet ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? sw * 0.014 : sw * 0.025,
            color: color,
          ),
          SizedBox(width: sw * 0.01),
          Text(
            label,
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

class _HistoryTimelineItem extends StatelessWidget {
  final TaskHistory history;
  final bool isLast;
  final double sw;
  final double sh;
  final bool isTablet;

  const _HistoryTimelineItem({
    required this.history,
    required this.isLast,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: isTablet ? sw * 0.035 : sw * 0.08,
                height: isTablet ? sw * 0.035 : sw * 0.08,
                decoration: BoxDecoration(
                  color: history.actionColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: history.actionColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  history.actionIcon,
                  size: isTablet ? sw * 0.018 : sw * 0.04,
                  color: history.actionColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          SizedBox(width: sw * 0.03),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : sh * 0.025,
              ),
              child: Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.035),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            history.actionText,
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Text(
                          history.timeAgo,
                          style: TextStyle(
                            fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      history.getChangesSummary(),
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    if (history.changedBy != null) ...[
                      SizedBox(height: sh * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: isTablet ? sw * 0.016 : sw * 0.03,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            history.changedBy!,
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: sh * 0.008),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a')
                          .format(history.changedAt),
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.014 : sw * 0.026,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
