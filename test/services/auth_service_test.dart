import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fermentrack/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

/// Comprehensive unit tests for AuthService using Mockito
///
/// This test file demonstrates modern Firebase Auth testing patterns for 2024:
///
/// Key Testing Concepts Covered:
/// - Firebase Auth mocking with Mockito package
/// - Dependency injection testing patterns
/// - Comprehensive error scenario testing
/// - Mock Firebase initialization for tests
/// - Testing both success and failure cases
/// - FirebaseAuthException handling verification
///
/// Testing Strategy for Security Validation:
/// - Mock Firebase Auth to avoid real network calls
/// - Test authentication success flows
/// - Test all possible error scenarios and exception codes
/// - Verify input validation and sanitization
/// - Test edge cases and boundary conditions
/// - Ensure proper error message handling for user security
///
/// Learning Objectives for New Developers:
/// - How to use Mockito for Firebase Auth testing
/// - Best practices for testing authentication flows
/// - Understanding Firebase Auth error codes
/// - Testing service layer architecture
/// - Security-focused testing approaches

// Generate mocks for Firebase Auth classes using Mockito code generation
@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  /// Initialize Firebase mocking for all tests
  /// This prevents Firebase from trying to connect to real services
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Test organization: group related tests together
  /// This makes test output more readable and helps organize test cases logically
  group('AuthService Tests', () {
    /// Test variables - declared here so they can be used across test methods
    /// We'll initialize these in setUp() for each test
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    /// setUp() runs before each individual test
    /// This ensures each test starts with a clean state
    /// It's a best practice to reset mocks between tests
    setUp(() {
      // Create mock instances
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Configure default mock user properties
      when(mockUser.uid).thenReturn('test-uid-123');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.emailVerified).thenReturn(true);

      // Configure default mock user credential
      when(mockUserCredential.user).thenReturn(mockUser);

      // Configure default mock Firebase Auth
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(
        mockFirebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));

      // Create AuthService instance with dependency injection
      // This is the key to testable code - injecting the mock
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    /// tearDown() runs after each individual test
    /// Clean up any resources if needed
    tearDown(() {
      // Reset all mocks to clean state
      reset(mockFirebaseAuth);
      reset(mockUser);
      reset(mockUserCredential);
    });

    /// Testing Group: Sign In with Email functionality
    /// This group tests all scenarios related to user sign in
    group('signInWithEmail', () {
      test('should return User when credentials are valid', () async {
        // ARRANGE: Set up the test conditions
        const String testEmail = 'test@example.com';
        const String testPassword = 'password123';

        // Configure mock to return successful sign in
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // ACT: Call the method we're testing
        final User result = await authService.signInWithEmail(
          testEmail,
          testPassword,
        );

        // ASSERT: Verify the results
        expect(result, isNotNull);
        expect(result.uid, equals('test-uid-123'));
        expect(result.email, equals('test@example.com'));
        expect(result.displayName, equals('Test User'));

        // Verify the mock was called with correct parameters
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: testEmail.trim(),
            password: testPassword,
          ),
        ).called(1);
      });

      test('should throw AuthException when email is empty', () async {
        // ARRANGE
        const String emptyEmail = '';
        const String validPassword = 'password123';

        // ACT & ASSERT
        expect(
          () async =>
              await authService.signInWithEmail(emptyEmail, validPassword),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Email cannot be empty',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      test('should throw AuthException when password is empty', () async {
        // ARRANGE
        const String validEmail = 'test@example.com';
        const String emptyPassword = '';

        // ACT & ASSERT
        expect(
          () async =>
              await authService.signInWithEmail(validEmail, emptyPassword),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Password cannot be empty',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      test('should trim whitespace from email', () async {
        // ARRANGE
        const String emailWithSpaces = '  test@example.com  ';
        const String password = 'password123';

        // Configure mock to return successful sign in
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // ACT: Call the method with email containing spaces
        final User result = await authService.signInWithEmail(
          emailWithSpaces,
          password,
        );

        // ASSERT: Verify that the email was trimmed and sign in succeeded
        expect(result, isNotNull);
        expect(result.email, equals('test@example.com')); // Should be trimmed

        // Verify the mock was called with trimmed email
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: emailWithSpaces.trim(),
            password: password,
          ),
        ).called(1);
      });

      /// Testing Firebase Auth Exception Handling
      /// These tests verify that Firebase error codes are properly converted
      /// to user-friendly messages for security validation
      group('Firebase Auth Error Handling', () {
        test('should handle user-not-found error', () async {
          // ARRANGE: Set up a mock that throws user-not-found error
          const String testEmail = 'nonexistent@example.com';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message:
                  'There is no user record corresponding to this identifier.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signInWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'No account found with this email address.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test('should handle wrong-password error', () async {
          // ARRANGE: Set up a mock that throws wrong-password error
          const String testEmail = 'test@example.com';
          const String testPassword = 'wrongpassword';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'wrong-password',
              message:
                  'The password is invalid or the user does not have a password.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signInWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Incorrect password. Please try again.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test('should handle invalid-email error', () async {
          // ARRANGE
          const String testEmail = 'invalid-email';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'invalid-email',
              message: 'The email address is badly formatted.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signInWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Please enter a valid email address.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test('should handle user-disabled error', () async {
          // ARRANGE
          const String testEmail = 'disabled@example.com';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'user-disabled',
              message:
                  'The user account has been disabled by an administrator.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signInWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) =>
                    e.message ==
                    'This account has been disabled. Please contact support.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test('should handle too-many-requests error', () async {
          // ARRANGE
          const String testEmail = 'test@example.com';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'too-many-requests',
              message: 'Too many unsuccessful login attempts.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signInWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) =>
                    e.message ==
                    'Too many failed attempts. Please try again later.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test(
          'should handle unknown error codes with default message',
          () async {
            // ARRANGE
            const String testEmail = 'test@example.com';
            const String testPassword = 'password123';

            when(
              mockFirebaseAuth.signInWithEmailAndPassword(
                email: anyNamed('email'),
                password: anyNamed('password'),
              ),
            ).thenThrow(
              FirebaseAuthException(
                code: 'unknown-error-code',
                message: 'Some unknown error occurred.',
              ),
            );

            // ACT & ASSERT
            expect(
              () async =>
                  await authService.signInWithEmail(testEmail, testPassword),
              throwsA(
                predicate<AuthException>(
                  (e) =>
                      e.message == 'Authentication failed. Please try again.',
                ),
              ),
            );

            // Verify the mock was called
            verify(
              mockFirebaseAuth.signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              ),
            ).called(1);
          },
        );

        test('should handle unexpected exceptions', () async {
          // ARRANGE
          const String testEmail = 'test@example.com';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(Exception('Network error'));

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signInWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) =>
                    e.message ==
                    'An unexpected error occurred. Please try again.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });
      });
    });

    /// Testing Group: Sign Up with Email functionality
    /// This group tests user account creation scenarios
    group('signUpWithEmail', () {
      test('should return User when account creation succeeds', () async {
        // ARRANGE
        const String newEmail = 'newuser@example.com';
        const String validPassword = 'password123';

        // Create a new mock user for signup
        final newMockUser = MockUser();
        when(newMockUser.uid).thenReturn('new-user-uid');
        when(newMockUser.email).thenReturn(newEmail);
        when(newMockUser.displayName).thenReturn(null);
        when(newMockUser.emailVerified).thenReturn(false);

        final newMockUserCredential = MockUserCredential();
        when(newMockUserCredential.user).thenReturn(newMockUser);

        // Configure mock to return successful signup
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => newMockUserCredential);

        // ACT
        final User result = await authService.signUpWithEmail(
          newEmail,
          validPassword,
        );

        // ASSERT
        expect(result, isNotNull);
        expect(result.uid, equals('new-user-uid'));
        expect(result.email, equals(newEmail));

        // Verify the mock was called with correct parameters
        verify(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: newEmail.trim(),
            password: validPassword,
          ),
        ).called(1);
      });

      test('should validate password length', () async {
        // ARRANGE
        const String validEmail = 'test@example.com';
        const String shortPassword = '12345'; // Less than 6 characters

        // ACT & ASSERT
        expect(
          () async =>
              await authService.signUpWithEmail(validEmail, shortPassword),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Password must be at least 6 characters long',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      test('should throw AuthException when email is empty', () async {
        // ARRANGE
        const String emptyEmail = '';
        const String validPassword = 'password123';

        // ACT & ASSERT
        expect(
          () async =>
              await authService.signUpWithEmail(emptyEmail, validPassword),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Email cannot be empty',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      test('should throw AuthException when password is empty', () async {
        // ARRANGE
        const String validEmail = 'test@example.com';
        const String emptyPassword = '';

        // ACT & ASSERT
        expect(
          () async =>
              await authService.signUpWithEmail(validEmail, emptyPassword),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Password cannot be empty',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      /// Testing Firebase Auth Exception Handling for Sign Up
      group('Sign Up Error Handling', () {
        test('should handle email-already-in-use error', () async {
          // ARRANGE
          const String testEmail = 'existing@example.com';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'The account already exists for that email.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signUpWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) =>
                    e.message == 'An account with this email already exists.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test('should handle weak-password error', () async {
          // ARRANGE
          const String testEmail = 'test@example.com';
          const String testPassword =
              'weakpw'; // 6 characters, passes client validation

          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'weak-password',
              message: 'The password provided is too weak.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signUpWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) =>
                    e.message ==
                    'Password is too weak. Please choose a stronger password.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });

        test('should handle operation-not-allowed error', () async {
          // ARRANGE
          const String testEmail = 'test@example.com';
          const String testPassword = 'password123';

          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'operation-not-allowed',
              message: 'Email/password accounts are not enabled.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async =>
                await authService.signUpWithEmail(testEmail, testPassword),
            throwsA(
              predicate<AuthException>(
                (e) =>
                    e.message ==
                    'Email authentication is not enabled. Please contact support.',
              ),
            ),
          );

          // Verify the mock was called
          verify(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        });
      });
    });

    /// Testing Group: Sign Out functionality
    /// This group tests user sign out scenarios
    group('signOut', () {
      test('should complete successfully when user is signed in', () async {
        // ARRANGE: Configure mock to succeed
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // ACT: Sign out the user
        await authService.signOut();

        // ASSERT: Verify sign out completed
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should complete successfully when no user is signed in', () async {
        // ARRANGE: Configure mock with no signed-in user
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // ACT & ASSERT: Should not throw even if no user is signed in
        await authService.signOut();

        // Verify sign out was still called
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should throw AuthException when sign out fails', () async {
        // ARRANGE: Set up mock to throw error on sign out
        when(
          mockFirebaseAuth.signOut(),
        ).thenThrow(Exception('Network error during sign out'));

        // ACT & ASSERT
        expect(
          () async => await authService.signOut(),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Failed to sign out. Please try again.',
            ),
          ),
        );

        // Verify the mock was called
        verify(mockFirebaseAuth.signOut()).called(1);
      });
    });

    /// Testing Group: Password Reset functionality
    /// This group tests password reset email scenarios
    group('sendPasswordResetEmail', () {
      test('should complete successfully with valid email', () async {
        // ARRANGE
        const String validEmail = 'test@example.com';

        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async {});

        // ACT
        await authService.sendPasswordResetEmail(validEmail);

        // ASSERT: Verify the mock was called
        verify(
          mockFirebaseAuth.sendPasswordResetEmail(email: validEmail.trim()),
        ).called(1);
      });

      test('should throw AuthException when email is empty', () async {
        // ARRANGE
        const String emptyEmail = '';

        // ACT & ASSERT
        expect(
          () async => await authService.sendPasswordResetEmail(emptyEmail),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Email cannot be empty',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        );
      });

      test('should validate email format', () async {
        // ARRANGE
        const String invalidEmail = 'not-an-email';

        // ACT & ASSERT
        expect(
          () async => await authService.sendPasswordResetEmail(invalidEmail),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Please enter a valid email address',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        );
      });

      test('should accept various valid email formats', () async {
        // ARRANGE: List of valid email formats to test
        final validEmails = [
          'user@domain.com',
          'user.name@domain.co.uk',
          'user+tag@domain.org',
          'user123@domain123.net',
        ];

        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async {});

        // ACT & ASSERT: All should complete without throwing
        for (String email in validEmails) {
          await authService.sendPasswordResetEmail(email);

          // Verify each call
          verify(
            mockFirebaseAuth.sendPasswordResetEmail(email: email.trim()),
          ).called(1);
        }
      });

      /// Testing Password Reset Error Handling
      group('Password Reset Error Handling', () {
        test('should handle invalid-email error', () async {
          // ARRANGE
          const String testEmail = 'invalid@';

          when(
            mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenThrow(
            FirebaseAuthException(
              code: 'invalid-email',
              message: 'The email address is badly formatted.',
            ),
          );

          // ACT & ASSERT
          expect(
            () async => await authService.sendPasswordResetEmail(testEmail),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Please enter a valid email address',
              ),
            ),
          );

          // Verify the mock never called
          verifyNever(
            mockFirebaseAuth.sendPasswordResetEmail(email: testEmail.trim()),
          );
        });

        test('should handle user-not-found gracefully for security', () async {
          // ARRANGE: Mock user-not-found error
          const String testEmail = 'nonexistent@example.com';

          when(
            mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message:
                  'There is no user record corresponding to this identifier.',
            ),
          );

          // ACT: Should complete normally for security
          // We don't want to reveal if an email exists or not
          await authService.sendPasswordResetEmail(testEmail);

          // ASSERT: Verify the mock was called
          verify(
            mockFirebaseAuth.sendPasswordResetEmail(email: testEmail.trim()),
          ).called(1);
        });
      });
    });

    /// Testing Group: AuthService Properties and Getters
    /// This group tests the service's exposed properties
    group('AuthService Properties', () {
      test('should provide access to current user', () {
        // ARRANGE & ACT
        final User? currentUser = authService.currentUser;

        // ASSERT
        expect(currentUser, isA<User?>());
        expect(currentUser?.uid, equals('test-uid-123'));

        // Verify the mock was called
        verify(mockFirebaseAuth.currentUser);
      });

      test('should provide auth state changes stream', () {
        // ARRANGE & ACT
        final Stream<User?> authStateStream = authService.authStateChanges;

        // ASSERT
        expect(authStateStream, isA<Stream<User?>>());

        // Verify the mock was called
        verify(mockFirebaseAuth.authStateChanges());
      });

      test('should return null for current user when not signed in', () {
        // ARRANGE: Configure mock with no signed-in user
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // ACT
        final User? currentUser = authService.currentUser;

        // ASSERT
        expect(currentUser, isNull);

        // Verify the mock was called
        verify(mockFirebaseAuth.currentUser);
      });
    });

    /// Testing Group: AuthException Custom Exception
    /// This group tests our custom exception class
    group('AuthException', () {
      test('should create exception with message', () {
        // ARRANGE
        const String testMessage = 'Test error message';

        // ACT
        const AuthException exception = AuthException(testMessage);

        // ASSERT
        expect(exception.message, equals(testMessage));
        expect(exception.toString(), equals('AuthException: $testMessage'));
      });

      test('should be catchable as Exception', () {
        // ARRANGE
        const AuthException authException = AuthException('Test');

        // ACT & ASSERT
        expect(authException, isA<Exception>());
      });

      test('should be distinguishable from other exceptions', () {
        // ARRANGE
        const AuthException authException = AuthException('Auth error');
        final Exception genericException = Exception('Generic error');

        // ACT & ASSERT
        expect(authException, isA<AuthException>());
        expect(genericException, isNot(isA<AuthException>()));
      });
    });

    /// Testing Group: Edge Cases and Security Validation
    /// This group tests edge cases and security-focused scenarios
    group('Edge Cases and Security Validation', () {
      test('should handle extremely long email addresses', () async {
        // ARRANGE: Create an extremely long but valid email
        final longEmail = '${'a' * 240}@example.com'; // Near email length limit

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // ACT & ASSERT: Should handle gracefully
        final User result = await authService.signInWithEmail(
          longEmail,
          'password123',
        );

        expect(result, isNotNull);
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: longEmail.trim(),
            password: 'password123',
          ),
        ).called(1);
      });

      test('should handle extremely long passwords', () async {
        // ARRANGE: Create a very long password
        final longPassword = 'password' * 100; // 800 characters

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // ACT & ASSERT: Should handle gracefully
        final User result = await authService.signInWithEmail(
          'test@example.com',
          longPassword,
        );

        expect(result, isNotNull);
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: longPassword,
          ),
        ).called(1);
      });

      test('should handle special characters in email', () async {
        // ARRANGE: Email with special characters (valid in email spec)
        const String specialEmail = 'test+tag@example-domain.co.uk';

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // ACT & ASSERT: Should handle gracefully
        final User result = await authService.signInWithEmail(
          specialEmail,
          'password123',
        );

        expect(result, isNotNull);
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: specialEmail,
            password: 'password123',
          ),
        ).called(1);
      });

      test('should handle unicode characters in password', () async {
        // ARRANGE: Password with unicode characters
        const String unicodePassword = 'pāssw0rd🔒';

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // ACT & ASSERT: Should handle gracefully
        final User result = await authService.signInWithEmail(
          'test@example.com',
          unicodePassword,
        );

        expect(result, isNotNull);
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: unicodePassword,
          ),
        ).called(1);
      });

      test(
        'should trim whitespace but preserve internal spaces in password',
        () async {
          // ARRANGE: Email with whitespace and password with internal spaces
          const String emailWithSpaces = '  test@example.com  ';
          const String passwordWithSpaces =
              'my password 123'; // Internal spaces should be preserved

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);

          // ACT: Should succeed (email trimmed, password preserved)
          final User result = await authService.signInWithEmail(
            emailWithSpaces,
            passwordWithSpaces,
          );

          // ASSERT
          expect(result, isNotNull);
          expect(result.email, equals('test@example.com')); // Trimmed

          // Verify password spaces are preserved
          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: emailWithSpaces.trim(),
              password: passwordWithSpaces, // Should NOT be trimmed
            ),
          ).called(1);
        },
      );

      test('should handle null and whitespace-only inputs', () async {
        // ARRANGE: Various whitespace scenarios
        const String whitespaceOnlyEmail = '   ';
        const String whitespaceOnlyPassword = '   ';

        // ACT & ASSERT: Should throw validation errors
        expect(
          () async => await authService.signInWithEmail(
            whitespaceOnlyEmail.trim(),
            'password123',
          ),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Email cannot be empty',
            ),
          ),
        );

        expect(
          () async => await authService.signInWithEmail(
            'test@example.com',
            whitespaceOnlyPassword.trim(),
          ),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Password cannot be empty',
            ),
          ),
        );

        // Verify Firebase Auth was never called due to validation
        verifyNever(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      });

      test('should validate minimum password length correctly', () async {
        // ARRANGE: Test various password lengths
        final passwordTests = [
          ('', 'Password cannot be empty'),
          ('a', 'Password must be at least 6 characters long'),
          ('ab', 'Password must be at least 6 characters long'),
          ('abc', 'Password must be at least 6 characters long'),
          ('abcd', 'Password must be at least 6 characters long'),
          ('abcde', 'Password must be at least 6 characters long'),
        ];

        // ACT & ASSERT: Test each password length
        for (final (password, expectedError) in passwordTests) {
          expect(
            () async =>
                await authService.signUpWithEmail('test@example.com', password),
            throwsA(
              predicate<AuthException>((e) => e.message == expectedError),
            ),
            reason: 'Password "$password" should throw error: $expectedError',
          );
        }

        // Test valid 6-character password
        const String validSixCharPassword = 'abcdef';
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        final User result = await authService.signUpWithEmail(
          'newuser@example.com',
          validSixCharPassword,
        );

        expect(result, isNotNull);
        verify(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'newuser@example.com',
            password: validSixCharPassword,
          ),
        ).called(1);
      });
    });

    /// Testing Group: Error Message Consistency
    /// This group ensures error messages are consistent and user-friendly
    group('Error Message Consistency', () {
      test(
        'should provide consistent error messages for empty inputs',
        () async {
          // Test empty email in sign in
          expect(
            () async => await authService.signInWithEmail('', 'password123'),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Email cannot be empty',
              ),
            ),
          );

          // Test empty email in sign up
          expect(
            () async => await authService.signUpWithEmail('', 'password123'),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Email cannot be empty',
              ),
            ),
          );

          // Test empty email in password reset
          expect(
            () async => await authService.sendPasswordResetEmail(''),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Email cannot be empty',
              ),
            ),
          );

          // Test empty password in sign in
          expect(
            () async =>
                await authService.signInWithEmail('test@example.com', ''),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Password cannot be empty',
              ),
            ),
          );

          // Test empty password in sign up
          expect(
            () async =>
                await authService.signUpWithEmail('test@example.com', ''),
            throwsA(
              predicate<AuthException>(
                (e) => e.message == 'Password cannot be empty',
              ),
            ),
          );
        },
      );

      test('should provide specific password validation messages', () async {
        // Test short password
        expect(
          () async =>
              await authService.signUpWithEmail('test@example.com', 'short'),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Password must be at least 6 characters long',
            ),
          ),
        );
      });

      test('should provide specific email validation messages', () async {
        // Test invalid email format in password reset
        expect(
          () async => await authService.sendPasswordResetEmail('invalid-email'),
          throwsA(
            predicate<AuthException>(
              (e) => e.message == 'Please enter a valid email address',
            ),
          ),
        );
      });
    });
  });

  /// Performance and Integration Test Examples
  /// These demonstrate patterns for more comprehensive testing
  group('AuthService Advanced Testing Patterns', () {
    test('demonstrates performance testing approach', () {
      // Performance tests would measure:
      // - Auth operation response times
      // - Memory usage during auth flows
      // - Concurrent authentication handling
      // - Network timeout scenarios

      expect(true, isTrue); // Placeholder for educational purposes
    });

    test('demonstrates stream testing patterns', () async {
      // Stream testing would verify:
      // - Authentication state change notifications
      // - Multiple subscribers handling
      // - Stream cancellation and cleanup
      // - Error propagation through streams

      final mockAuth = MockFirebaseAuth();
      when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));

      final authService = AuthService(firebaseAuth: mockAuth);
      final authStateStream = authService.authStateChanges;

      expect(authStateStream, isA<Stream<User?>>());
      verify(mockAuth.authStateChanges());
    });

    test('demonstrates concurrent operation testing', () async {
      // Concurrent testing would verify:
      // - Multiple simultaneous auth operations
      // - Race condition handling
      // - Resource cleanup under load
      // - Error isolation between operations

      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();

      when(mockUser.uid).thenReturn('concurrent-test-uid');
      when(mockUser.email).thenReturn('concurrent@example.com');
      when(mockUserCredential.user).thenReturn(mockUser);

      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final authService = AuthService(firebaseAuth: mockAuth);

      // Simulate multiple concurrent operations
      final futures = List.generate(5, (index) async {
        try {
          await authService.signInWithEmail(
            'test$index@example.com',
            'password123',
          );
          return true;
        } catch (e) {
          return false;
        }
      });

      final results = await Future.wait(futures);
      expect(results, everyElement(isTrue));

      // Verify all operations were called
      verify(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).called(5);
    });
  });
}

