import 'package:fermentrack/models/project.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ProjectCard Widget
///
/// A reusable widget that displays a project in a Material Card format.
/// This widget demonstrates:
/// - Custom widget creation
/// - Material Design principles
/// - Date calculations and formatting
/// - Icon mapping for enums
/// - Gesture handling with callbacks
///
/// Learning Points:
/// - StatelessWidget for display-only components
/// - Card widget with elevation for depth
/// - ListTile for consistent layouts
/// - Hero widget for smooth transitions
/// - Type-safe callbacks with VoidCallback
///
/// Usage Example:
/// ```dart
/// ProjectCard(
///   project: myProject,
///   onTap: () => navigateToDetails(myProject),
/// )
/// ```
class ProjectCard extends StatelessWidget {
  /// Constructor
  ///
  /// Parameters:
  /// - [project]: The project data to display (required)
  /// - [onTap]: Callback when card is tapped (optional)
  /// - [key]: Widget key for testing and optimization
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  /// The project to display
  final Project project;

  /// Callback when the card is tapped
  /// Typically used for navigation to project details
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon and status badge
              Row(
                children: [
                  // Project type icon
                  Hero(
                    tag: 'project-icon-${project.id}',
                    child: Icon(
                      _getProjectIcon(project.type),
                      color: _getProjectColor(project.type),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Project name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatProjectType(project.type),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              const Divider(),
              const SizedBox(height: 12),
              // Project details row
              Row(
                children: [
                  // Start date
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Started',
                      value: _formatDate(project.startDate),
                    ),
                  ),
                  // Days active
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.access_time,
                      label: 'Days Active',
                      value: _calculateDaysActive(),
                    ),
                  ),
                ],
              ),
              // Description if available
              if (project.description != null && project.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  project.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build status badge widget
  Widget _buildStatusBadge(BuildContext context) {
    final statusConfig = _getStatusConfig(project.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig['color'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusConfig['label'] as String,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build a detail item (icon + label + value)
  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get icon for project type
  ///
  /// Maps each ProjectType enum to an appropriate icon
  /// This demonstrates enum-based UI customization
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

  /// Get color for project type
  ///
  /// Assigns distinct colors to different project types
  /// Helps users quickly identify project categories
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

  /// Format project type for display
  ///
  /// Converts enum names to human-readable strings
  /// Handles special cases like "waterKefir" -> "Water Kefir"
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

  /// Get status configuration (color and label)
  ///
  /// Returns a map with display properties for each status
  Map<String, dynamic> _getStatusConfig(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return {
          'label': 'Active',
          'color': Colors.green,
        };
      case ProjectStatus.paused:
        return {
          'label': 'Paused',
          'color': Colors.orange,
        };
      case ProjectStatus.completed:
        return {
          'label': 'Completed',
          'color': Colors.blue,
        };
      case ProjectStatus.archived:
        return {
          'label': 'Archived',
          'color': Colors.grey,
        };
    }
  }

  /// Format date for display
  ///
  /// Uses intl package for localized date formatting
  /// Format: Jan 1, 2025
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Calculate days active
  ///
  /// Calculates the number of days between start date and:
  /// - End date if project is completed
  /// - Current date if project is active
  ///
  /// Returns formatted string like "42 days" or "0 days" for same-day projects
  String _calculateDaysActive() {
    final endDate = project.endDate ?? DateTime.now();
    final days = endDate.difference(project.startDate).inDays;

    if (days == 0) {
      return '< 1 day';
    } else if (days == 1) {
      return '1 day';
    } else {
      return '$days days';
    }
  }
}
