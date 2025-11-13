import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fermentrack/middleware/services/firestore_service.dart';
import 'package:fermentrack/models/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firestore_service_test.mocks.dart';

/// Firestore Service Tests
///
/// These tests verify that the FirestoreService:
/// - Performs CRUD operations correctly
/// - Handles errors gracefully
/// - Validates input properly
/// - Provides real-time streams of data
/// - Isolates user data correctly
///
/// Learning Points:
/// - Mocking Firestore with Mockito
/// - Testing async operations
/// - Testing streams
/// - Error handling verification
/// - Service layer testing patterns
///
/// Testing Strategy:
/// - Mock FirebaseFirestore to avoid real database calls
/// - Test each method in isolation
/// - Verify error handling paths
/// - Test edge cases and validation

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  group('FirestoreService Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
    late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
    late MockCollectionReference<Map<String, dynamic>> mockProjectsCollection;
    late MockDocumentReference<Map<String, dynamic>> mockProjectDoc;
    late FirestoreService service;

    // Test data
    const testUserId = 'test-user-123';
    const testProjectId = 'test-project-456';
    final testDateTime = DateTime(2025, 1, 1);
    final testProject = Project(
      id: testProjectId,
      name: 'Test Sourdough',
      type: ProjectType.sourdough,
      startDate: testDateTime,
      userId: testUserId,
      status: ProjectStatus.active,
      description: 'Test project description',
    );

    setUp(() {
      // Initialize mocks
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
      mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
      mockProjectsCollection = MockCollectionReference<Map<String, dynamic>>();
      mockProjectDoc = MockDocumentReference<Map<String, dynamic>>();

      // Set up default mock behavior for collection path
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
      when(mockUserDoc.collection('projects'))
          .thenReturn(mockProjectsCollection);

      // Create service with mocked Firestore
      service = FirestoreService(firestore: mockFirestore);
    });

    group('getProjectsStream', () {
      test('returns stream of projects for valid userId', () async {
        // Arrange: Create mock query snapshot with projects
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        final projectData = testProject.toJson();
        projectData.remove('id'); // Firestore data doesn't include id

        when(mockProjectsCollection.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
        when(mockDocSnapshot.id).thenReturn(testProjectId);
        when(mockDocSnapshot.data()).thenReturn(projectData);

        // Act: Get the stream and listen to it
        final stream = service.getProjectsStream(testUserId);
        final projects = await stream.first;

        // Assert: Verify correct project was returned
        expect(projects, hasLength(1));
        expect(projects.first.id, testProjectId);
        expect(projects.first.name, testProject.name);
        expect(projects.first.type, testProject.type);
        expect(projects.first.userId, testProject.userId);
      });

      test('returns empty list when no projects exist', () async {
        // Arrange: Mock empty query snapshot
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

        when(mockProjectsCollection.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final stream = service.getProjectsStream(testUserId);
        final projects = await stream.first;

        // Assert
        expect(projects, isEmpty);
      });

      test('handles multiple projects in stream', () async {
        // Arrange: Create multiple mock documents
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        final project1Data = testProject.toJson();
        project1Data.remove('id');

        final project2 = testProject.copyWith(
          id: 'project-2',
          name: 'Second Project',
        );
        final project2Data = project2.toJson();
        project2Data.remove('id');

        when(mockProjectsCollection.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

        when(mockDoc1.id).thenReturn(testProjectId);
        when(mockDoc1.data()).thenReturn(project1Data);
        when(mockDoc2.id).thenReturn('project-2');
        when(mockDoc2.data()).thenReturn(project2Data);

        // Act
        final stream = service.getProjectsStream(testUserId);
        final projects = await stream.first;

        // Assert
        expect(projects, hasLength(2));
        expect(projects[0].name, 'Test Sourdough');
        expect(projects[1].name, 'Second Project');
      });

      test('throws exception for empty userId', () {
        // Act & Assert
        expect(
          () => service.getProjectsStream(''),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('continues processing if one document fails deserialization', () async {
        // Arrange: Create one valid and one invalid document
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        final validData = testProject.toJson();
        validData.remove('id');

        final invalidData = {'invalid': 'data'}; // Missing required fields

        when(mockProjectsCollection.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

        when(mockDoc1.id).thenReturn(testProjectId);
        when(mockDoc1.data()).thenReturn(validData);
        when(mockDoc2.id).thenReturn('invalid-doc');
        when(mockDoc2.data()).thenReturn(invalidData);

        // Act
        final stream = service.getProjectsStream(testUserId);
        final projects = await stream.first;

        // Assert: Should return only the valid project
        expect(projects, hasLength(1));
        expect(projects.first.id, testProjectId);
      });
    });

    group('addProject', () {
      test('adds project successfully and returns project with id', () async {
        // Arrange
        final newProject = testProject.copyWith(id: null);
        when(mockProjectsCollection.add(any))
            .thenAnswer((_) async => mockProjectDoc);
        when(mockProjectDoc.id).thenReturn(testProjectId);

        // Act
        final result = await service.addProject(newProject);

        // Assert
        expect(result.id, testProjectId);
        expect(result.name, newProject.name);
        expect(result.type, newProject.type);
        expect(result.userId, newProject.userId);

        // Verify Firestore add was called
        verify(mockProjectsCollection.add(any)).called(1);
      });

      test('throws exception for empty userId', () async {
        // Arrange
        final invalidProject = testProject.copyWith(userId: '');

        // Act & Assert
        await expectLater(
          service.addProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for empty project name', () async {
        // Arrange
        final invalidProject = testProject.copyWith(name: '');

        // Act & Assert
        await expectLater(
          service.addProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for whitespace-only project name', () async {
        // Arrange
        final invalidProject = testProject.copyWith(name: '   ');

        // Act & Assert
        await expectLater(
          service.addProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('handles Firebase permission errors', () async {
        // Arrange
        when(mockProjectsCollection.add(any)).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        );

        // Act & Assert
        await expectLater(
          service.addProject(testProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });
    });

    group('updateProject', () {
      test('updates project successfully', () async {
        // Arrange
        when(mockProjectsCollection.doc(testProjectId))
            .thenReturn(mockProjectDoc);
        when(mockProjectDoc.update(any)).thenAnswer((_) async => {});

        // Act
        await service.updateProject(testProject);

        // Assert
        verify(mockProjectDoc.update(any)).called(1);
      });

      test('throws exception for null project id', () async {
        // Arrange
        final invalidProject = testProject.copyWith(id: null);

        // Act & Assert
        await expectLater(
          service.updateProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for empty project id', () async {
        // Arrange
        final invalidProject = testProject.copyWith(id: '');

        // Act & Assert
        await expectLater(
          service.updateProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for empty userId', () async {
        // Arrange
        final invalidProject = testProject.copyWith(userId: '');

        // Act & Assert
        await expectLater(
          service.updateProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for empty project name', () async {
        // Arrange
        final invalidProject = testProject.copyWith(name: '');

        // Act & Assert
        await expectLater(
          service.updateProject(invalidProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('handles not-found error for non-existent project', () async {
        // Arrange
        when(mockProjectsCollection.doc(testProjectId))
            .thenReturn(mockProjectDoc);
        when(mockProjectDoc.update(any)).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
          ),
        );

        // Act & Assert
        await expectLater(
          service.updateProject(testProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });
    });

    group('deleteProject', () {
      test('deletes project successfully', () async {
        // Arrange
        when(mockProjectsCollection.doc(testProjectId))
            .thenReturn(mockProjectDoc);
        when(mockProjectDoc.delete()).thenAnswer((_) async => {});

        // Act
        await service.deleteProject(testUserId, testProjectId);

        // Assert
        verify(mockProjectDoc.delete()).called(1);
      });

      test('throws exception for empty userId', () async {
        // Act & Assert
        await expectLater(
          service.deleteProject('', testProjectId),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for empty projectId', () async {
        // Act & Assert
        await expectLater(
          service.deleteProject(testUserId, ''),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('handles Firebase errors gracefully', () async {
        // Arrange
        when(mockProjectsCollection.doc(testProjectId))
            .thenReturn(mockProjectDoc);
        when(mockProjectDoc.delete()).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        );

        // Act & Assert
        await expectLater(
          service.deleteProject(testUserId, testProjectId),
          throwsA(isA<FirestoreServiceException>()),
        );
      });
    });

    group('getProject', () {
      test('returns project when found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        final projectData = testProject.toJson();
        projectData.remove('id');

        when(mockProjectsCollection.doc(testProjectId))
            .thenReturn(mockProjectDoc);
        when(mockProjectDoc.get())
            .thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn(projectData);
        when(mockDocSnapshot.id).thenReturn(testProjectId);

        // Act
        final result = await service.getProject(testUserId, testProjectId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, testProjectId);
        expect(result.name, testProject.name);
      });

      test('returns null when project not found', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockProjectsCollection.doc(testProjectId))
            .thenReturn(mockProjectDoc);
        when(mockProjectDoc.get())
            .thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await service.getProject(testUserId, testProjectId);

        // Assert
        expect(result, isNull);
      });

      test('throws exception for empty userId', () async {
        // Act & Assert
        await expectLater(
          service.getProject('', testProjectId),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('throws exception for empty projectId', () async {
        // Act & Assert
        await expectLater(
          service.getProject(testUserId, ''),
          throwsA(isA<FirestoreServiceException>()),
        );
      });
    });

    group('Error Handling', () {
      test('handles network errors', () async {
        // Arrange
        when(mockProjectsCollection.add(any)).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'network-request-failed',
          ),
        );

        // Act & Assert
        await expectLater(
          service.addProject(testProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('handles unavailable service error', () async {
        // Arrange
        when(mockProjectsCollection.add(any)).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
          ),
        );

        // Act & Assert
        await expectLater(
          service.addProject(testProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('handles unauthenticated error', () async {
        // Arrange
        when(mockProjectsCollection.add(any)).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unauthenticated',
          ),
        );

        // Act & Assert
        await expectLater(
          service.addProject(testProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });

      test('handles unexpected errors', () async {
        // Arrange
        when(mockProjectsCollection.add(any))
            .thenThrow(Exception('Unexpected error'));

        // Act & Assert
        await expectLater(
          service.addProject(testProject),
          throwsA(isA<FirestoreServiceException>()),
        );
      });
    });

    group('FirestoreServiceException', () {
      test('exception contains message', () {
        const exception = FirestoreServiceException('Test error message');
        expect(exception.message, 'Test error message');
      });

      test('exception toString includes message', () {
        const exception = FirestoreServiceException('Test error');
        expect(exception.toString(), contains('Test error'));
      });
    });
  });
}
