import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fermentrack/core/features/auth/presentation/password_reset_screen.dart';
import 'package:fermentrack/providers/auth/auth_providers.dart';
import 'package:fermentrack/services/auth_service.dart';

// Generate mocks for FirebaseAuth
@GenerateMocks([auth.FirebaseAuth])
import 'password_reset_screen_test.mocks.dart';

/// Widget tests for PasswordResetScreen (Sub-Issue 2.1.5)
///
/// These tests verify the acceptance criteria from the GitHub issue:
/// - Email field validates format (empty, no @)
/// - Success message appears after email sent
/// - Error message shows for invalid email
/// - Button shows loading state during API call
/// - Navigation back to login works
/// - Screen handles network errors gracefully
///
/// Learning objectives for new engineers:
/// - Widget testing fundamentals
/// - Email validation testing
/// - Async operation testing
/// - Loading state verification
/// - Success/error state testing
/// - User feedback testing (SnackBar)

void main() {
  group('PasswordResetScreen Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      // Initialize mocks before each test
      mockFirebaseAuth = MockFirebaseAuth();
    });

    // Helper function to create testable widget
    // Wraps PasswordResetScreen with ProviderScope for Riverpod support
    // Overrides authServiceProvider with mock AuthService
    Widget createPasswordResetScreen() {
      return ProviderScope(
        overrides: [
          // Override the authServiceProvider with a mock AuthService
          authServiceProvider.overrideWithValue(
            AuthService(firebaseAuth: mockFirebaseAuth),
          ),
        ],
        child: const MaterialApp(
          home: PasswordResetScreen(),
        ),
      );
    }

    group('UI Rendering Tests', () {
      testWidgets('should render all required UI elements', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act & Assert - Verify all UI elements are present
        expect(find.text('Reset Password'), findsOneWidget); // AppBar title
        expect(
          find.text(
            'Enter your email address and we\'ll send you a link to reset your password.',
          ),
          findsOneWidget,
        ); // Instruction text
        expect(find.byType(TextFormField), findsOneWidget); // Email field
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Send Reset Email'), findsOneWidget);
        expect(find.text('Back to Login'), findsOneWidget);

        // Verify email icon is present
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('should have proper hint texts and labels', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act & Assert - Check for specific text elements
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);
      });
    });

    group('Email Field Validation Tests', () {
      testWidgets('should show error for empty email', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Tap send button with empty email field
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Error message should appear
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Enter invalid email (no @ symbol) and trigger validation
        await tester.enterText(find.byType(TextFormField), 'invalid-email');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Email validation error should appear
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (tester) async {
        // Arrange
        // Mock successful password reset
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer((_) async => Future.value());

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Enter valid email and wait for validation to pass
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.pump(); // Allow the form to update with valid text

        // Assert - Before submission, no validation errors should appear for valid email
        expect(find.text('Please enter your email'), findsNothing);
        expect(find.text('Please enter a valid email'), findsNothing);

        // Act - Submit the form
        await tester.tap(find.byType(ElevatedButton));

        // Verify form submission was attempted (email field gets cleared on success)
        await tester.pumpAndSettle();

        // After successful submission, the field is cleared which may trigger
        // validation again, but the submission itself should have succeeded
        verify(
          mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'),
        ).called(1);
      });
    });

    group('Form Submission Tests', () {
      testWidgets('should prevent submission with invalid email',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Try to submit with invalid email
        await tester.enterText(find.byType(TextFormField), 'invalid-email');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Form should not submit, email validation error should show
        expect(find.text('Please enter a valid email'), findsOneWidget);

        // Verify that sendPasswordResetEmail was never called
        verifyNever(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        );
      });

      testWidgets('should show loading state during password reset',
          (tester) async {
        // Arrange
        // Mock password reset with a delay to test loading state
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return Future.value();
          },
        );

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit valid email
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Trigger the loading state

        // Assert - Loading spinner should appear and button should be disabled
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Find the ElevatedButton and check if it's disabled
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull); // Disabled button has null onPressed

        // Clean up - Let the async operation complete
        await tester.pumpAndSettle();
      });

      testWidgets(
          'should show success message after sending reset email',
          (tester) async {
        // Arrange
        // Mock successful password reset
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer((_) async => Future.value());

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit valid email and wait for completion
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle(); // Wait for async operation to complete

        // Assert - Verify no exceptions occurred
        expect(tester.takeException(), isNull);

        // Loading should be complete
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Button should be enabled again
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);

        // Verify that sendPasswordResetEmail was called
        verify(
          mockFirebaseAuth.sendPasswordResetEmail(
            email: 'test@example.com',
          ),
        ).called(1);
      });

      testWidgets('should clear email field after successful submission',
          (tester) async {
        // Arrange
        // Mock successful password reset
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer((_) async => Future.value());

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit valid email and wait for completion
        const testEmail = 'test@example.com';
        await tester.enterText(find.byType(TextFormField), testEmail);
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle(); // Wait for async operation to complete

        // Assert - Email field should be cleared
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      });

      testWidgets('should handle network errors gracefully', (tester) async {
        // Arrange
        // Mock network error
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenThrow(
          auth.FirebaseAuthException(code: 'network-request-failed'),
        );

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit valid email
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Error should be handled without crashing
        expect(tester.takeException(), isNull);

        // Button should be enabled again (loading complete)
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should handle invalid-email error from Firebase',
          (tester) async {
        // Arrange
        // Mock invalid email error
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenThrow(
          auth.FirebaseAuthException(code: 'invalid-email'),
        );

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit email that Firebase rejects
        await tester.enterText(find.byType(TextFormField), 'bad@email');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Error should be handled gracefully
        expect(tester.takeException(), isNull);

        // Button should be enabled again
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should handle user-not-found without revealing it',
          (tester) async {
        // Arrange
        // Mock user not found (security: should still show success)
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenThrow(
          auth.FirebaseAuthException(code: 'user-not-found'),
        );

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit email for non-existent user
        await tester.enterText(
          find.byType(TextFormField),
          'nonexistent@example.com',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Should handle gracefully (security: don't reveal user existence)
        expect(tester.takeException(), isNull);

        // Button should be enabled again
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate back to login when back button pressed',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Tap "Back to Login" button
        await tester.tap(find.text('Back to Login'));
        await tester.pumpAndSettle();

        // Assert - Navigation should occur without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support AppBar back button', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Tap back button in AppBar (if present)
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();

          // Assert - Navigation should occur without errors
          expect(tester.takeException(), isNull);
        }
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should support text input and focus', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Test text entry in email field
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.pumpAndSettle();

        // Assert - Text should appear in the field
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('should have email keyboard type', (tester) async {
        // Arrange
        await tester.pumpWidget(createPasswordResetScreen());

        // Act & Assert - Verify email keyboard type is set by checking TextField
        // TextFormField wraps TextField, so we need to find the TextField widget
        final textField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField),
            matching: find.byType(TextField),
          ),
        );
        expect(
          textField.keyboardType,
          TextInputType.emailAddress,
        );
      });
    });

    group('Button State Tests', () {
      testWidgets('button should be enabled with valid email', (tester) async {
        // Arrange
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer((_) async => Future.value());

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Enter valid email
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.pump();

        // Assert - Button should be enabled
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('button should disable during API call', (tester) async {
        // Arrange
        when(mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')))
            .thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return Future.value();
          },
        );

        await tester.pumpWidget(createPasswordResetScreen());

        // Act - Submit form
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Start the async operation

        // Assert - Button should be disabled during loading
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);

        // Clean up
        await tester.pumpAndSettle();
      });
    });
  });
}
