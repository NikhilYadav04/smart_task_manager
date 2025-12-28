import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_task_manager/models/task.dart';
import 'package:smart_task_manager/providers/task_provider.dart';
import '../../utils/task_utils.dart';

class CreateTaskBottomSheet extends StatefulWidget {
  const CreateTaskBottomSheet({super.key});

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPriority;
  DateTime? _selectedDueDate;
  ClassificationPreview? _preview;
  bool _isLoadingPreview = false;
  bool _showPreview = false;

  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    if (_titleController.text.isEmpty) return;

    setState(() {
      _isLoadingPreview = true;
    });

    final provider = context.read<TaskProvider>();
    final preview = await provider.previewClassification(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    setState(() {
      _preview = preview;
      _isLoadingPreview = false;
      _showPreview = true;

      //* Auto-fill if not filled ( preview api call )
      if (_selectedCategory == null && preview != null) {
        _selectedCategory = preview.category;
      }
      if (_selectedPriority == null && preview != null) {
        _selectedPriority = preview.priority;
      }
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating a New Task'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    final provider = context.read<TaskProvider>();

    final task = await provider.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      assignedTo: _assignedToController.text.trim(),
      dueDate: _selectedDueDate,
    );

    setState(() {
      _isCreating = false;
    });

    if (mounted) {
      if (task != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to create task'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Create New Task',
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
                SizedBox(height: sh * 0.03),

                //* Title Field
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                    ),
                    hintText: 'Enter task title',
                    hintStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.title,
                      size: isTablet ? sw * 0.022 : sw * 0.05,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    setState(() {
                      _showPreview = false;
                    });
                  },
                ),
                SizedBox(height: sh * 0.02),

                //* Description Field
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                    ),
                    hintText: 'Enter task description',
                    hintStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.description,
                      size: isTablet ? sw * 0.022 : sw * 0.05,
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    setState(() {
                      _showPreview = false;
                    });
                  },
                ),
                SizedBox(height: sh * 0.02),

                //* Preview Button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingPreview ? null : _loadPreview,
                    icon: _isLoadingPreview
                        ? SizedBox(
                            width: isTablet ? sw * 0.02 : sw * 0.04,
                            height: isTablet ? sw * 0.02 : sw * 0.04,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.auto_awesome,
                            size: isTablet ? sw * 0.022 : sw * 0.045,
                          ),
                    label: Text(
                      'Preview Auto-Classification',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                        vertical: isTablet ? sh * 0.012 : sh * 0.015,
                      ),
                    ),
                  ),
                ),

                //* Preview Results
                if (_showPreview && _preview != null) ...[
                  SizedBox(height: sh * 0.02),
                  _PreviewCard(
                    preview: _preview!,
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                  ),
                ],

                SizedBox(height: sh * 0.02),

                //* Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.category,
                      size: isTablet ? sw * 0.022 : sw * 0.05,
                    ),
                  ),
                  hint: Text(
                    'Select category (optional)',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'scheduling',
                      child: Text(
                        'Scheduling',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'finance',
                      child: Text(
                        'Finance',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'technical',
                      child: Text(
                        'Technical',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'safety',
                      child: Text(
                        'Safety',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'general',
                      child: Text(
                        'General',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                SizedBox(height: sh * 0.02),

                //* Priority Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.flag,
                      size: isTablet ? sw * 0.022 : sw * 0.05,
                    ),
                  ),
                  hint: Text(
                    'Select priority (optional)',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'high',
                      child: Text(
                        'High',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text(
                        'Medium',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'low',
                      child: Text(
                        'Low',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                ),
                SizedBox(height: sh * 0.02),

                //* Due Date Picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                      ),
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        size: isTablet ? sw * 0.022 : sw * 0.05,
                      ),
                    ),
                    child: Text(
                      _selectedDueDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                          : 'Select due date (optional)',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        color: _selectedDueDate != null
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.02),

                //* Assigned To Field
                TextFormField(
                  controller: _assignedToController,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Assigned To',
                    labelStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                    ),
                    hintText: 'Enter assignee name',
                    hintStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.person,
                      size: isTablet ? sw * 0.022 : sw * 0.05,
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.03),

                //* Submit Button
                SizedBox(
                  width: double.infinity,
                  child: _isCreating
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.purpleAccent,
                          ),
                        )
                      : FilledButton(
                          onPressed: _handleSubmit,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? sh * 0.018 : sh * 0.02,
                            ),
                          ),
                          child: Text(
                            'Create Task',
                            style: TextStyle(
                              fontSize: isTablet ? sw * 0.022 : sw * 0.042,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final ClassificationPreview preview;
  final double sw;
  final double sh;
  final bool isTablet;

  const _PreviewCard({
    required this.preview,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: isTablet ? sw * 0.022 : sw * 0.045,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: sw * 0.02),
                Text(
                  'Auto-Classification Preview',
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.015),

            //* Category and Priority
            Wrap(
              spacing: sw * 0.02,
              runSpacing: sh * 0.01,
              children: [
                Chip(
                  avatar: Icon(
                    TaskUtils.getCategoryIcon(preview.category),
                    size: isTablet ? sw * 0.018 : sw * 0.035,
                  ),
                  label: Text(
                    'Category: ${TaskUtils.capitalize(preview.category)}',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
                Chip(
                  label: Text(
                    'Priority: ${TaskUtils.capitalize(preview.priority)}',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
              ],
            ),

            //* Suggested Actions
            if (preview.suggestedActions.isNotEmpty) ...[
              SizedBox(height: sh * 0.015),
              Text(
                'Suggested Actions:',
                style: TextStyle(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Wrap(
                spacing: sw * 0.015,
                runSpacing: sh * 0.008,
                children: preview.suggestedActions.take(4).map((action) {
                  return Chip(
                    label: Text(
                      action,
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
