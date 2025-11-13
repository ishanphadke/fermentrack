import 'package:fermentrack/middleware/auth/providers/auth_providers.dart';
import 'package:fermentrack/middleware/services/firestore_service.dart';
import 'package:fermentrack/models/project.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// This part directive tells Riverpod's code generator where to place generated code
// The generated file will be: project_providers.g.dart
part 'project_providers.g.dart';

/// **FirestoreService Provider**
///
/// This provider exposes our FirestoreService as a Riverpod provider, making it
/// available throughout the widget tree for project data operations.
///
/// **Learning Points for New Developers:**
/// - **Provider Pattern**: Creates a singleton instance of FirestoreService
/// - **Dependency Injection**: Widgets can access FirestoreService via `ref.read(firestoreServiceProvider)`
/// - **Testability**: Easy to override this provider in tests with mock implementations
/// - **Code Generation**: @riverpod annotation generates boilerplate code
///
/// **Why we use this pattern:**
/// - Centralizes service creation
/// - Ensures consistent FirestoreService instance across the app
/// - Makes testing easier (can inject mock services)
/// - Follows dependency inversion principle
/// - Separates business logic from UI
///
/// **Usage Example:**
/// ```dart
/// class ProjectScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final firestoreService = ref.read(firestoreServiceProvider);
///     // Use firestoreService for CRUD operations
///   }
/// }
/// ```
@riverpod
FirestoreService firestoreService(Ref ref) {
  // Create and return FirestoreService instance
  // In production: uses FirebaseFirestore.instance
  // In tests: can be overridden with mock implementation
  return FirestoreService();
}

/// **User Projects Stream Provider**
///
/// This StreamProvider listens to the user's projects from Firestore and automatically
/// updates the UI when projects are added, modified, or deleted.
///
/// **Learning Points for New Developers:**
/// - **StreamProvider**: Special Riverpod provider for reactive data streams
/// - **Reactive Programming**: UI automatically updates when data changes
/// - **Firestore Integration**: Real-time updates from Cloud Firestore
/// - **Provider Dependencies**: Depends on both firestoreServiceProvider and authStateProvider
/// - **User-specific Data**: Automatically filters projects for the current user
///
/// **How it works:**
/// 1. Gets the current user from authStateProvider
/// 2. If no user is authenticated, returns empty stream
/// 3. If user is authenticated, gets their projects stream from FirestoreService
/// 4. Riverpod automatically manages subscription/unsubscription
/// 5. UI widgets listening to this provider auto-rebuild on data changes
///
/// **State Values:**
/// - `AsyncData<List<Project>>`: Projects loaded successfully
/// - `AsyncLoading`: Projects are loading
/// - `AsyncError`: Error occurred while loading projects
///
/// **Real-time Updates:**
/// This provider provides real-time updates, meaning:
/// - When a new project is added, it immediately appears in the UI
/// - When a project is updated, changes reflect instantly
/// - When a project is deleted, it's removed from the UI immediately
/// - No manual refresh needed - Firestore pushes updates automatically
///
/// **Usage Example:**
/// ```dart
/// class ProjectListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final projectsAsync = ref.watch(userProjectsProvider);
///
///     return projectsAsync.when(
///       data: (projects) => ListView.builder(
///         itemCount: projects.length,
///         itemBuilder: (context, index) => ProjectCard(
///           project: projects[index],
///         ),
///       ),
///       loading: () => CircularProgressIndicator(),
///       error: (error, stack) => ErrorWidget(error),
///     );
///   }
/// }
/// ```
@riverpod
Stream<List<Project>> userProjects(Ref ref) {
  // Get the FirestoreService instance
  final firestoreService = ref.watch(firestoreServiceProvider);

  // Get the current authentication state
  final authState = ref.watch(authStateProvider);

  // Handle auth state
  return authState.when(
    // User is authenticated - get their projects
    data: (user) {
      if (user == null) {
        // No user signed in - return empty stream
        return Stream.value([]);
      }

      // User is signed in - return their projects stream
      // This stream will emit updates whenever projects change in Firestore
      return firestoreService.getProjectsStream(user.uid);
    },
    // Auth state is loading - return empty stream
    loading: () => Stream.value([]),
    // Auth error - return empty stream
    // Note: Auth errors should be handled by auth-specific UI
    error: (_, __) => Stream.value([]),
  );
}