/// Test Data Constants
/// Centralizing test data makes tests more maintainable
class TestData {
  static const String validEmail = 'test@example.com';
  static const String validPassword = 'password123';
  static const String weakPassword = '123';
  static const String invalidEmail = 'not-an-email';
  static const String emptyString = '';
  static const String testUid = 'test-uid-123';

  // Edge case test data
  static const String longEmail =
      'very-long-email-address-for-testing-purposes@very-long-domain-name-example.com';
  static const String specialCharsEmail = 'test+tag@example-domain.co.uk';
  static const String unicodePassword = 'pāssw0rd🔒';
}

/// Custom Matchers for Better Test Readability
/// These make test assertions more expressive and readable

/// Matcher to check if an AuthException has a specific message
Matcher hasAuthExceptionMessage(String expectedMessage) {
  return predicate<AuthException>(
    (exception) => exception.message == expectedMessage,
    'AuthException with message "$expectedMessage"',
  );
}

/// Matcher to check if a Future throws an AuthException
Matcher throwsAuthException() {
  return throwsA(isA<AuthException>());
}

/// Matcher to check if a Future throws a specific AuthException message
Matcher throwsAuthExceptionWithMessage(String message) {
  return throwsA(hasAuthExceptionMessage(message));
}

/// Example usage of custom matchers in tests:
/// ```dart
/// expect(
///   () => authService.signIn('', 'password'),
///   throwsAuthException(),
/// );
///
/// expect(
///   () => authService.signIn('', 'password'),
///   throwsAuthExceptionWithMessage('Email cannot be empty'),
/// );
/// ```
