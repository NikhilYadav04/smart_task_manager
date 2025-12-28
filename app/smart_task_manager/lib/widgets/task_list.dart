import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_task_manager/providers/task_provider.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return TaskListShimmer();
        }

        if (provider.hasError) {
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
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: sh * 0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.05 : sw * 0.04,
                    ),
                    child: Text(
                      provider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.03),
                  FilledButton.icon(
                    onPressed: () => provider.loadTasks(),
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
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? sw * 0.04 : sw * 0.06,
                        vertical: isTablet ? sh * 0.015 : sh * 0.018,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.1 : sw * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: isTablet ? sw * 0.08 : sw * 0.16,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: sh * 0.02),
                  Text(
                    'No tasks found',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: sh * 0.01),
                  Text(
                    'Create a new task to get started',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          strokeWidth: isTablet ? 2.5 : 3,
          child: ListView.builder(
            padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            itemCount: provider.filteredTasks.length,
            itemBuilder: (context, index) {
              final task = provider.filteredTasks[index];
              return TaskItem(task: task);
            },
          ),
        );
      },
    );
  }
}
