import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fermentrack/models/project.dart';
import 'package:flutter/foundation.dart';

/// FirestoreService - Cloud Firestore Database Service
///
/// This service class handles all Firestore operations for projects in the Fermentrack app.
/// It's designed as a training exercise for intermediate Flutter developers to learn:
///
/// Key Learning Concepts:
/// - Cloud Firestore integration
/// - Real-time data streaming with snapshots()
/// - CRUD operations (Create, Read, Update, Delete)
/// - User-specific data isolation
/// - Async/await patterns in Dart
/// - Error handling with try-catch blocks
/// - Service layer architecture patterns
///
/// Architecture Notes:
/// - This service acts as the data layer for project management
/// - It abstracts Firestore complexity from the UI
/// - Returns custom error messages for better UX
/// - Uses dependency injection patterns for testability
/// - Implements user-isolated data structure: /users/{userId}/projects
///
/// Data Structure:
/// /users/{userId}/projects/{projectId}
/// This hierarchical structure ensures:
/// - Users can only access their own projects
/// - Data is automatically isolated per user
/// - Security rules can be simplified
/// - Easier to implement data export/backup per user
class FirestoreService {
  /// Constructor with optional dependency injection
  ///
  /// This constructor pattern enables:
  /// - Production use: FirestoreService() uses FirebaseFirestore.instance
  /// - Testing use: FirestoreService(firestore: mockFirestore) uses mocked firestore
  ///
  /// This is a key pattern for testable code in Flutter:
  /// - Dependency injection makes code more modular
  /// - Makes unit testing possible without real Firestore calls
  /// - Follows SOLID principles (Dependency Inversion)
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Collection path constants for better maintainability
  static const String _usersCollection = 'users';
  static const String _projectsCollection = 'projects';

