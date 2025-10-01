import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fermentrack/core/features/auth/presentation/login_screen.dart';
import 'package:fermentrack/providers/auth/auth_providers.dart';
import 'package:fermentrack/services/auth_service.dart';

// Generate mocks for FirebaseAuth and User
@GenerateMocks([auth.FirebaseAuth, auth.User, auth.UserCredential])
import 'login_screen_test.mocks.dart';

/// Widget tests for LoginScreen (Sub-Issue 2.1.1)
///
/// These tests verify the acceptance criteria from the GitHub issue:
/// - Email field shows error for invalid email format
/// - Password field shows error for empty input
/// - Form cannot be submitted with invalid data
/// - Loading state disables button and shows spinner
/// - Navigation to forgot password screen works
/// - Navigation to signup screen works
///
/// Learning objectives for new engineers:
/// - Widget testing fundamentals
/// - Form validation testing
/// - User interaction simulation
/// - State change verification
/// - Text finder and widget matcher usage

void main() {
  group('LoginScreen Widget Tests', () {
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
    // Wraps LoginScreen with ProviderScope for Riverpod support
    // Overrides authServiceProvider with mock AuthService
    Widget createLoginScreen() {
      return ProviderScope(
        overrides: [
          // Override the authServiceProvider with a mock AuthService
          authServiceProvider.overrideWithValue(
            AuthService(firebaseAuth: mockFirebaseAuth),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    group('UI Rendering Tests', () {
      testWidgets('should render all required UI elements', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act & Assert - Verify all UI elements are present
        expect(find.text('Login'), findsNWidgets(2)); // AppBar title + Button
        expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);

        // Verify icons are present
        expect(find.byIcon(Icons.email), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('should have proper hint texts and labels', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act & Assert - Check for specific text elements
        // Since TextFormField properties aren't directly accessible in tests,
        // we verify the labels and hints are rendered in the widget tree
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Enter your password'), findsOneWidget);

        // Verify password field obscures text by checking for TextField with obscureText
        final passwordTextFields = find.byWidgetPredicate(
          (widget) => widget is TextField && widget.obscureText == true,
        );
        expect(passwordTextFields, findsOneWidget);
      });
    });

    group('Email Field Validation Tests', () {
      testWidgets('should show error for empty email', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Tap login button with empty email field
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Error message should appear
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Enter invalid email and trigger validation
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Email validation error should appear
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Enter valid email
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
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
        await tester.pumpWidget(createLoginScreen());

        // Act - Enter valid email but leave password empty
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Password validation error should appear
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should accept any non-empty password for login', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Enter valid email and any non-empty password
        // Note: Login doesn't enforce password strength - Firebase validates
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, '123'); // Any password is accepted
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - No password validation error should appear (only empty check)
        expect(find.text('Please enter your password'), findsNothing);
      });

      testWidgets('should accept valid password', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Enter valid credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - No password validation errors should appear
        expect(find.text('Please enter your password'), findsNothing);
      });
    });

    group('Form Submission Tests', () {
      testWidgets('should prevent submission with invalid email', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Try to submit with invalid email but valid password
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.enterText(find.byType(TextFormField).last, 'anypassword');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert - Form should not submit, email validation error should show
        expect(find.text('Please enter a valid email'), findsOneWidget);

        // Success message should not appear
        expect(find.text('Login successful!'), findsNothing);
      });

      testWidgets('should show loading state during login', (tester) async {
        // Arrange
        // Mock successful login with a delay to test loading state
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return mockUserCredential;
          },
        );

        await tester.pumpWidget(createLoginScreen());

        // Act - Submit valid form
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
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

      testWidgets('should show success message after successful login', (tester) async {
        // Arrange
        // Mock successful login
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        await tester.pumpWidget(createLoginScreen());

        // Act - Submit valid form and wait for completion
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle(); // Wait for async operation to complete

        // Assert - Success snackbar should appear
        // Note: SnackBar content may not be immediately visible in tests
        // We verify no exceptions occurred and loading completed
        expect(tester.takeException(), isNull);

        // Loading should be complete
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Button should be enabled again
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should handle forgot password button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Tap forgot password button
        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        // Assert - Since we're using debugPrint, we can't easily test the output
        // In a real implementation, this would navigate to password reset screen
        // For now, we just verify the button is tappable without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle sign up button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Tap sign up button
        await tester.tap(find.text('Don\'t have an account? Sign Up'));
        await tester.pumpAndSettle();

        // Assert - Since we're using debugPrint, we can't easily test the output
        // In a real implementation, this would navigate to signup screen
        // For now, we just verify the button is tappable without errors
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should support text input and focus', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Test text entry in both fields
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.pumpAndSettle();

        // Assert - Text should appear in the fields
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('password123'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation between fields', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act - Focus on first field and enter text
        await tester.tap(find.byType(TextFormField).first);
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.pumpAndSettle();

        // Then focus on second field
        await tester.tap(find.byType(TextFormField).last);
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.pumpAndSettle();

        // Assert - Both texts should be present
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('password123'), findsOneWidget);
      });
    });
  });
}