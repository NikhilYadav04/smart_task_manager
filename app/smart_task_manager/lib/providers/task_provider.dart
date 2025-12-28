import 'package:flutter/foundation.dart';
import 'package:smart_task_manager/services/api_services.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService;

  TaskProvider(this._apiService);

  //* State
  List<Task> _tasks = [];
  TaskStats? _stats;
  bool _isLoading = false;
  String? _error;

  //* Filters
  String? _statusFilter;
  String? _categoryFilter;
  String? _priorityFilter;
  String? _searchQuery;

  //* Getters
  List<Task> get tasks => _tasks;
  TaskStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;
  String? get priorityFilter => _priorityFilter;
  String? get searchQuery => _searchQuery;

  //* Filtered tasks
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      if (_statusFilter != null && task.status != _statusFilter) {
        return false;
      }
      if (_categoryFilter != null && task.category != _categoryFilter) {
        return false;
      }
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        return task.title.toLowerCase().contains(query) ||
            (task.description?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }

  //* Load tasks
  Future<void> loadTasks({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _tasks = await _apiService.getTasks(
        status: _statusFilter,
        category: _categoryFilter,
        priority: _priorityFilter,
        search: _searchQuery,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //* Load statistics
  Future<void> loadStats() async {
    try {
      _stats = await _apiService.getTaskStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  //* Create task
  Future<Task?> createTask({
    required String title,
    String? description,
    String? category,
    String? priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      _error = null;
      final task = await _apiService.createTask(
        title: title,
        description: description,
        category: category,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

      await loadTasks(showLoading: false);
      await loadStats();
      return task;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  //* Update task
  Future<bool> updateTask(
    String id, {
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      _error = null;
      await _apiService.updateTask(
        id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: status,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

      await loadTasks(showLoading: false);
      await loadStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  //* Delete task
  Future<bool> deleteTask(String id) async {
    try {
      _error = null;
      await _apiService.deleteTask(id);

      await loadTasks(showLoading: false);
      await loadStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  //* Preview classification
  Future<ClassificationPreview?> previewClassification({
    required String title,
    String? description,
  }) async {
    try {
      return await _apiService.previewClassification(
        title: title,
        description: description,
      );
    } catch (e) {
      debugPrint('Error previewing classification: $e');
      return null;
    }
  }

  //* Set filters
  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  //* Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _priorityFilter = null;
    _searchQuery = null;
    notifyListeners();
  }

  //* Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  //* Refresh
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadTasks(showLoading: false),
      loadStats(),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}