/// **Active Projects Provider**
///
/// This computed provider filters the user's projects to show only active ones.
/// It demonstrates how to create derived state from other providers.
///
/// **Learning Points:**
/// - **Computed State**: Derives data from other providers
/// - **Filtering**: Shows subset of data based on business logic
/// - **Composability**: Builds on top of userProjectsProvider
/// - **Automatic Updates**: Recomputes when userProjectsProvider changes
///
/// **Use Cases:**
/// - Dashboard showing only active projects
/// - Quick access to current work
/// - Statistics about ongoing fermentations
///
/// **Usage Example:**
/// ```dart
/// class ActiveProjectsWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final activeProjectsAsync = ref.watch(activeProjectsProvider);
///
///     return activeProjectsAsync.when(
///       data: (projects) => Text('${projects.length} active projects'),
///       loading: () => CircularProgressIndicator(),
///       error: (error, stack) => Text('Error loading projects'),
///     );
///   }
/// }
/// ```
@riverpod
Stream<List<Project>> activeProjects(Ref ref) {
  // Watch the user projects stream
  final projectsStream = ref.watch(userProjectsProvider);

  // Transform the stream to filter only active projects
  return projectsStream.when(
    data: (projects) {
      // Filter for active projects only
      final activeProjects = projects
          .where((project) => project.status == ProjectStatus.active)
          .toList();

      // Return as a stream
      return Stream.value(activeProjects);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}

/// **Project Count Provider**
///
/// This computed provider returns the total count of user's projects.
/// Useful for displaying statistics and dashboard summaries.
///
/// **Learning Points:**
/// - **Simple Derived State**: Single value computed from collection
/// - **Lightweight**: Just returns count, not full project data
/// - **Reactive**: Updates automatically when projects change
///
/// **Usage Example:**
/// ```dart
/// class ProjectStatsWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final countAsync = ref.watch(projectCountProvider);
///
///     return countAsync.when(
///       data: (count) => Text('Total Projects: $count'),
///       loading: () => Text('Loading...'),
///       error: (error, stack) => Text('Error'),
///     );
///   }
/// }
/// ```
@riverpod
Stream<int> projectCount(Ref ref) {
  // Watch the user projects stream
  final projectsStream = ref.watch(userProjectsProvider);

  // Transform to return count
  return projectsStream.when(
    data: (projects) => Stream.value(projects.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
}

/// **Project by ID Provider**
///
/// This provider family allows fetching a single project by its ID.
/// Provider families enable parameterized providers - like functions with parameters.
///
/// **Learning Points:**
/// - **Provider Families**: Create providers that take parameters
/// - **Single Item Access**: Get one specific project
/// - **Efficient**: Only fetches the requested project
/// - **Type-safe**: Parameter type checking at compile time
///
/// **How it works:**
/// 1. Takes a projectId parameter
/// 2. Gets the user from auth state
/// 3. Fetches that specific project from Firestore
/// 4. Returns Future<Project?> (null if not found)
///
/// **Usage Example:**
/// ```dart
/// class ProjectDetailScreen extends ConsumerWidget {
///   final String projectId;
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final projectAsync = ref.watch(projectByIdProvider(projectId));
///
///     return projectAsync.when(
///       data: (project) {
///         if (project == null) return Text('Project not found');
///         return ProjectDetails(project: project);
///       },
///       loading: () => CircularProgressIndicator(),
///       error: (error, stack) => ErrorWidget(error),
///     );
///   }
/// }
/// ```
@riverpod
Future<Project?> projectById(Ref ref, String projectId) async {
  // Get services and auth state
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authState = ref.watch(authStateProvider);

  // Get current user
  final user = authState.value;
  if (user == null) {
    return null;
  }

  // Fetch the specific project
  try {
    return await firestoreService.getProject(user.uid, projectId);
  } catch (e) {
    // Log error and return null
    // In production, you might want to throw a custom exception
    return null;
  }
}
