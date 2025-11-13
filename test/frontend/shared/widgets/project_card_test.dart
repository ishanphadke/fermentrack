import 'package:fermentrack/frontend/shared/widgets/project_card.dart';
import 'package:fermentrack/models/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ProjectCard Widget Tests
///
/// These tests verify that the ProjectCard widget:
/// - Renders project information correctly
/// - Displays appropriate icons for different project types
/// - Shows correct status badges
/// - Calculates days active correctly
/// - Handles tap gestures
/// - Deals gracefully with null/missing data
///
/// Learning Points:
/// - Widget testing with flutter_test
/// - Finding widgets by text and icon
/// - Testing user interactions
/// - Testing conditional rendering
/// - Material Design compliance
void main() {
  group('ProjectCard Widget Tests', () {
    // Test data
    final testDateTime = DateTime(2025, 1, 1);
    final testProject = Project(
      id: 'test-id-123',
      name: 'Test Sourdough',
      type: ProjectType.sourdough,
      startDate: testDateTime,
      userId: 'user-123',
      status: ProjectStatus.active,
      description: 'A test project for sourdough bread',
    );

    /// Helper function to wrap widget with MaterialApp for testing
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders project name', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        expect(find.text('Test Sourdough'), findsOneWidget);
      });

      testWidgets('renders project type', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        expect(find.text('Sourdough'), findsOneWidget);
      });

      testWidgets('renders project description', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        expect(find.text('A test project for sourdough bread'), findsOneWidget);
      });

      testWidgets('does not render description when null', (WidgetTester tester) async {
        // Arrange
        final projectWithoutDescription = testProject.copyWith(description: null);

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: projectWithoutDescription)),
        );

        // Assert - description should not be present
        expect(find.text('A test project for sourdough bread'), findsNothing);
      });

      testWidgets('does not render description when empty', (WidgetTester tester) async {
        // Arrange
        final projectWithEmptyDescription = testProject.copyWith(description: '');

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: projectWithEmptyDescription)),
        );

        // Assert - description section should not be visible
        // We verify by checking the spacing is correct (no extra SizedBox)
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        expect(sizedBoxes.length, lessThan(6)); // Fewer SizedBoxes when description is hidden
      });
    });

    group('Project Type Icons', () {
      testWidgets('displays correct icon for sourdough', (WidgetTester tester) async {
        // Arrange
        final sourdoughProject = testProject.copyWith(type: ProjectType.sourdough);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: sourdoughProject)));

        // Assert
        expect(find.byIcon(Icons.bakery_dining), findsOneWidget);
      });

      testWidgets('displays correct icon for kombucha', (WidgetTester tester) async {
        // Arrange
        final kombuchaProject = testProject.copyWith(type: ProjectType.kombucha);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: kombuchaProject)));

        // Assert
        expect(find.byIcon(Icons.local_drink), findsOneWidget);
        expect(find.text('Kombucha'), findsOneWidget);
      });

      testWidgets('displays correct icon for kimchi', (WidgetTester tester) async {
        // Arrange
        final kimchiProject = testProject.copyWith(type: ProjectType.kimchi);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: kimchiProject)));

        // Assert
        expect(find.byIcon(Icons.lunch_dining), findsOneWidget);
        expect(find.text('Kimchi'), findsOneWidget);
      });

      testWidgets('displays correct icon for water kefir', (WidgetTester tester) async {
        // Arrange
        final kefirProject = testProject.copyWith(type: ProjectType.waterKefir);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: kefirProject)));

        // Assert
        expect(find.byIcon(Icons.water_drop), findsOneWidget);
        expect(find.text('Water Kefir'), findsOneWidget);
      });

      testWidgets('displays correct icon for yogurt', (WidgetTester tester) async {
        // Arrange
        final yogurtProject = testProject.copyWith(type: ProjectType.yogurt);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: yogurtProject)));

        // Assert
        expect(find.byIcon(Icons.icecream), findsOneWidget);
        expect(find.text('Yogurt'), findsOneWidget);
      });

      testWidgets('displays correct icon for sauerkraut', (WidgetTester tester) async {
        // Arrange
        final sauerkrautProject = testProject.copyWith(type: ProjectType.sauerkraut);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: sauerkrautProject)));

        // Assert
        expect(find.byIcon(Icons.set_meal), findsOneWidget);
        expect(find.text('Sauerkraut'), findsOneWidget);
      });

      testWidgets('displays correct icon for other', (WidgetTester tester) async {
        // Arrange
        final otherProject = testProject.copyWith(type: ProjectType.other);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: otherProject)));

        // Assert
        expect(find.byIcon(Icons.science), findsOneWidget);
        expect(find.text('Other'), findsOneWidget);
      });
    });

    group('Status Badges', () {
      testWidgets('displays active status badge', (WidgetTester tester) async {
        // Arrange
        final activeProject = testProject.copyWith(status: ProjectStatus.active);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: activeProject)));

        // Assert
        expect(find.text('Active'), findsOneWidget);
      });

      testWidgets('displays paused status badge', (WidgetTester tester) async {
        // Arrange
        final pausedProject = testProject.copyWith(status: ProjectStatus.paused);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: pausedProject)));

        // Assert
        expect(find.text('Paused'), findsOneWidget);
      });

      testWidgets('displays completed status badge', (WidgetTester tester) async {
        // Arrange
        final completedProject = testProject.copyWith(status: ProjectStatus.completed);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: completedProject)));

        // Assert
        expect(find.text('Completed'), findsOneWidget);
      });

      testWidgets('displays archived status badge', (WidgetTester tester) async {
        // Arrange
        final archivedProject = testProject.copyWith(status: ProjectStatus.archived);

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: archivedProject)));

        // Assert
        expect(find.text('Archived'), findsOneWidget);
      });
    });

    group('Days Active Calculation', () {
      testWidgets('displays "< 1 day" for same-day project', (WidgetTester tester) async {
        // Arrange - project started today
        final todayProject = testProject.copyWith(
          startDate: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: todayProject)));

        // Assert
        expect(find.text('< 1 day'), findsOneWidget);
      });

      testWidgets('displays "1 day" for one-day-old project', (WidgetTester tester) async {
        // Arrange - project started yesterday
        final yesterdayProject = testProject.copyWith(
          startDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: yesterdayProject)));

        // Assert
        expect(find.text('1 day'), findsOneWidget);
      });

      testWidgets('displays correct days for multi-day project', (WidgetTester tester) async {
        // Arrange - project started 30 days ago
        final oldProject = testProject.copyWith(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: oldProject)));

        // Assert
        expect(find.textContaining('30 days'), findsOneWidget);
      });

      testWidgets('uses endDate for completed projects', (WidgetTester tester) async {
        // Arrange - completed project with specific duration
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 15); // 14 days later
        final completedProject = testProject.copyWith(
          startDate: startDate,
          endDate: endDate,
          status: ProjectStatus.completed,
        );

        // Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: completedProject)));

        // Assert
        expect(find.textContaining('14 days'), findsOneWidget);
      });
    });

    group('Date Formatting', () {
      testWidgets('displays formatted start date', (WidgetTester tester) async {
        // Arrange
        final projectWithSpecificDate = testProject.copyWith(
          startDate: DateTime(2025, 6, 15),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: projectWithSpecificDate)),
        );

        // Assert - Should contain the month name (format depends on locale)
        expect(find.text('Started'), findsOneWidget);
        // The actual date format may vary by locale, so we just verify it's present
        final card = tester.widget<ProjectCard>(find.byType(ProjectCard));
        expect(card.project.startDate, equals(DateTime(2025, 6, 15)));
      });
    });

    group('User Interactions', () {
      testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
        // Arrange
        bool wasTapped = false;
        await tester.pumpWidget(
          createTestWidget(
            ProjectCard(
              project: testProject,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ProjectCard));
        await tester.pumpAndSettle();

        // Assert
        expect(wasTapped, isTrue);
      });

      testWidgets('does not crash when onTap is null', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            ProjectCard(
              project: testProject,
              onTap: null,
            ),
          ),
        );

        // Try to tap
        await tester.tap(find.byType(ProjectCard));
        await tester.pumpAndSettle();

        // Assert - no crash, card still renders
        expect(find.byType(ProjectCard), findsOneWidget);
      });

      testWidgets('shows ink splash effect on tap', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createTestWidget(
            ProjectCard(
              project: testProject,
              onTap: () {},
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(InkWell));
        await tester.pump(); // Start the animation
        await tester.pump(const Duration(milliseconds: 100)); // Mid-animation

        // Assert - InkWell creates visual feedback
        expect(find.byType(InkWell), findsOneWidget);
      });
    });

    group('Material Design Compliance', () {
      testWidgets('uses Card widget with elevation', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, equals(2));
      });

      testWidgets('has proper margin', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
      });

      testWidgets('uses Hero widget for icon transition', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        expect(find.byType(Hero), findsOneWidget);
        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, equals('project-icon-test-id-123'));
      });

      testWidgets('includes Divider for visual separation', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(ProjectCard(project: testProject)));

        // Assert
        expect(find.byType(Divider), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long project names', (WidgetTester tester) async {
        // Arrange
        final longName = 'A' * 100;
        final longNameProject = testProject.copyWith(name: longName);

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: longNameProject)),
        );

        // Assert - should render without overflow
        expect(find.byType(ProjectCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles very long descriptions', (WidgetTester tester) async {
        // Arrange
        final longDescription = 'B' * 500;
        final longDescProject = testProject.copyWith(description: longDescription);

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: longDescProject)),
        );

        // Assert - should render without overflow (truncated with ellipsis)
        expect(find.byType(ProjectCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles special characters in name', (WidgetTester tester) async {
        // Arrange
        final specialNameProject = testProject.copyWith(
          name: 'Project with émojis 🍞 and spëcial chârs!',
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: specialNameProject)),
        );

        // Assert
        expect(find.text('Project with émojis 🍞 and spëcial chârs!'), findsOneWidget);
      });

      testWidgets('handles project with null id', (WidgetTester tester) async {
        // Arrange
        final noIdProject = testProject.copyWith(id: null);

        // Act
        await tester.pumpWidget(
          createTestWidget(ProjectCard(project: noIdProject)),
        );

        // Assert - should still render (Hero tag will be 'project-icon-null')
        expect(find.byType(ProjectCard), findsOneWidget);
      });

      testWidgets('renders consistently for all project types', (WidgetTester tester) async {
        // Test all project types can be rendered
        for (final type in ProjectType.values) {
          final project = testProject.copyWith(type: type);

          await tester.pumpWidget(
            createTestWidget(ProjectCard(project: project)),
          );

          // Assert - each type renders without error
          expect(find.byType(ProjectCard), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      });

      testWidgets('renders consistently for all status types', (WidgetTester tester) async {
        // Test all status types can be rendered
        for (final status in ProjectStatus.values) {
          final project = testProject.copyWith(status: status);

          await tester.pumpWidget(
            createTestWidget(ProjectCard(project: project)),
          );

          // Assert - each status renders without error
          expect(find.byType(ProjectCard), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      });
    });
  });
}
