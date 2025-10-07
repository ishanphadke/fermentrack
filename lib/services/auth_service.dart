import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// AuthService - Firebase Authentication Service
///
/// This service class handles all Firebase Authentication operations for the Fermentrack app.
/// It's designed as a training exercise for intermediate Flutter developers to learn:
///
/// Key Learning Concepts:
/// - Firebase Authentication integration
/// - Async/await patterns in Dart
/// - Error handling with try-catch blocks
/// - Service layer architecture patterns
/// - Logging for debugging purposes
///
/// Architecture Notes:
/// - This service acts as the data layer for authentication
/// - It abstracts Firebase Auth complexity from the UI
/// - Returns custom error messages for better UX
/// - Uses dependency injection patterns for testability
///
/// The service follows the Repository pattern where:
/// - UI layer -> AuthService -> Firebase Auth
/// - Business logic is separated from data access
/// - Easier to test and mock for unit tests
class AuthService {
  /// Constructor with optional dependency injection
  ///
  /// This constructor pattern enables:
  /// - Production use: AuthService() uses FirebaseAuth.instance
  /// - Testing use: AuthService(firebaseAuth: mockAuth) uses mocked auth
  ///
  /// This is a key pattern for testable code in Flutter:
  /// - Dependency injection makes code more modular
  /// - Makes unit testing possible without real Firebase calls
  /// - Follows SOLID principles (Dependency Inversion)
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Current authenticated user
  /// This getter provides easy access to the current user
  /// Returns null if no user is authenticated
  User? get currentUser => _firebaseAuth.currentUser;

