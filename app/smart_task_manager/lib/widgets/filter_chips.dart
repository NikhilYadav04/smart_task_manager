import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_task_manager/providers/task_provider.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final hasFilters = provider.statusFilter != null ||
            provider.categoryFilter != null ||
            provider.priorityFilter != null;

        if (!hasFilters) {
          return const SizedBox.shrink();
        }

        return Container(
          height: isTablet ? sh * 0.06 : sh * 0.065,
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? sw * 0.025 : sw * 0.04,
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (provider.statusFilter != null)
                _buildFilterChip(
                  context,
                  label: 'Status: ${_formatStatus(provider.statusFilter!)}',
                  onDeleted: () {
                    provider.setStatusFilter(null);
                    provider.loadTasks();
                  },
                  sw: sw,
                  isTablet: isTablet,
                ),
              if (provider.categoryFilter != null)
                _buildFilterChip(
                  context,
                  label: 'Category: ${_capitalize(provider.categoryFilter!)}',
                  onDeleted: () {
                    provider.setCategoryFilter(null);
                    provider.loadTasks();
                  },
                  sw: sw,
                  isTablet: isTablet,
                ),
              if (provider.priorityFilter != null)
                _buildFilterChip(
                  context,
                  label: 'Priority: ${_capitalize(provider.priorityFilter!)}',
                  onDeleted: () {
                    provider.setPriorityFilter(null);
                    provider.loadTasks();
                  },
                  sw: sw,
                  isTablet: isTablet,
                ),
              Padding(
                padding: EdgeInsets.only(left: sw * 0.01),
                child: TextButton.icon(
                  onPressed: () {
                    provider.clearFilters();
                    provider.loadTasks();
                  },
                  icon: Icon(
                    Icons.clear_all,
                    size: isTablet ? sw * 0.02 : sw * 0.04,
                  ),
                  label: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.02 : sw * 0.03,
                      vertical: isTablet ? sh * 0.01 : sh * 0.012,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required VoidCallback onDeleted,
    required double sw,
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: sw * 0.02),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? sw * 0.018 : sw * 0.032,
            fontWeight: FontWeight.w500,
          ),
        ),
        onDeleted: onDeleted,
        deleteIcon: Icon(
          Icons.close,
          size: isTablet ? sw * 0.02 : sw * 0.04,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.015 : sw * 0.025,
          vertical: isTablet ? 6 : 8,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map(_capitalize).join(' ');
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
