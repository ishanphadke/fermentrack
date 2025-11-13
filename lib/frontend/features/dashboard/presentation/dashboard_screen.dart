import 'package:fermentrack/frontend/shared/widgets/project_card.dart';
import 'package:fermentrack/middleware/projects/providers/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../middleware/auth/providers/auth_providers.dart';

/// **Dashboard Screen**
///
/// This is the main protected screen that users see after authentication.
/// It displays a list of the user's fermentation projects with real-time updates.
///
/// **Features:**
/// - Real-time project list from Firestore
/// - Pull-to-refresh functionality
/// - Project cards with visual indicators
/// - Empty state for new users
/// - Loading and error states
/// - FAB to add new projects
/// - Sign out functionality
///
/// **Learning Points for New Developers:**
/// - **ConsumerWidget**: Riverpod widget that can read providers
/// - **StreamProvider**: Reactive data from Firestore
/// - **AsyncValue**: Handling loading, data, and error states
/// - **Pull-to-Refresh**: RefreshIndicator widget
/// - **List Rendering**: ListView.builder for efficient scrolling
/// - **State Management**: Riverpod for reactive UI updates
/// - **Navigation**: GoRouter for screen navigation
///
/// **Architecture:**
/// - This screen is a presentation layer component
/// - Business logic is in providers (middleware/projects/providers)
/// - Data access is in FirestoreService (middleware/services)
/// - Follows clean architecture principles
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user display name from provider
    final displayName = ref.watch(userDisplayNameProvider);
    final authService = ref.read(authServiceProvider);

    // Watch the projects stream
    final projectsAsync = ref.watch(userProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              // Show confirmation dialog
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              // If user confirmed, sign out
              if (shouldSignOut == true && context.mounted) {
                try {
                  await authService.signOut();
                  // GoRouter will automatically redirect to login via redirect logic
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      // Use RefreshIndicator for pull-to-refresh functionality
      body: RefreshIndicator(
        // Refresh callback
        onRefresh: () async {
          // Invalidate the provider to trigger a refresh
          // This will re-fetch data from Firestore
          ref.invalidate(userProjectsProvider);

          // Wait a bit for the provider to refresh
          // In a real app, you might want to wait for the actual future
          await Future.delayed(const Duration(milliseconds: 500));
        },
        // Build the main body based on async state
        child: projectsAsync.when(
          // Data state: projects loaded successfully
          data: (projects) {
            // Check if there are no projects (empty state)
            if (projects.isEmpty) {
              return _buildEmptyState(context, displayName);
            }

            // Build project list
            return CustomScrollView(
              slivers: [
                // Welcome header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $displayName!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have ${projects.length} ${projects.length == 1 ? 'project' : 'projects'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Project list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        onTap: () {
                          // Navigate to project details (to be implemented)
                          // context.go('/project/${project.id}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Project details for "${project.name}" - Coming soon!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                    childCount: projects.length,
                  ),
                ),
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80), // Space for FAB
                ),
              ],
            );
          },
          // Loading state: show spinner
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading your projects...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          // Error state: show error message with retry
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Projects',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry by invalidating the provider
                      ref.invalidate(userProjectsProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Floating Action Button to add new project
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add project screen
          context.push('/add-project');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
        tooltip: 'Add New Project',
      ),
    );
  }

  /// Build empty state UI
  ///
  /// Shown when user has no projects yet
  /// Encourages user to create their first project
  Widget _buildEmptyState(BuildContext context, String? displayName) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome message
            Icon(
              Icons.science,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome, $displayName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You haven\'t started any fermentation projects yet.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Info card about getting started
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Getting Started',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Track your fermentation projects like:\n'
                      '• Sourdough starters and bakes\n'
                      '• Kombucha brewing\n'
                      '• Kimchi and sauerkraut\n'
                      '• Yogurt and kefir\n'
                      '• And many more!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Call to action button
            ElevatedButton.icon(
              onPressed: () {
                context.push('/add-project');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Project'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
