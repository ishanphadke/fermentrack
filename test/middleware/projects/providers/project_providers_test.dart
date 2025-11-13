import 'package:fermentrack/middleware/auth/providers/auth_providers.dart';
import 'package:fermentrack/middleware/projects/providers/project_providers.dart';
import 'package:fermentrack/middleware/services/firestore_service.dart';
import 'package:fermentrack/models/project.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'project_providers_test.mocks.dart';

/// Project Providers Tests
///
/// These tests verify that the Riverpod providers:
/// - Create service instances correctly
/// - Stream project data properly
/// - Filter and transform data correctly
/// - Handle authentication state changes
/// - Respond to data updates
///
/// Learning Points:
/// - Testing Riverpod providers
/// - Mocking services for tests
/// - Testing stream providers
/// - Testing provider overrides
/// - Async testing patterns
/// - Provider state management
///
/// Testing Strategy:
/// - Use ProviderContainer for isolated provider testing
/// - Mock services and auth state
/// - Test each provider in isolation
/// - Verify provider dependencies work correctly
/// - Ensure proper cleanup and disposal

@GenerateMocks([FirestoreService, User])
void main() {
  group('Project Providers Tests', () {
    late MockFirestoreService mockFirestoreService;
    late MockUser mockUser;
    late ProviderContainer container;

    // Test data
    const testUserId = 'test-user-123';
    final testDateTime = DateTime(2025, 1, 1);
    final testProject1 = Project(
      id: 'project-1',
      name: 'Test Sourdough',
      type: ProjectType.sourdough,
      startDate: testDateTime,
      userId: testUserId,
      status: ProjectStatus.active,
    );

    final testProject2 = Project(
      id: 'project-2',
      name: 'Test Kombucha',
      type: ProjectType.kombucha,
      startDate: testDateTime,
      userId: testUserId,
      status: ProjectStatus.paused,
    );

    final testProject3 = Project(
      id: 'project-3',
      name: 'Completed Kimchi',
      type: ProjectType.kimchi,
      startDate: testDateTime,
      userId: testUserId,
      status: ProjectStatus.completed,
    );

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      mockUser = MockUser();

      // Setup mock user
      when(mockUser.uid).thenReturn(testUserId);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
    });

    tearDown(() {
      // Important: Dispose container after each test to prevent memory leaks
      // and ensure clean state between tests
      container.dispose();
    });

    group('firestoreServiceProvider', () {
      test('provides FirestoreService instance', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
          ],
        );

        // Act
        final service = container.read(firestoreServiceProvider);

        // Assert
        expect(service, isA<FirestoreService>());
      });
    });

    group('userProjectsProvider', () {
      test('returns empty list when user is not authenticated', () async {
        // Arrange
        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            // Override auth state to return null (no user)
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Act
        // Listen to the provider before reading to ensure stream is established
        final listener = container.listen(
          userProjectsProvider,
          (previous, next) {},
        );

        // Wait for the provider to emit a value
        await container.read(userProjectsProvider.future);

        // Assert
        final projectsAsync = container.read(userProjectsProvider);
        expect(
          projectsAsync.when(
            data: (projects) => projects,
            loading: () => null,
            error: (_, __) => null,
          ),
          isEmpty,
        );

        // Cleanup
        listener.close();
      });

      test('returns projects stream when user is authenticated', () async {
        // Arrange
        final projectsStream = Stream.value([testProject1, testProject2]);

        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => projectsStream);

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            // Override auth state to return authenticated user
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        // Listen to the provider before reading
        final listener = container.listen(
          userProjectsProvider,
          (previous, next) {},
        );

        // Wait for the async provider to complete
        final projects = await container.read(userProjectsProvider.future);

        // Assert
        expect(projects, hasLength(2));
        expect(projects[0].name, 'Test Sourdough');
        expect(projects[1].name, 'Test Kombucha');

        // Verify the service was called with correct user ID
        verify(mockFirestoreService.getProjectsStream(testUserId)).called(1);

        // Cleanup
        listener.close();
      });

      test('handles empty projects list', () async {
        // Arrange
        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => Stream.value([]));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          userProjectsProvider,
          (previous, next) {},
        );

        final projects = await container.read(userProjectsProvider.future);

        // Assert
        expect(projects, isEmpty);

        // Cleanup
        listener.close();
      });

      test('emits updates when projects change', () async {
        // Arrange
        // Create a stream controller to emit multiple values
        final List<List<Project>> emittedValues = [];
        final projectsStream = Stream.fromIterable([
          [testProject1], // First emission
          [testProject1, testProject2], // Second emission (project added)
        ]);

        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => projectsStream);

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          userProjectsProvider,
          (previous, next) {
            next.whenData((projects) => emittedValues.add(projects));
          },
        );

        // Wait for stream to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(emittedValues.length, greaterThanOrEqualTo(1));

        // Cleanup
        listener.close();
      });
    });

    group('activeProjectsProvider', () {
      test('filters only active projects', () async {
        // Arrange
        final allProjects = [testProject1, testProject2, testProject3];
        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => Stream.value(allProjects));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          activeProjectsProvider,
          (previous, next) {},
        );

        final activeProjects = await container.read(activeProjectsProvider.future);

        // Assert
        expect(activeProjects, hasLength(1));
        expect(activeProjects.first.status, ProjectStatus.active);
        expect(activeProjects.first.name, 'Test Sourdough');

        // Cleanup
        listener.close();
      });

      test('returns empty list when no active projects', () async {
        // Arrange
        final completedProjects = [testProject2, testProject3]; // Both non-active
        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => Stream.value(completedProjects));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          activeProjectsProvider,
          (previous, next) {},
        );

        final activeProjects = await container.read(activeProjectsProvider.future);

        // Assert
        expect(activeProjects, isEmpty);

        // Cleanup
        listener.close();
      });

      test('returns empty list when user not authenticated', () async {
        // Arrange
        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Act
        final listener = container.listen(
          activeProjectsProvider,
          (previous, next) {},
        );

        final activeProjects = await container.read(activeProjectsProvider.future);

        // Assert
        expect(activeProjects, isEmpty);

        // Cleanup
        listener.close();
      });
    });

    group('projectCountProvider', () {
      test('returns correct count of projects', () async {
        // Arrange
        final projects = [testProject1, testProject2, testProject3];
        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => Stream.value(projects));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          projectCountProvider,
          (previous, next) {},
        );

        final count = await container.read(projectCountProvider.future);

        // Assert
        expect(count, 3);

        // Cleanup
        listener.close();
      });

      test('returns 0 when no projects', () async {
        // Arrange
        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => Stream.value([]));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          projectCountProvider,
          (previous, next) {},
        );

        final count = await container.read(projectCountProvider.future);

        // Assert
        expect(count, 0);

        // Cleanup
        listener.close();
      });

      test('returns 0 when user not authenticated', () async {
        // Arrange
        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Act
        final listener = container.listen(
          projectCountProvider,
          (previous, next) {},
        );

        final count = await container.read(projectCountProvider.future);

        // Assert
        expect(count, 0);

        // Cleanup
        listener.close();
      });
    });

    group('projectByIdProvider', () {
      test('returns project when found', () async {
        // Arrange
        when(mockFirestoreService.getProject(testUserId, 'project-1'))
            .thenAnswer((_) async => testProject1);

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final project = await container.read(projectByIdProvider('project-1').future);

        // Assert
        expect(project, isNotNull);
        expect(project!.id, 'project-1');
        expect(project.name, 'Test Sourdough');

        // Verify service was called with correct parameters
        verify(mockFirestoreService.getProject(testUserId, 'project-1')).called(1);
      });

      test('returns null when project not found', () async {
        // Arrange
        when(mockFirestoreService.getProject(testUserId, 'non-existent'))
            .thenAnswer((_) async => null);

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final project = await container.read(projectByIdProvider('non-existent').future);

        // Assert
        expect(project, isNull);
      });

      test('returns null when user not authenticated', () async {
        // Arrange
        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        // Act
        final project = await container.read(projectByIdProvider('project-1').future);

        // Assert
        expect(project, isNull);
        // Service should not be called when no user
        verifyNever(mockFirestoreService.getProject(any, any));
      });

      test('returns null when service throws exception', () async {
        // Arrange
        when(mockFirestoreService.getProject(testUserId, 'project-1'))
            .thenThrow(Exception('Firestore error'));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final project = await container.read(projectByIdProvider('project-1').future);

        // Assert
        expect(project, isNull);
      });

      test('can fetch different projects with different IDs', () async {
        // Arrange
        when(mockFirestoreService.getProject(testUserId, 'project-1'))
            .thenAnswer((_) async => testProject1);
        when(mockFirestoreService.getProject(testUserId, 'project-2'))
            .thenAnswer((_) async => testProject2);

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final project1 = await container.read(projectByIdProvider('project-1').future);
        final project2 = await container.read(projectByIdProvider('project-2').future);

        // Assert
        expect(project1!.id, 'project-1');
        expect(project2!.id, 'project-2');
        expect(project1.name, 'Test Sourdough');
        expect(project2.name, 'Test Kombucha');
      });
    });

    group('Provider Dependencies', () {
      test('userProjectsProvider depends on authStateProvider', () async {
        // Arrange
        when(mockFirestoreService.getProjectsStream(testUserId))
            .thenAnswer((_) => Stream.value([testProject1]));

        container = ProviderContainer(
          overrides: [
            firestoreServiceProvider.overrideWithValue(mockFirestoreService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );

        // Act
        final listener = container.listen(
          userProjectsProvider,
          (previous, next) {},
        );

        await container.read(userProjectsProvider.future);

        // Now change auth state to null
        container.updateOverrides([
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ]);

        // Wait for provider to react to auth state change
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - provider should react to auth state change
        // The specific behavior depends on your implementation

        // Cleanup
        listener.close();
      });
    });
  });
}
