import 'package:fermentrack/models/project.dart';
import 'package:flutter_test/flutter_test.dart';

/// Project Model Tests
///
/// These tests verify that the Project model:
/// - Creates instances correctly
/// - Maintains immutability
/// - Serializes to JSON correctly
/// - Deserializes from JSON correctly
/// - Uses copyWith() for updates
/// - Implements equality correctly
/// - Provides readable toString() output
///
/// Learning Points:
/// - Writing comprehensive unit tests
/// - Testing data models
/// - JSON serialization testing
/// - Immutability verification
/// - Equality testing patterns
void main() {
  group('Project Model Tests', () {
    // Test data setup
    final testDateTime = DateTime(2025, 1, 1);
    final testProject = Project(
      id: 'test-id-123',
      name: 'Test Sourdough',
      type: ProjectType.sourdough,
      startDate: testDateTime,
      userId: 'user-123',
      status: ProjectStatus.active,
      description: 'A test project',
    );

    group('Constructor and Basic Properties', () {
      test('creates Project with all required fields', () {
        expect(testProject.id, 'test-id-123');
        expect(testProject.name, 'Test Sourdough');
        expect(testProject.type, ProjectType.sourdough);
        expect(testProject.startDate, testDateTime);
        expect(testProject.userId, 'user-123');
        expect(testProject.status, ProjectStatus.active);
        expect(testProject.description, 'A test project');
      });

      test('creates Project without id (for new projects)', () {
        final newProject = Project(
          name: 'New Project',
          type: ProjectType.kombucha,
          startDate: testDateTime,
          userId: 'user-456',
        );

        expect(newProject.id, isNull);
        expect(newProject.name, 'New Project');
        expect(newProject.endDate, isNull);
        expect(newProject.description, isNull);
        expect(newProject.status, ProjectStatus.active); // Default value
      });

      test('creates Project with endDate', () {
        final endDateTime = DateTime(2025, 2, 1);
        final completedProject = Project(
          id: 'completed-123',
          name: 'Completed Project',
          type: ProjectType.kimchi,
          startDate: testDateTime,
          endDate: endDateTime,
          userId: 'user-789',
          status: ProjectStatus.completed,
        );

        expect(completedProject.endDate, endDateTime);
        expect(completedProject.status, ProjectStatus.completed);
      });
    });

    group('ProjectType Enum', () {
      test('has all expected fermentation types', () {
        expect(ProjectType.sourdough, isNotNull);
        expect(ProjectType.kombucha, isNotNull);
        expect(ProjectType.kimchi, isNotNull);
        expect(ProjectType.waterKefir, isNotNull);
        expect(ProjectType.yogurt, isNotNull);
        expect(ProjectType.sauerkraut, isNotNull);
        expect(ProjectType.other, isNotNull);
      });

      test('enum values are distinct', () {
        final types = ProjectType.values.toSet();
        expect(types.length, ProjectType.values.length);
      });
    });

    group('ProjectStatus Enum', () {
      test('has all expected status values', () {
        expect(ProjectStatus.active, isNotNull);
        expect(ProjectStatus.paused, isNotNull);
        expect(ProjectStatus.completed, isNotNull);
        expect(ProjectStatus.archived, isNotNull);
      });

      test('enum values are distinct', () {
        final statuses = ProjectStatus.values.toSet();
        expect(statuses.length, ProjectStatus.values.length);
      });

      test('active is the default status', () {
        final project = Project(
          name: 'Test',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
        );
        expect(project.status, ProjectStatus.active);
      });
    });

    group('Immutability', () {
      test('Project instances are immutable', () {
        // This test verifies that Freezed has made the class immutable
        // We do this by trying to use copyWith to create a new instance
        final original = Project(
          name: 'Original',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
        );

        // Create a modified copy
        final modified = original.copyWith(name: 'Modified');

        // Original should be unchanged
        expect(original.name, 'Original');
        expect(modified.name, 'Modified');

        // They should be different instances
        expect(identical(original, modified), isFalse);
      });
    });

    group('CopyWith Method', () {
      test('copyWith creates new instance with updated values', () {
        final updated = testProject.copyWith(
          name: 'Updated Name',
          status: ProjectStatus.completed,
        );

        expect(updated.name, 'Updated Name');
        expect(updated.status, ProjectStatus.completed);
        // Other fields should remain the same
        expect(updated.id, testProject.id);
        expect(updated.type, testProject.type);
        expect(updated.startDate, testProject.startDate);
        expect(updated.userId, testProject.userId);
      });

      test('copyWith can set null values for nullable fields', () {
        final projectWithDescription = Project(
          id: 'test-123',
          name: 'Test',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
          description: 'Original description',
        );

        final withoutDescription = projectWithDescription.copyWith(
          description: null,
        );

        expect(withoutDescription.description, isNull);
      });

      test('copyWith can update endDate', () {
        final endDateTime = DateTime(2025, 3, 1);
        final updated = testProject.copyWith(
          endDate: endDateTime,
          status: ProjectStatus.completed,
        );

        expect(updated.endDate, endDateTime);
        expect(updated.status, ProjectStatus.completed);
      });
    });

    group('Equality', () {
      test('two Projects with same values are equal', () {
        final project1 = Project(
          id: 'same-id',
          name: 'Same Project',
          type: ProjectType.kombucha,
          startDate: testDateTime,
          userId: 'user-123',
          status: ProjectStatus.active,
        );

        final project2 = Project(
          id: 'same-id',
          name: 'Same Project',
          type: ProjectType.kombucha,
          startDate: testDateTime,
          userId: 'user-123',
          status: ProjectStatus.active,
        );

        expect(project1, equals(project2));
        expect(project1.hashCode, equals(project2.hashCode));
      });

      test('two Projects with different values are not equal', () {
        final project1 = Project(
          id: 'id-1',
          name: 'Project 1',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
        );

        final project2 = Project(
          id: 'id-2',
          name: 'Project 2',
          type: ProjectType.kombucha,
          startDate: testDateTime,
          userId: 'user-123',
        );

        expect(project1, isNot(equals(project2)));
      });
    });

    group('ToString', () {
      test('toString returns readable output', () {
        final output = testProject.toString();

        // Verify that key fields are present in the string
        expect(output, contains('Test Sourdough'));
        expect(output, contains('test-id-123'));
        expect(output, contains('sourdough'));
        expect(output, contains('active'));
      });

      test('toString handles null values', () {
        final projectWithNulls = Project(
          name: 'Project',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
        );

        final output = projectWithNulls.toString();
        // Should not throw and should be readable
        expect(output, isNotEmpty);
        expect(output, contains('Project'));
      });
    });

    group('JSON Serialization', () {
      test('toJson converts Project to Map', () {
        final json = testProject.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], 'test-id-123');
        expect(json['name'], 'Test Sourdough');
        expect(json['type'], 'sourdough'); // Enum as string
        expect(json['userId'], 'user-123');
        expect(json['status'], 'active');
        expect(json['description'], 'A test project');
        expect(json['startDate'], isA<String>()); // DateTime as ISO string
      });

      test('toJson handles null values', () {
        final project = Project(
          name: 'Project',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
        );

        final json = project.toJson();

        expect(json['id'], isNull);
        expect(json['endDate'], isNull);
        expect(json['description'], isNull);
      });

      test('fromJson creates Project from Map', () {
        final json = {
          'id': 'json-id-456',
          'name': 'JSON Project',
          'type': 'kombucha',
          'startDate': '2025-01-15T10:30:00.000Z',
          'userId': 'user-789',
          'status': 'completed',
          'description': 'From JSON',
        };

        final project = Project.fromJson(json);

        expect(project.id, 'json-id-456');
        expect(project.name, 'JSON Project');
        expect(project.type, ProjectType.kombucha);
        expect(project.userId, 'user-789');
        expect(project.status, ProjectStatus.completed);
        expect(project.description, 'From JSON');
        expect(project.startDate, isA<DateTime>());
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'name': 'Minimal Project',
          'type': 'kimchi',
          'startDate': '2025-01-01T00:00:00.000Z',
          'userId': 'user-123',
        };

        final project = Project.fromJson(json);

        expect(project.id, isNull);
        expect(project.endDate, isNull);
        expect(project.description, isNull);
        expect(project.status, ProjectStatus.active); // Default value
      });

      test('roundtrip: toJson -> fromJson preserves data', () {
        final json = testProject.toJson();
        final reconstructed = Project.fromJson(json);

        expect(reconstructed, equals(testProject));
      });

      test('roundtrip with endDate: toJson -> fromJson preserves data', () {
        final endDateTime = DateTime(2025, 6, 1);
        final completedProject = Project(
          id: 'completed-456',
          name: 'Finished Project',
          type: ProjectType.sauerkraut,
          startDate: testDateTime,
          endDate: endDateTime,
          userId: 'user-999',
          status: ProjectStatus.completed,
          description: 'All done!',
        );

        final json = completedProject.toJson();
        final reconstructed = Project.fromJson(json);

        expect(reconstructed, equals(completedProject));
        expect(reconstructed.endDate, isNotNull);
        expect(reconstructed.endDate, endDateTime);
      });
    });

    group('Edge Cases', () {
      test('handles very long project names', () {
        final longName = 'A' * 1000;
        final project = Project(
          name: longName,
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
        );

        expect(project.name, longName);
        expect(project.name.length, 1000);

        // Verify serialization works
        final json = project.toJson();
        final reconstructed = Project.fromJson(json);
        expect(reconstructed.name, longName);
      });

      test('handles special characters in fields', () {
        final project = Project(
          name: 'Project with émojis 🍞 and spëcial chârs',
          type: ProjectType.sourdough,
          startDate: testDateTime,
          userId: 'user-123',
          description: 'Testing "quotes" and \'apostrophes\' & ampersands',
        );

        final json = project.toJson();
        final reconstructed = Project.fromJson(json);

        expect(reconstructed.name, project.name);
        expect(reconstructed.description, project.description);
      });

      test('handles dates in different timezones', () {
        final utcDate = DateTime.utc(2025, 3, 15, 14, 30);
        final localDate = DateTime(2025, 3, 15, 14, 30);

        final utcProject = Project(
          name: 'UTC Project',
          type: ProjectType.sourdough,
          startDate: utcDate,
          userId: 'user-123',
        );

        final localProject = Project(
          name: 'Local Project',
          type: ProjectType.sourdough,
          startDate: localDate,
          userId: 'user-123',
        );

        // Both should serialize and deserialize correctly
        final utcJson = utcProject.toJson();
        final localJson = localProject.toJson();

        final utcReconstructed = Project.fromJson(utcJson);
        final localReconstructed = Project.fromJson(localJson);

        expect(utcReconstructed.startDate, utcDate);
        expect(localReconstructed.startDate, localDate);
      });

      test('handles all ProjectType enum values in serialization', () {
        for (final type in ProjectType.values) {
          final project = Project(
            name: 'Test ${type.name}',
            type: type,
            startDate: testDateTime,
            userId: 'user-123',
          );

          final json = project.toJson();
          final reconstructed = Project.fromJson(json);

          expect(reconstructed.type, type);
        }
      });

      test('handles all ProjectStatus enum values in serialization', () {
        for (final status in ProjectStatus.values) {
          final project = Project(
            name: 'Test',
            type: ProjectType.sourdough,
            startDate: testDateTime,
            userId: 'user-123',
            status: status,
          );

          final json = project.toJson();
          final reconstructed = Project.fromJson(json);

          expect(reconstructed.status, status);
        }
      });
    });
  });
}
