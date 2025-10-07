import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fermentrack/services/auth_service.dart';

// Generate mocks for the following classes
@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
import 'auth_service_google_test.mocks.dart';

/// Unit tests for Google Sign-In functionality in AuthService
///
/// This test suite demonstrates:
/// - Mocking third-party dependencies (Google Sign-In, Firebase Auth)
/// - Testing OAuth authentication flow
/// - Testing user cancellation scenarios
/// - Testing error handling for various Firebase errors
/// - Following TDD principles with comprehensive test coverage
///
/// Part of Sub-Issue 2.1.6: Implement Google Sign-In Authentication
/// Learning objectives: Unit testing, mocking, OAuth flow, error handling
void main() {
  group('AuthService - Google Sign-In', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late AuthService authService;

    setUp(() {
      // Initialize mocks before each test
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );
    });

    test('successful Google Sign-In returns User', () async {
      // Arrange - Set up mock behavior for successful sign-in
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      // Mock Google Sign-In flow
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');

      // Mock Firebase authentication
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');

      // Act - Perform Google Sign-In
      final result = await authService.signInWithGoogle();

      // Assert - Verify the result and method calls
      expect(result, equals(mockUser));
      expect(result?.uid, equals('test_uid'));

      // Verify Google Sign-In was called
      verify(mockGoogleSignIn.signIn()).called(1);

      // Verify authentication tokens were requested
      verify(mockGoogleUser.authentication).called(1);

      // Verify Firebase credential sign-in was called
      verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
    });

    test('Google Sign-In returns null when user cancels', () async {
      // Arrange - Mock user cancellation (signIn returns null)
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act - Attempt Google Sign-In
      final result = await authService.signInWithGoogle();

      // Assert - Verify null is returned (not an error)
      expect(result, isNull);

      // Verify sign-in was attempted
      verify(mockGoogleSignIn.signIn()).called(1);

      // Verify Firebase sign-in was never called (user cancelled before that)
      verifyNever(mockFirebaseAuth.signInWithCredential(any));
    });

    test('Google Sign-In throws AuthException when user is null', () async {
      // Arrange - Mock successful Google sign-in but null Firebase user
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);
      // UserCredential.user is null (edge case)
      when(mockUserCredential.user).thenReturn(null);

      // Act & Assert - Verify AuthException is thrown
      expect(
        () => authService.signInWithGoogle(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Google Sign-In failed'),
          ),
        ),
      );
    });

    test('Google Sign-In throws AuthException on invalid-credential error',
        () async {
      // Arrange - Mock Firebase error: invalid credential
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      // Act & Assert - Verify AuthException is thrown with appropriate message
      expect(
        () => authService.signInWithGoogle(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('credential received from Google is invalid'),
          ),
        ),
      );
    });

    test(
        'Google Sign-In throws AuthException on '
        'account-exists-with-different-credential error', () async {
      // Arrange - Mock Firebase error: account exists with different provider
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
        FirebaseAuthException(
          code: 'account-exists-with-different-credential',
        ),
      );

      // Act & Assert - Verify AuthException with helpful message
      expect(
        () => authService.signInWithGoogle(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('account already exists with the same email address'),
          ),
        ),
      );
    });

    test('Google Sign-In throws AuthException on operation-not-allowed error',
        () async {
      // Arrange - Mock Firebase error: Google Sign-In not enabled
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
        FirebaseAuthException(code: 'operation-not-allowed'),
      );

      // Act & Assert - Verify appropriate error message
      expect(
        () => authService.signInWithGoogle(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Google Sign-In is not enabled'),
          ),
        ),
      );
    });

    test('Google Sign-In throws AuthException on user-disabled error',
        () async {
      // Arrange - Mock Firebase error: user account disabled
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
        FirebaseAuthException(code: 'user-disabled'),
      );

      // Act & Assert - Verify appropriate error message
      expect(
        () => authService.signInWithGoogle(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('account has been disabled'),
          ),
        ),
      );
    });

    test('Google Sign-In throws AuthException on unexpected error', () async {
      // Arrange - Mock unexpected error during Google Sign-In
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenThrow(Exception('Unexpected error'));

      // Act & Assert - Verify generic error message
      expect(
        () => authService.signInWithGoogle(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('unexpected error occurred during Google Sign-In'),
          ),
        ),
      );
    });

    test('Google Sign-In handles network-request-failed error', () async {
      // Arrange - Mock network error
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleUser.email).thenReturn('test@example.com');
      when(mockGoogleAuth.accessToken).thenReturn('test_access_token');
      when(mockGoogleAuth.idToken).thenReturn('test_id_token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      // Act & Assert - Verify network error is handled
      expect(
        () => authService.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
