import 'package:dio/dio.dart';
import 'package:smart_task_manager/models/task_history.dart';
import '../models/task.dart';

class ApiService {
  late final Dio _dio;

  static const String baseUrl = 'https://smart-task-manager-fu6v.onrender.com/api';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: const Duration(seconds: 90),
        connectTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    //* Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  //* Get all tasks with filters
  Future<List<Task>> getTasks({
    String? status,
    String? category,
    String? priority,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (search != null) queryParams['search'] = search;
      queryParams['limit'] = limit;
      queryParams['offset'] = offset;

      final response = await _dio.get(
        '/tasks',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> tasksJson = response.data['data'];
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      }
      throw Exception('Failed to load tasks');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Get task by ID
  Future<TaskWithHistory> getTaskById(String id) async {
    try {
      final response = await _dio.get('/tasks/$id');

      if (response.data['success'] == true) {
        print(response.data['data']);
        print(response.data['data']['history'][0]);
        return TaskWithHistory.fromMap(response.data['data']);
      }
      throw Exception('Failed to load task');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Create new task
  Future<Task> createTask({
    required String title,
    String? description,
    String? category,
    String? priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final data = {
        'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (priority != null) 'priority': priority,
        if (assignedTo != null) 'assignedTo': assignedTo,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      };

      final response = await _dio.post('/tasks', data: data);

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data']);
      }
      throw Exception('Failed to create task');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Update task
  Future<Task> updateTask(
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
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (priority != null) data['priority'] = priority;
      if (status != null) data['status'] = status;
      if (assignedTo != null) data['assignedTo'] = assignedTo;
      if (dueDate != null) data['dueDate'] = dueDate.toIso8601String();

      final response = await _dio.patch('/tasks/$id', data: data);

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data']);
      }
      throw Exception('Failed to update task');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Delete task
  Future<void> deleteTask(String id) async {
    try {
      final response = await _dio.delete('/tasks/$id');

      if (response.data['success'] != true) {
        throw Exception('Failed to delete task');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Preview classification
  Future<ClassificationPreview> previewClassification({
    required String title,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/tasks/classify',
        data: {
          'title': title,
          if (description != null) 'description': description,
        },
      );

      if (response.data['success'] == true) {
        return ClassificationPreview.fromJson(response.data['data']);
      }
      throw Exception('Failed to preview classification');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Get task statistics
  Future<TaskStats> getTaskStats() async {
    try {
      final response = await _dio.get('/tasks/stats');

      if (response.data['success'] == true) {
        return TaskStats.fromJson(response.data['data']);
      }
      throw Exception('Failed to load statistics');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //* Handle errors
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your connection.';
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 400) {
        return data['error'] ?? 'Invalid request';
      } else if (statusCode == 404) {
        return 'Resource not found';
      } else if (statusCode == 500) {
        return 'Server error. Please try again later.';
      }

      return data['error'] ?? 'An error occurred';
    }

    return 'Network error. Please try again.';
  }
}
