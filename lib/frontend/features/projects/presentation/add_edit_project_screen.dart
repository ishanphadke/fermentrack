import 'package:fermentrack/middleware/auth/providers/auth_providers.dart';
import 'package:fermentrack/middleware/projects/providers/project_providers.dart';
import 'package:fermentrack/middleware/services/firestore_service.dart';
import 'package:fermentrack/models/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// **Add/Edit Project Screen**
///
/// A unified screen for both creating new projects and editing existing ones.
/// This demonstrates single responsibility with conditional behavior based on context.
///
/// **Features:**
/// - Create new fermentation projects
/// - Edit existing project details
/// - Form validation
/// - Date picker for start date
/// - Dropdown for project type selection
/// - Optional description field
/// - Loading states during save
/// - Error handling
///
/// **Learning Points:**
/// - **StatefulWidget**: For managing form state
/// - **Form Validation**: Using Form widget and validators
/// - **TextEditingController**: Managing text input
/// - **Date Picker**: showDatePicker dialog
/// - **Dropdown**: DropdownButtonFormField
/// - **Async Operations**: Handling save operations
/// - **Navigation**: Go back after save
/// - **Riverpod Integration**: Reading providers
///
/// **Usage:**
/// - Add mode: `AddEditProjectScreen()`
/// - Edit mode: `AddEditProjectScreen(projectId: 'abc123')`
class AddEditProjectScreen extends ConsumerStatefulWidget {
  const AddEditProjectScreen({
    super.key,
    this.projectId,
  });

  /// Project ID for edit mode (null for add mode)
  final String? projectId;

  @override
  ConsumerState<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends ConsumerState<AddEditProjectScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  // Form state
  ProjectType? _selectedType;
  DateTime? _startDate;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _startDate = DateTime.now(); // Default to today
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Initialize form with existing project data (edit mode)
  Future<void> _initializeEditMode() async {
    if (widget.projectId == null || _isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch the project data
      final project = await ref.read(projectByIdProvider(widget.projectId!).future);

      if (project != null && mounted) {
        setState(() {
          _nameController.text = project.name;
          _descriptionController.text = project.description ?? '';
          _selectedType = project.type;
          _startDate = project.startDate;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize edit mode if needed
    if (widget.projectId != null && !_isInitialized && !_isLoading) {
      // Use addPostFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeEditMode();
      });
    }

    final bool isEditMode = widget.projectId != null;
    final String title = isEditMode ? 'Edit Project' : 'New Project';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Project Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name *',
                        hintText: 'e.g., My First Sourdough',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a project name';
                        }
                        if (value.trim().length < 3) {
                          return 'Project name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Project Type Dropdown
                    DropdownButtonFormField<ProjectType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Project Type *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ProjectType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getProjectIcon(type),
                                size: 20,
                                color: _getProjectColor(type),
                              ),
                              const SizedBox(width: 12),
                              Text(_formatProjectType(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a project type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date Picker
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date *',
                        hintText: 'Select start date',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _startDate != null
                            ? DateFormat.yMMMd().format(_startDate!)
                            : '',
                      ),
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (_startDate == null) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field (Optional)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add notes about your project...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),

                    // Info card
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You can update project details anytime after creation.',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProject,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditMode ? 'Update Project' : 'Create Project'),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Start Date',
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  /// Save project (create or update)
  Future<void> _saveProject() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevent multiple submissions
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Firestore service
      final firestoreService = ref.read(firestoreServiceProvider);

      // Create project object
      final project = Project(
        id: widget.projectId, // null for new project
        name: _nameController.text.trim(),
        type: _selectedType!,
        startDate: _startDate!,
        userId: user.uid,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      // Save to Firestore
      if (widget.projectId == null) {
        // Add new project
        await firestoreService.addProject(project);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing project
        await firestoreService.updateProject(project);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Navigate back to dashboard
      if (mounted) {
        context.pop();
      }
    } on FirestoreServiceException catch (e) {
      // Handle Firestore-specific errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Get icon for project type (same as ProjectCard)
  IconData _getProjectIcon(ProjectType type) {
    switch (type) {
      case ProjectType.sourdough:
        return Icons.bakery_dining;
      case ProjectType.kombucha:
        return Icons.local_drink;
      case ProjectType.kimchi:
        return Icons.lunch_dining;
      case ProjectType.waterKefir:
        return Icons.water_drop;
      case ProjectType.yogurt:
        return Icons.icecream;
      case ProjectType.sauerkraut:
        return Icons.set_meal;
      case ProjectType.other:
        return Icons.science;
    }
  }

  /// Get color for project type (same as ProjectCard)
  Color _getProjectColor(ProjectType type) {
    switch (type) {
      case ProjectType.sourdough:
        return Colors.brown;
      case ProjectType.kombucha:
        return Colors.orange;
      case ProjectType.kimchi:
        return Colors.red;
      case ProjectType.waterKefir:
        return Colors.blue;
      case ProjectType.yogurt:
        return Colors.purple;
      case ProjectType.sauerkraut:
        return Colors.green;
      case ProjectType.other:
        return Colors.grey;
    }
  }

  /// Format project type for display (same as ProjectCard)
  String _formatProjectType(ProjectType type) {
    switch (type) {
      case ProjectType.sourdough:
        return 'Sourdough';
      case ProjectType.kombucha:
        return 'Kombucha';
      case ProjectType.kimchi:
        return 'Kimchi';
      case ProjectType.waterKefir:
        return 'Water Kefir';
      case ProjectType.yogurt:
        return 'Yogurt';
      case ProjectType.sauerkraut:
        return 'Sauerkraut';
      case ProjectType.other:
        return 'Other';
    }
  }
}