  /// Authentication state stream
  /// This stream emits whenever the auth state changes:
  /// - User signs in: emits User object
  /// - User signs out: emits null
  /// - User session expires: emits null
  ///
  /// Perfect for reactive UI updates using StreamBuilder or Riverpod
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  ///
  /// This method demonstrates:
  /// - Async/await for handling Firebase operations
  /// - Try-catch for error handling
  /// - Custom exception handling for specific Firebase errors
  /// - Input validation (basic)
  /// - Logging for debugging
  ///
  /// Parameters:
  /// - [email]: User's email address (must be valid email format)
  /// - [password]: User's password (must meet Firebase requirements)
  ///
  /// Returns:
  /// - [User] object on successful authentication
  ///
  /// Throws:
  /// - [AuthException] with user-friendly error messages
  ///
  /// Common Firebase Auth Error Codes:
  /// - 'user-not-found': No user record with this email
  /// - 'wrong-password': Incorrect password
  /// - 'invalid-email': Email format is invalid
  /// - 'user-disabled': User account has been disabled
  /// - 'too-many-requests': Too many failed login attempts
  Future<User> signInWithEmail(String email, String password) async {
    try {
      // Input validation
      if (email.isEmpty) {
        throw const AuthException('Email cannot be empty');
      }
      if (password.isEmpty) {
        throw const AuthException('Password cannot be empty');
      }

      debugPrint('AuthService: Attempting to sign in user with email: $email');

      // Attempt Firebase authentication
      // This method returns a UserCredential which contains the User object
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email.trim(), // Remove whitespace
            password: password,
          );

      // Extract the User object from the credential
      final User? user = userCredential.user;

      // Defensive programming: ensure user is not null
      if (user == null) {
        debugPrint('AuthService: Sign in failed - user is null');
        throw const AuthException('Authentication failed. Please try again.');
      }

      debugPrint('AuthService: Sign in successful for user: ${user.uid}');
      return user;
    } on AuthException catch (e) {
      // Re-throw AuthException as-is (from input validation)
      debugPrint('AuthService: Validation error during sign in: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      debugPrint(
        'AuthService: Firebase Auth Exception - Code: ${e.code}, Message: ${e.message}',
      );

      // Convert Firebase error codes to user-friendly messages
      final String errorMessage = _handleFirebaseAuthError(e);
      throw AuthException(errorMessage);
    } catch (e) {
      // Handle any other unexpected errors
      debugPrint('AuthService: Unexpected error during sign in: $e');
      throw const AuthException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign up with email and password
  ///
  /// This method creates a new user account with Firebase Auth.
  /// It demonstrates the same patterns as signIn but for account creation.
  ///
  /// Learning Points:
  /// - Account creation vs authentication
  /// - Different error handling for signup vs signin
  /// - Password strength validation by Firebase
  /// - Email verification patterns (can be extended)
  ///
  /// Parameters:
  /// - [email]: User's email address (must be unique and valid)
  /// - [password]: User's password (Firebase enforces minimum 6 characters)
  ///
  /// Returns:
  /// - [User] object for the newly created account
  ///
  /// Throws:
  /// - [AuthException] with user-friendly error messages
  ///
  /// Common Firebase Auth Error Codes for Signup:
  /// - 'email-already-in-use': Account with this email already exists
  /// - 'weak-password': Password doesn't meet strength requirements
  /// - 'invalid-email': Email format is invalid
  /// - 'operation-not-allowed': Email/password auth is disabled
  Future<User> signUpWithEmail(String email, String password) async {
    try {
      // Input validation
      if (email.isEmpty) {
        throw const AuthException('Email cannot be empty');
      }
      if (password.isEmpty) {
        throw const AuthException('Password cannot be empty');
      }
      if (password.length < 6) {
        throw const AuthException(
          'Password must be at least 6 characters long',
        );
      }

      debugPrint('AuthService: Attempting to create account for email: $email');

      // Create new user account with Firebase
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? user = userCredential.user;

      if (user == null) {
        debugPrint('AuthService: Account creation failed - user is null');
        throw const AuthException('Account creation failed. Please try again.');
      }

      debugPrint(
        'AuthService: Account created successfully for user: ${user.uid}',
      );

      // Optional: Send email verification
      // await user.sendEmailVerification();
      // debugPrint('AuthService: Verification email sent to: ${user.email}');

      return user;
    } on AuthException catch (e) {
      // Re-throw AuthException as-is (from input validation)
      debugPrint('AuthService: Validation error during signup: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during signup - Code: ${e.code}, Message: ${e.message}',
      );

      final String errorMessage = _handleFirebaseAuthError(e);
      throw AuthException(errorMessage);
    } catch (e) {
      debugPrint('AuthService: Unexpected error during signup: $e');
      throw const AuthException(
        'An unexpected error occurred during account creation.',
      );
    }
  }

  /// Sign out the current user
  ///
  /// This method signs out the currently authenticated user.
  /// It's simpler than sign in/up but demonstrates:
  /// - State management (clearing auth state)
  /// - Error handling for network issues
  /// - Logging for debugging
  ///
  /// After successful sign out:
  /// - currentUser becomes null
  /// - authStateChanges stream emits null
  /// - All auth-related UI should update automatically
  ///
  /// Throws:
  /// - [AuthException] if sign out fails
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Attempting to sign out current user');

      await _firebaseAuth.signOut();

      debugPrint('AuthService: Sign out successful');
    } catch (e) {
      debugPrint('AuthService: Error during sign out: $e');
      throw const AuthException('Failed to sign out. Please try again.');
    }
  }

  /// Send password reset email
  ///
  /// This method sends a password reset email to the specified address.
  /// It demonstrates:
  /// - Firebase Auth password reset functionality
  /// - Email validation
  /// - Error handling for various scenarios
  /// - User feedback patterns
  ///
  /// The reset email contains a link that allows users to:
  /// - Verify their identity
  /// - Set a new password
  /// - Return to the app
  ///
  /// Parameters:
  /// - [email]: Email address to send reset link to
  ///
  /// Throws:
  /// - [AuthException] with user-friendly error messages
  ///
  /// Common scenarios:
  /// - Email not found: Still shows success (security best practice)
  /// - Invalid email format: Shows validation error
  /// - Network issues: Shows network error
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Input validation
      if (email.isEmpty) {
        throw const AuthException('Email cannot be empty');
      }

      // Basic email format validation
      if (!email.contains('@') || !email.contains('.')) {
        throw const AuthException('Please enter a valid email address');
      }

      debugPrint('AuthService: Sending password reset email to: $email');

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      debugPrint('AuthService: Password reset email sent successfully');
    } on AuthException catch (e) {
      // Re-throw AuthException as-is (from input validation)
      debugPrint('AuthService: Validation error during password reset: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during password reset - Code: ${e.code}',
      );

      // For security reasons, we don't want to reveal if an email exists or not
      // So we handle most errors the same way
      switch (e.code) {
        case 'invalid-email':
          throw const AuthException('Please enter a valid email address');
        case 'user-not-found':
          // Security: Don't reveal that user doesn't exist
          // The email will simply not be delivered
          debugPrint(
            'AuthService: User not found, but showing success message',
          );
          break;
        default:
          throw const AuthException(
            'Failed to send reset email. Please try again.',
          );
      }
    } catch (e) {
      debugPrint('AuthService: Unexpected error during password reset: $e');
      throw const AuthException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign in with Google
  ///
  /// This method demonstrates:
  /// - Third-party OAuth authentication flow
  /// - Google Sign-In SDK integration
  /// - Linking Google credentials with Firebase Auth
  /// - Handling user cancellation
  /// - Error handling for OAuth flow
  ///
  /// Flow:
  /// 1. Trigger Google Sign-In picker
  /// 2. User selects Google account
  /// 3. Get authentication tokens from Google
  /// 4. Create Firebase credential from Google tokens
  /// 5. Sign in to Firebase with the credential
  ///
  /// Returns:
  /// - [User] object on successful authentication
  /// - null if user cancels the sign-in
  ///
  /// Throws:
  /// - [AuthException] with user-friendly error messages
  ///
  /// Common scenarios:
  /// - User cancels: Returns null (not an error)
  /// - Network issues: Throws AuthException
  /// - Account already exists: Links accounts or throws error
  /// - Email already in use with password: Throws AuthException
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('AuthService: Initiating Google Sign-In');

      // Step 1: Trigger Google Sign-In flow
      // This shows the Google account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Step 2: Handle user cancellation
      // If user dismisses the picker, googleUser will be null
      if (googleUser == null) {
        debugPrint('AuthService: Google Sign-In cancelled by user');
        return null; // User cancelled, not an error
      }

      debugPrint('AuthService: Google account selected: ${googleUser.email}');

      // Step 3: Obtain Google authentication tokens
      // This gets the access token and ID token needed for Firebase
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 4: Create Firebase credential from Google tokens
      // This credential will be used to authenticate with Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('AuthService: Signing in to Firebase with Google credential');

      // Step 5: Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        debugPrint('AuthService: Google Sign-In failed - user is null');
        throw const AuthException('Google Sign-In failed. Please try again.');
      }

      debugPrint(
        'AuthService: Google Sign-In successful for user: ${user.uid}',
      );
      return user;
    } on AuthException catch (e) {
      debugPrint('AuthService: Validation error during Google Sign-In: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during Google Sign-In - '
        'Code: ${e.code}, Message: ${e.message}',
      );

      // Handle specific Google Sign-In related errors
      switch (e.code) {
        case 'popup-closed-by-user':
        case 'popup_closed':
          // User closed the popup - this is not an error, just cancelled
          debugPrint('AuthService: Google Sign-In popup closed by user');
          return null;
        case 'account-exists-with-different-credential':
          throw const AuthException(
            'An account already exists with the same email address but different sign-in credentials. '
            'Please sign in using a provider associated with this email address.',
          );
        case 'invalid-credential':
          throw const AuthException(
            'The credential received from Google is invalid. Please try again.',
          );
        case 'operation-not-allowed':
          throw const AuthException(
            'Google Sign-In is not enabled. Please contact support.',
          );
        case 'user-disabled':
          throw const AuthException(
            'This account has been disabled. Please contact support.',
          );
        case 'user-not-found':
          throw const AuthException('No account found. Please sign up first.');
        case 'wrong-password':
          throw const AuthException('Invalid credentials. Please try again.');
        default:
          throw AuthException(_handleFirebaseAuthError(e));
      }
    } catch (e, stackTrace) {
      // Check if this is a popup_closed error from PlatformException
      if (e.toString().contains('popup_closed')) {
        debugPrint(
          'AuthService: Detected popup_closed error - treating as cancellation',
        );
        return null;
      }
      debugPrint('AuthService: Unexpected error during Google Sign-In: $e');
      throw const AuthException(
        'An unexpected error occurred during Google Sign-In. Please try again.',
      );
    }
  }

  /// Convert Firebase Auth error codes to user-friendly messages
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
  /// - [e]: FirebaseAuthException to convert
  ///
  /// Returns:
  /// - User-friendly error message string
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      // Sign In Errors
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';

      // Sign Up Errors
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email authentication is not enabled. Please contact support.';

      // Network and General Errors
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';

      // Default case for unknown errors
      default:
        debugPrint(
          'AuthService: Unhandled Firebase Auth error code: ${e.code}',
        );
        return 'Authentication failed. Please try again.';
    }
  }
}

/// Custom exception class for authentication errors
///
/// This class provides a consistent way to handle authentication errors
/// throughout the app. It demonstrates:
/// - Custom exception creation
/// - Error message encapsulation
/// - Type safety for error handling
///
/// Benefits:
/// - Clear separation between auth errors and other errors
/// - Consistent error handling patterns
/// - Easy to catch and handle specifically
///
/// Usage:
/// ```dart
/// try {
///   await authService.signIn(email, password);
/// } on AuthException catch (e) {
///   // Handle auth-specific errors
///   showErrorMessage(e.message);
/// } catch (e) {
///   // Handle other errors
///   showGenericError();
/// }
/// ```
class AuthException implements Exception {
  /// The user-friendly error message
  final String message;

  /// Create an AuthException with a message
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
