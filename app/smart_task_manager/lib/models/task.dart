class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime? dueDate;
  final Map<String, dynamic>? extractedEntities;
  final List<String>? suggestedActions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.dueDate,
    this.extractedEntities,
    this.suggestedActions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'low',
      status: json['status'] ?? 'pending',
      assignedTo: json['assignedTo'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      extractedEntities: json['extractedEntities'] as Map<String, dynamic>?,
      suggestedActions: json['suggestedActions'] != null
          ? List<String>.from(json['suggestedActions'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'dueDate': dueDate?.toIso8601String(),
      'extractedEntities': extractedEntities,
      'suggestedActions': suggestedActions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
    Map<String, dynamic>? extractedEntities,
    List<String>? suggestedActions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      extractedEntities: extractedEntities ?? this.extractedEntities,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TaskStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    final byStatus = json['byStatus'] as Map<String, dynamic>? ?? {};
    return TaskStats(
      total: json['total'] ?? 0,
      pending: byStatus['pending'] ?? 0,
      inProgress: byStatus['in_progress'] ?? 0,
      completed: byStatus['completed'] ?? 0,
    );
  }
}

class ClassificationPreview {
  final String category;
  final String priority;
  final List<String> suggestedActions;
  final Map<String, dynamic> extractedEntities;

  ClassificationPreview({
    required this.category,
    required this.priority,
    required this.suggestedActions,
    required this.extractedEntities,
  });

  factory ClassificationPreview.fromJson(Map<String, dynamic> json) {
    return ClassificationPreview(
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'low',
      suggestedActions: List<String>.from(json['suggestedActions'] ?? []),
      extractedEntities: json['extractedEntities'] ?? {},
    );
  }
}
