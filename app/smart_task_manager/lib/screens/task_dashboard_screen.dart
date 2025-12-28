import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/summary_cards.dart';
import '../widgets/task_list.dart';
import '../widgets/filter_chips.dart';
import 'tasks/create_task_bottom_sheet.dart';
import '../widgets/offline_banner.dart';

class TaskDashboardScreen extends StatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  State<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _onSearchChanged() {
    setState(() {}); // Rebuild to show/hide clear button
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<TaskProvider>();
    await Future.wait([
      provider.loadTasks(),
      provider.loadStats(),
    ]);
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<TaskProvider>();
    await provider.refresh();
  }

  void _showCreateTaskSheet(double sw, double sh, bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTaskBottomSheet(),
    );
  }

  void _showFilterSheet(double sw, double sh, bool isTablet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FilterBottomSheet(sw: sw, sh: sh, isTablet: isTablet),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Task Manager',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? sw * 0.03 : sw * 0.045,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: isTablet ? sw * 0.025 : sw * 0.05,
            ),
            onPressed: () => _showFilterSheet(sw, sh, isTablet),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Offline Banner
            const OfflineBanner(),

            // Search Bar
            _buildSearchBar(sw, sh, isTablet),

            // Summary Cards
            const SummaryCards(),

            SizedBox(height: sh * 0.016),

            // Filter Chips
            const FilterChips(),

            // Task List
            const Expanded(
              child: TaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskSheet(sw, sh, isTablet),
        icon: Icon(Icons.add, size: isTablet ? sw * 0.02 : sw * 0.04),
        label: Text(
          'New Task',
          style: TextStyle(fontSize: isTablet ? sw * 0.02 : sw * 0.035),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double sw, double sh, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            fontSize: isTablet ? sw * 0.022 : sw * 0.036,
          ),
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: TextStyle(
              fontSize: isTablet ? sw * 0.022 : sw * 0.036,
              color: Colors.grey.shade600,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: isTablet ? sw * 0.025 : sw * 0.045,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: isTablet ? sw * 0.025 : sw * 0.045,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<TaskProvider>().setSearchQuery(null);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.015,
            ),
          ),
          onChanged: (value) {
            context.read<TaskProvider>().setSearchQuery(
                  value.isEmpty ? null : value,
                );
          },
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const FilterBottomSheet({
    super.key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(sw * 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: sw * 0.12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: isTablet ? sw * 0.028 : sw * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearFilters();
                            provider.loadTasks();
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.016),

                    // Status Filter
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Wrap(
                      spacing: sw * 0.02,
                      runSpacing: sh * 0.01,
                      children: [
                        FilterChip(
                          label: const Text('Pending'),
                          selected: provider.statusFilter == 'pending',
                          onSelected: (selected) {
                            provider
                                .setStatusFilter(selected ? 'pending' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('In Progress'),
                          selected: provider.statusFilter == 'in_progress',
                          onSelected: (selected) {
                            provider.setStatusFilter(
                                selected ? 'in_progress' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('Completed'),
                          selected: provider.statusFilter == 'completed',
                          onSelected: (selected) {
                            provider
                                .setStatusFilter(selected ? 'completed' : null);
                            provider.loadTasks();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.016),

                    // Priority Filter
                    Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Wrap(
                      spacing: sw * 0.02,
                      runSpacing: sh * 0.01,
                      children: [
                        FilterChip(
                          label: const Text('High'),
                          selected: provider.priorityFilter == 'high',
                          onSelected: (selected) {
                            provider
                                .setPriorityFilter(selected ? 'high' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('Medium'),
                          selected: provider.priorityFilter == 'medium',
                          onSelected: (selected) {
                            provider
                                .setPriorityFilter(selected ? 'medium' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('Low'),
                          selected: provider.priorityFilter == 'low',
                          onSelected: (selected) {
                            provider.setPriorityFilter(selected ? 'low' : null);
                            provider.loadTasks();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.016),

                    // Category Filter
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Wrap(
                      spacing: sw * 0.02,
                      runSpacing: sh * 0.01,
                      children: [
                        FilterChip(
                          label: const Text('Scheduling'),
                          selected: provider.categoryFilter == 'scheduling',
                          onSelected: (selected) {
                            provider.setCategoryFilter(
                                selected ? 'scheduling' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('Finance'),
                          selected: provider.categoryFilter == 'finance',
                          onSelected: (selected) {
                            provider
                                .setCategoryFilter(selected ? 'finance' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('Technical'),
                          selected: provider.categoryFilter == 'technical',
                          onSelected: (selected) {
                            provider.setCategoryFilter(
                                selected ? 'technical' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('Safety'),
                          selected: provider.categoryFilter == 'safety',
                          onSelected: (selected) {
                            provider
                                .setCategoryFilter(selected ? 'safety' : null);
                            provider.loadTasks();
                          },
                        ),
                        FilterChip(
                          label: const Text('General'),
                          selected: provider.categoryFilter == 'general',
                          onSelected: (selected) {
                            provider
                                .setCategoryFilter(selected ? 'general' : null);
                            provider.loadTasks();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.024),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
