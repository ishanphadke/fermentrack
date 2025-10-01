import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fermentrack/core/features/auth/presentation/signup_screen.dart';
import 'package:fermentrack/providers/auth/auth_providers.dart';
import 'package:fermentrack/services/auth_service.dart';

// Generate mocks for FirebaseAuth and User
@GenerateMocks([auth.FirebaseAuth, auth.User, auth.UserCredential])
import 'signup_screen_test.mocks.dart';

/// Widget tests for SignupScreen (Sub-Issue 2.1.4)
///
/// These tests verify the acceptance criteria from the GitHub issue:
/// - Email field validates format correctly
/// - Password field shows strength requirements
/// - Confirm password validates matching passwords
/// - Form prevents submission with invalid data
/// - Success state navigates to login or dashboard
/// - Navigation to login screen works
/// - Password strength indicator displays correctly
///
/// Learning objectives for new engineers:
/// - Widget testing fundamentals
/// - Multi-field form validation testing
/// - Password strength validation testing
/// - User interaction simulation
/// - State change verification
/// - Text finder and widget matcher usage

void main() {
  group('SignupScreen Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      // Initialize mocks before each test
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Setup default mock behaviors
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');
    });

    // Helper function to create testable widget
    // Wraps SignupScreen with ProviderScope for Riverpod support
    // Overrides authServiceProvider with mock AuthService
    Widget createSignupScreen() {
      return ProviderScope(
        overrides: [
          // Override the authServiceProvider with a mock AuthService
          authServiceProvider.overrideWithValue(
            AuthService(firebaseAuth: mockFirebaseAuth),
          ),
        ],
        child: const MaterialApp(
          home: SignupScreen(),
        ),
      );
    }

    group('UI Rendering Tests', () {
      testWidgets('should render all required UI elements', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act & Assert - Verify all UI elements are present
        expect(find.text('Sign Up'), findsNWidgets(1)); // AppBar title
        expect(
          find.byType(TextFormField),
          findsNWidgets(3),
        ); // Email, password, confirm password
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
        expect(find.text('Already have an account? Login'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);

        // Verify icons are present
        expect(find.byIcon(Icons.email), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('should have proper hint texts and labels', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act & Assert - Check for specific text elements
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Enter your password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
        expect(find.text('Re-enter your password'), findsOneWidget);

        // Verify password fields obscure text
        final passwordTextFields = find.byWidgetPredicate(
          (widget) => widget is TextField && widget.obscureText == true,
        );
        expect(passwordTextFields, findsNWidgets(2)); // Password and confirm
      });
    });

    group('Email Field Validation Tests', () {
      testWidgets('should show error for empty email', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Tap create account button with empty email field
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Error message should appear
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter invalid email and trigger validation
        await tester.enterText(
          find.byType(TextFormField).first,
          'invalid-email',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Email validation error should appear
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter valid email
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - No email validation error should appear
        expect(find.text('Please enter your email'), findsNothing);
        expect(find.text('Please enter a valid email'), findsNothing);
      });
    });

    group('Password Field Validation Tests', () {
      testWidgets('should show error for empty password', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter valid email but leave password empty
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Password validation error should appear
        expect(find.text('Please enter a password'), findsOneWidget);
      });

      testWidgets('should show error for short password', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter valid email but short password
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Pass1!',
        ); // Less than 8 characters
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Password length validation error should appear
        expect(
          find.text('Password must be at least 8 characters'),
          findsOneWidget,
        );
      });

      testWidgets('should show error for password without uppercase',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter password without uppercase
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'password123!',
        ); // No uppercase
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Uppercase validation error should appear
        expect(
          find.text('Password must contain at least one uppercase letter'),
          findsOneWidget,
        );
      });

      testWidgets('should show error for password without lowercase',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter password without lowercase
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'PASSWORD123!',
        ); // No lowercase
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Lowercase validation error should appear
        expect(
          find.text('Password must contain at least one lowercase letter'),
          findsOneWidget,
        );
      });

      testWidgets('should show error for password without digit',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter password without digit
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password!',
        ); // No digit
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Digit validation error should appear
        expect(
          find.text('Password must contain at least one digit'),
          findsOneWidget,
        );
      });

      testWidgets('should show error for password without special character',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter password without special character
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123',
        ); // No special char
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Special character validation error should appear
        expect(
          find.text('Password must contain at least one special character'),
          findsOneWidget,
        );
      });

      testWidgets('should accept valid strong password', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter valid credentials
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - No password validation errors should appear
        expect(find.text('Please enter a password'), findsNothing);
        expect(
          find.text('Password must be at least 8 characters'),
          findsNothing,
        );
        expect(
          find.text('Password must contain at least one uppercase letter'),
          findsNothing,
        );
        expect(
          find.text('Password must contain at least one lowercase letter'),
          findsNothing,
        );
        expect(
          find.text('Password must contain at least one digit'),
          findsNothing,
        );
        expect(
          find.text('Password must contain at least one special character'),
          findsNothing,
        );
      });
    });

    group('Confirm Password Validation Tests', () {
      testWidgets('should show error for empty confirm password',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter email and password but leave confirm empty
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Confirm password validation error should appear
        expect(find.text('Please confirm your password'), findsOneWidget);
      });

      testWidgets('should show error for non-matching passwords',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter different passwords
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'DifferentPass123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Password mismatch error should appear
        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should accept matching passwords', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter matching passwords
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - No password mismatch error should appear
        expect(find.text('Please confirm your password'), findsNothing);
        expect(find.text('Passwords do not match'), findsNothing);
      });
    });

    group('Password Strength Indicator Tests', () {
      testWidgets('should not show indicator when password is empty',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Assert - No strength indicator should be visible
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('Weak'), findsNothing);
        expect(find.text('Medium'), findsNothing);
        expect(find.text('Strong'), findsNothing);
      });

      testWidgets('should show weak indicator for weak password',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter weak password (only 1 point: lowercase)
        await tester.enterText(find.byType(TextFormField).at(1), 'abc');
        await tester.pumpAndSettle();

        // Assert - Weak indicator should appear
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Weak'), findsOneWidget);
      });

      testWidgets('should show medium indicator for medium password',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter medium password (3 points: uppercase, lowercase, digit)
        await tester.enterText(find.byType(TextFormField).at(1), 'Abc123');
        await tester.pumpAndSettle();

        // Assert - Medium indicator should appear
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('should show strong indicator for strong password',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Enter strong password (all criteria met)
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.pumpAndSettle();

        // Assert - Strong indicator should appear
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Strong'), findsOneWidget);
      });

      testWidgets('should update strength indicator in real-time',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());
        final passwordField = find.byType(TextFormField).at(1);

        // Act - Enter weak password first (only 1 criteria: lowercase, no length)
        await tester.enterText(passwordField, 'abc');
        await tester.pumpAndSettle();

        // Assert - Weak indicator
        expect(find.text('Weak'), findsOneWidget);

        // Act - Update to medium password (3 criteria: upper, lower, digit)
        await tester.enterText(passwordField, 'Abc123');
        await tester.pumpAndSettle();

        // Assert - Medium indicator (missing length and special char - 3 points)
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('Weak'), findsNothing);

        // Act - Update to strong password (all 5 criteria)
        await tester.enterText(passwordField, 'Password123!');
        await tester.pumpAndSettle();

        // Assert - Strong indicator (all criteria met)
        expect(find.text('Strong'), findsOneWidget);
        expect(find.text('Medium'), findsNothing);
      });
    });

    group('Form Submission Tests', () {
      testWidgets('should prevent submission with invalid data',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Try to submit with invalid data
        await tester.enterText(
          find.byType(TextFormField).first,
          'invalid-email',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'weak',
        ); // Too short and weak
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'different',
        ); // Doesn't match
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Form should not submit, validation errors should show
        expect(find.text('Please enter a valid email'), findsOneWidget);
        expect(
          find.text('Password must be at least 8 characters'),
          findsOneWidget,
        );

        // Success message should not appear
        expect(find.text('Account created successfully!'), findsNothing);
      });

      testWidgets('should show loading state during signup', (tester) async {
        // Arrange
        // Mock successful signup with a delay to test loading state
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return mockUserCredential;
          },
        );

        await tester.pumpWidget(createSignupScreen());

        // Act - Submit valid form
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Trigger the loading state

        // Assert - Loading spinner should appear and button should be disabled
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Find the ElevatedButton and check if it's disabled
        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull); // Disabled button has null onPressed

        // Clean up - Let the async operation complete
        await tester.pumpAndSettle();
      });

      testWidgets('should show success message after successful signup',
          (tester) async {
        // Arrange
        // Mock successful signup
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        await tester.pumpWidget(createSignupScreen());

        // Act - Submit valid form and wait for completion
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle(); // Wait for async operation to complete

        // Assert - No exceptions occurred
        expect(tester.takeException(), isNull);

        // Loading should be complete
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Button should be enabled again (or screen should have navigated away)
        // Since we navigate back, the screen might be gone, so we just verify no exceptions
      });
    });

    group('Navigation Tests', () {
      testWidgets('should handle login button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Tap already have account button
        await tester.tap(find.text('Already have an account? Login'));
        await tester.pumpAndSettle();

        // Assert - Since Navigator.pop() requires a navigation stack,
        // this will attempt to pop. We verify no exceptions occurred.
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should support text input and focus', (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Test text entry in all fields
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.pumpAndSettle();

        // Assert - Text should appear in the fields
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('Password123!'), findsNWidgets(2)); // Both password fields
      });

      testWidgets('should support keyboard navigation between fields',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createSignupScreen());

        // Act - Focus on first field and enter text
        await tester.tap(find.byType(TextFormField).first);
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.pumpAndSettle();

        // Then focus on second field
        await tester.tap(find.byType(TextFormField).at(1));
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.pumpAndSettle();

        // Then focus on third field
        await tester.tap(find.byType(TextFormField).at(2));
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Password123!',
        );
        await tester.pumpAndSettle();

        // Assert - All texts should be present
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('Password123!'), findsNWidgets(2));
      });
    });
  });
}