  /// Get the user-specific projects collection reference
  ///
  /// This helper method encapsulates the collection path logic
  /// Returns: CollectionReference to /users/{userId}/projects
  ///
  /// Benefits:
  /// - Consistent path structure across all methods
  /// - Easy to modify collection structure in one place
  /// - Type-safe collection reference
  CollectionReference<Map<String, dynamic>> _getProjectsCollection(
    String userId,
  ) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_projectsCollection);
  }

  /// Get real-time stream of projects for a specific user
  ///
  /// This method demonstrates:
  /// - Real-time data streaming with Firestore
  /// - Stream transformation and mapping
  /// - Error handling for stream operations
  /// - User-specific data filtering
  ///
  /// Flow:
  /// 1. Get user's projects collection
  /// 2. Listen to snapshots() for real-time updates
  /// 3. Transform QuerySnapshot to List<Project>
  /// 4. Handle deserialization errors gracefully
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose projects to fetch
  ///
  /// Returns:
  /// - Stream<List<Project>> that emits whenever data changes
  ///
  /// Error Handling:
  /// - Logs deserialization errors but continues with valid projects
  /// - Returns empty list if no projects exist
  /// - Stream errors are propagated to the caller
  ///
  /// Usage Example:
  /// ```dart
  /// final projectsStream = firestoreService.getProjectsStream(userId);
  /// projectsStream.listen((projects) {
  ///   print('Got ${projects.length} projects');
  /// });
  /// ```
  Stream<List<Project>> getProjectsStream(String userId) {
    try {
      // Input validation
      if (userId.isEmpty) {
        debugPrint('FirestoreService: Invalid userId - cannot be empty');
        throw const FirestoreServiceException(
          'User ID cannot be empty',
        );
      }

      debugPrint('FirestoreService: Getting projects stream for user: $userId');

      // Get the user-specific projects collection
      final projectsRef = _getProjectsCollection(userId);

      // Listen to snapshots and transform to List<Project>
      return projectsRef.snapshots().map((querySnapshot) {
        debugPrint(
          'FirestoreService: Received ${querySnapshot.docs.length} projects from stream',
        );

        final projects = <Project>[];

        for (final doc in querySnapshot.docs) {
          try {
            // Get document data and add the document ID
            final data = doc.data();
            data['id'] = doc.id;

            // Deserialize to Project model
            final project = Project.fromJson(data);
            projects.add(project);
          } catch (e) {
            // Log error but continue processing other documents
            debugPrint(
              'FirestoreService: Error deserializing project ${doc.id}: $e',
            );
          }
        }

        debugPrint(
          'FirestoreService: Successfully deserialized ${projects.length} projects',
        );
        return projects;
      });
    } catch (e) {
      debugPrint('FirestoreService: Error setting up projects stream: $e');
      rethrow;
    }
  }

  /// Add a new project to Firestore
  ///
  /// This method demonstrates:
  /// - Document creation with auto-generated IDs
  /// - JSON serialization before storing
  /// - Server timestamp handling
  /// - Error handling for Firestore operations
  ///
  /// Flow:
  /// 1. Validate input
  /// 2. Serialize project to JSON
  /// 3. Add document to Firestore (auto-generates ID)
  /// 4. Return new project with assigned ID
  ///
  /// Parameters:
  /// - [project]: The project to add (id should be null for new projects)
  ///
  /// Returns:
  /// - Future<Project> with the assigned Firestore document ID
  ///
  /// Throws:
  /// - [FirestoreServiceException] for validation or Firestore errors
  ///
  /// Notes:
  /// - The input project's id will be ignored if provided
  /// - A new ID is always generated by Firestore
  /// - You could extend this to add createdAt/updatedAt timestamps
  Future<Project> addProject(Project project) async {
    try {
      // Input validation
      if (project.userId.isEmpty) {
        debugPrint('FirestoreService: Invalid project - userId cannot be empty');
        throw const FirestoreServiceException(
          'Project userId cannot be empty',
        );
      }

      if (project.name.trim().isEmpty) {
        debugPrint('FirestoreService: Invalid project - name cannot be empty');
        throw const FirestoreServiceException(
          'Project name cannot be empty',
        );
      }

      debugPrint(
        'FirestoreService: Adding project "${project.name}" for user: ${project.userId}',
      );

      // Get the user-specific projects collection
      final projectsRef = _getProjectsCollection(project.userId);

      // Serialize project to JSON (excluding the id field)
      final projectData = project.copyWith(id: null).toJson();

      // Add document to Firestore (auto-generates ID)
      final docRef = await projectsRef.add(projectData);

      debugPrint(
        'FirestoreService: Project added successfully with ID: ${docRef.id}',
      );

      // Return project with the assigned ID
      return project.copyWith(id: docRef.id);
    } on FirestoreServiceException {
      // Re-throw our custom exceptions
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint(
        'FirestoreService: Firebase Exception while adding project - '
        'Code: ${e.code}, Message: ${e.message}',
      );
      throw FirestoreServiceException(
        _handleFirebaseError(e),
      );
    } catch (e) {
      debugPrint('FirestoreService: Unexpected error while adding project: $e');
      throw const FirestoreServiceException(
        'Failed to add project. Please try again.',
      );
    }
  }

  /// Update an existing project in Firestore
  ///
  /// This method demonstrates:
  /// - Document updates by ID
  /// - Partial updates (only changed fields)
  /// - Validation before update
  /// - Error handling for non-existent documents
  ///
  /// Flow:
  /// 1. Validate input (project must have an id)
  /// 2. Serialize project to JSON
  /// 3. Update document in Firestore
  /// 4. Return updated project
  ///
  /// Parameters:
  /// - [project]: The project to update (must have an id)
  ///
  /// Returns:
  /// - Future<void> on successful update
  ///
  /// Throws:
  /// - [FirestoreServiceException] for validation or Firestore errors
  ///
  /// Notes:
  /// - This performs a full document update (set with merge: true would be partial)
  /// - userId cannot be changed once project is created
  /// - Consider adding updatedAt timestamp
  Future<void> updateProject(Project project) async {
    try {
      // Input validation
      if (project.id == null || project.id!.isEmpty) {
        debugPrint(
          'FirestoreService: Invalid project - id is required for update',
        );
        throw const FirestoreServiceException(
          'Project ID is required for update',
        );
      }

      if (project.userId.isEmpty) {
        debugPrint('FirestoreService: Invalid project - userId cannot be empty');
        throw const FirestoreServiceException(
          'Project userId cannot be empty',
        );
      }

      if (project.name.trim().isEmpty) {
        debugPrint('FirestoreService: Invalid project - name cannot be empty');
        throw const FirestoreServiceException(
          'Project name cannot be empty',
        );
      }

      debugPrint(
        'FirestoreService: Updating project ${project.id} for user: ${project.userId}',
      );

      // Get the specific project document reference
      final projectDoc = _getProjectsCollection(project.userId).doc(project.id);

      // Serialize project to JSON (excluding the id field)
      final projectData = project.copyWith(id: null).toJson();

      // Update the document
      await projectDoc.update(projectData);

      debugPrint(
        'FirestoreService: Project ${project.id} updated successfully',
      );
    } on FirestoreServiceException {
      // Re-throw our custom exceptions
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint(
        'FirestoreService: Firebase Exception while updating project - '
        'Code: ${e.code}, Message: ${e.message}',
      );

      // Special handling for not-found case
      if (e.code == 'not-found') {
        throw const FirestoreServiceException(
          'Project not found. It may have been deleted.',
        );
      }

      throw FirestoreServiceException(
        _handleFirebaseError(e),
      );
    } catch (e) {
      debugPrint(
        'FirestoreService: Unexpected error while updating project: $e',
      );
      throw const FirestoreServiceException(
        'Failed to update project. Please try again.',
      );
    }
  }

  /// Delete a project from Firestore
  ///
  /// This method demonstrates:
  /// - Document deletion by ID
  /// - Validation before deletion
  /// - Error handling for non-existent documents
  /// - Logging for audit trail
  ///
  /// Flow:
  /// 1. Validate inputs
  /// 2. Get document reference
  /// 3. Delete document from Firestore
  /// 4. Confirm successful deletion
  ///
  /// Parameters:
  /// - [userId]: The ID of the user who owns the project
  /// - [projectId]: The ID of the project to delete
  ///
  /// Returns:
  /// - Future<void> on successful deletion
  ///
  /// Throws:
  /// - [FirestoreServiceException] for validation or Firestore errors
  ///
  /// Important Notes:
  /// - This permanently deletes the project
  /// - Consider implementing soft delete (status: archived) instead
  /// - In production, you might want to delete associated subcollections
  /// - Consider adding a confirmation step in the UI
  Future<void> deleteProject(String userId, String projectId) async {
    try {
      // Input validation
      if (userId.isEmpty) {
        debugPrint('FirestoreService: Invalid userId - cannot be empty');
        throw const FirestoreServiceException(
          'User ID cannot be empty',
        );
      }

      if (projectId.isEmpty) {
        debugPrint('FirestoreService: Invalid projectId - cannot be empty');
        throw const FirestoreServiceException(
          'Project ID cannot be empty',
        );
      }

      debugPrint(
        'FirestoreService: Deleting project $projectId for user: $userId',
      );

      // Get the specific project document reference
      final projectDoc = _getProjectsCollection(userId).doc(projectId);

      // Delete the document
      await projectDoc.delete();

      debugPrint(
        'FirestoreService: Project $projectId deleted successfully',
      );
    } on FirestoreServiceException {
      // Re-throw our custom exceptions
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint(
        'FirestoreService: Firebase Exception while deleting project - '
        'Code: ${e.code}, Message: ${e.message}',
      );

      throw FirestoreServiceException(
        _handleFirebaseError(e),
      );
    } catch (e) {
      debugPrint(
        'FirestoreService: Unexpected error while deleting project: $e',
      );
      throw const FirestoreServiceException(
        'Failed to delete project. Please try again.',
      );
    }
  }

  /// Get a single project by ID
  ///
  /// This is a bonus method not in the original spec but useful for:
  /// - Loading project details screen
  /// - Refreshing single project data
  /// - Verification after updates
  ///
  /// Parameters:
  /// - [userId]: The ID of the user who owns the project
  /// - [projectId]: The ID of the project to fetch
  ///
  /// Returns:
  /// - Future<Project?> - the project if found, null otherwise
  ///
  /// Throws:
  /// - [FirestoreServiceException] for validation or Firestore errors
  Future<Project?> getProject(String userId, String projectId) async {
    try {
      // Input validation
      if (userId.isEmpty || projectId.isEmpty) {
        throw const FirestoreServiceException(
          'User ID and Project ID cannot be empty',
        );
      }

      debugPrint(
        'FirestoreService: Fetching project $projectId for user: $userId',
      );

      // Get the specific project document
      final projectDoc = _getProjectsCollection(userId).doc(projectId);
      final snapshot = await projectDoc.get();

      if (!snapshot.exists) {
        debugPrint('FirestoreService: Project $projectId not found');
        return null;
      }

      // Deserialize and return project
      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      final project = Project.fromJson(data);

      debugPrint('FirestoreService: Project $projectId fetched successfully');
      return project;
    } on FirestoreServiceException {
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint(
        'FirestoreService: Firebase Exception while fetching project - '
        'Code: ${e.code}, Message: ${e.message}',
      );
      throw FirestoreServiceException(
        _handleFirebaseError(e),
      );
    } catch (e) {
      debugPrint('FirestoreService: Unexpected error while fetching project: $e');
      throw const FirestoreServiceException(
        'Failed to fetch project. Please try again.',
      );
    }
  }

  /// Convert Firebase errors to user-friendly messages
  ///
  /// This private method centralizes error message handling.
  /// It demonstrates:
  /// - Error code mapping
  /// - User experience considerations
  /// - Maintainable error handling
  ///
  /// Benefits:
  /// - Consistent error messages across the app
  /// - Easy to update error text in one place
  /// - Better user experience with clear guidance
  ///
  /// Parameters:
  /// - [e]: FirebaseException to convert
  ///
  /// Returns:
  /// - User-friendly error message string
  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'not-found':
        return 'Project not found. It may have been deleted.';
      case 'already-exists':
        return 'Project already exists.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection and try again.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'unauthenticated':
        return 'You must be signed in to perform this action.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        debugPrint(
          'FirestoreService: Unhandled Firebase error code: ${e.code}',
        );
        return 'An error occurred. Please try again.';
    }
  }
}

/// Custom exception class for Firestore service errors
///
/// This class provides a consistent way to handle Firestore errors
/// throughout the app. It demonstrates:
/// - Custom exception creation
/// - Error message encapsulation
/// - Type safety for error handling
///
/// Benefits:
/// - Clear separation between Firestore errors and other errors
/// - Consistent error handling patterns
/// - Easy to catch and handle specifically
///
/// Usage:
/// ```dart
/// try {
///   await firestoreService.addProject(project);
/// } on FirestoreServiceException catch (e) {
///   // Handle Firestore-specific errors
///   showErrorMessage(e.message);
/// } catch (e) {
///   // Handle other errors
///   showGenericError();
/// }
/// ```
class FirestoreServiceException implements Exception {
  /// The user-friendly error message
  final String message;

  /// Create a FirestoreServiceException with a message
  const FirestoreServiceException(this.message);

  @override
  String toString() => 'FirestoreServiceException: $message';
}
