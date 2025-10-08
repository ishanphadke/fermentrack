import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// This part directive tells Riverpod's code generator where to place generated code
// The generated file will be: auth_providers.g.dart
part 'auth_providers.g.dart';

/// **AuthService Provider**
///
/// This provider exposes our AuthService as a Riverpod provider, making it
/// available throughout the widget tree without requiring manual dependency injection.
///
/// **Learning Points for New Developers:**
/// - **Provider Pattern**: This creates a singleton instance of AuthService
/// - **Dependency Injection**: Widgets can access AuthService via `ref.read(authServiceProvider)`
/// - **Testability**: Easy to override this provider in tests with mock implementations
/// - **Code Generation**: @riverpod annotation generates boilerplate code for us
///
/// **Why we use this pattern:**
/// - Centralizes service creation
/// - Ensures consistent AuthService instance across the app
/// - Makes testing easier (can inject mock services)
/// - Follows dependency inversion principle
///
/// **Usage Example:**
/// ```dart
/// class LoginScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authService = ref.read(authServiceProvider);
///     // Use authService for login operations
///   }
/// }
/// ```
@riverpod
AuthService authService(Ref ref) {
  // Create and return AuthService instance
  // In production: uses FirebaseAuth.instance
  // In tests: can be overridden with mock implementation
  return AuthService();
}

/// **Authentication State Stream Provider**
///
/// This StreamProvider listens to Firebase Auth state changes and automatically
/// updates the UI when the user signs in, signs out, or their session expires.
///
/// **Learning Points for New Developers:**
/// - **StreamProvider**: Special Riverpod provider for reactive data streams
/// - **Reactive Programming**: UI automatically updates when auth state changes
/// - **Firebase Integration**: Connects to Firebase Auth's built-in state stream
/// - **Provider Dependencies**: This provider depends on authServiceProvider
///
/// **How it works:**
/// 1. Gets AuthService from authServiceProvider
/// 2. Returns the authStateChanges stream from Firebase Auth
/// 3. Riverpod automatically manages subscription/unsubscription
/// 4. UI widgets listening to this provider auto-rebuild on state changes
///
/// **State Values:**
/// - `AsyncData<User>`: User is signed in
/// - `AsyncData<null>`: User is signed out
/// - `AsyncLoading`: Authentication state is loading
/// - `AsyncError`: Error occurred during authentication
///
/// **Usage Example:**
/// ```dart
/// class HomePage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authState = ref.watch(authStateProvider);
///
///     return authState.when(
///       data: (user) => user != null
///         ? DashboardScreen(user: user)
///         : LoginScreen(),
///       loading: () => LoadingScreen(),
///       error: (error, stack) => ErrorScreen(error: error),
///     );
///   }
/// }
/// ```
@riverpod
Stream<User?> authState(Ref ref) {
  // Get AuthService instance from provider
  final authService = ref.watch(authServiceProvider);

  // Return the authentication state stream
  // This stream emits:
  // - User object when signed in
  // - null when signed out
  // - Updates in real-time when auth state changes
  return authService.authStateChanges;
}

/// **Current User Provider**
///
/// This provider gives synchronous access to the currently authenticated user.
/// It's a computed provider that derives its value from the auth state stream.
///
/// **Learning Points for New Developers:**
/// - **Computed Providers**: Derive state from other providers
/// - **Synchronous Access**: Get current user without dealing with streams
/// - **Provider Composition**: Building providers on top of other providers
/// - **Null Safety**: Returns nullable User? type
///
/// **When to use:**
/// - Quick user ID or email access
/// - Checking auth status without listening to changes
/// - Conditional UI logic based on user presence
///
/// **Usage Example:**
/// ```dart
/// class UserProfile extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final user = ref.watch(currentUserProvider);
///
///     if (user == null) {
///       return Text('Please sign in');
///     }
///
///     return Text('Hello, ${user.email}!');
///   }
/// }
/// ```
@riverpod
User? currentUser(Ref ref) {
  // Watch the auth state stream and extract the current user
  // This automatically updates when auth state changes
  final authState = ref.watch(authStateProvider);

  if (authState.hasError == true) {
    return null;
  }

  // Handle different async states:
  return authState.when(
    // When we have data (user signed in or out)
    data: (user) => user,

    // While loading, assume no user (conservative approach)
    loading: () => null,

    // On error, assume no user (fail-safe approach)
    error: (error, stackTrace) => null,
  );
}

/// **Is Authenticated Provider**
///
/// This boolean provider indicates whether a user is currently authenticated.
/// It's a computed provider that makes authentication checks simple and readable.
///
/// **Learning Points for New Developers:**
/// - **Boolean Providers**: Simplify conditional logic in UI
/// - **Computed State**: Automatically updates when dependencies change
/// - **Clean Abstractions**: Hides complexity behind simple boolean
/// - **UI Conditional Logic**: Perfect for showing/hiding authenticated content
///
/// **Why this is useful:**
/// - More readable than checking `user != null` everywhere
/// - Consistent authentication logic across the app
/// - Easy to understand for conditional rendering
/// - Can be extended with additional auth checks (email verification, etc.)
///
/// **Usage Example:**
/// ```dart
/// class NavigationDrawer extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final isAuthenticated = ref.watch(isAuthenticatedProvider);
///
///     return Drawer(
///       child: Column(
///         children: [
///           if (isAuthenticated) ...[
///             UserAccountsDrawerHeader(...),
///             ListTile(title: Text('Dashboard')),
///             ListTile(title: Text('Settings')),
///           ] else ...[
///             DrawerHeader(child: Text('Welcome')),
///             ListTile(title: Text('Sign In')),
///             ListTile(title: Text('Sign Up')),
///           ],
///         ],
///       ),
///     );
///   }
/// }
/// ```
@riverpod
bool isAuthenticated(Ref ref) {
  // Get current user from the currentUser provider
  final user = ref.watch(currentUserProvider);

  // Return true if user exists, false otherwise
  // This automatically updates when auth state changes
  return user != null;
}

/// **User Display Name Provider**
///
/// This provider extracts the user's display name with a fallback to email.
/// Demonstrates how to create domain-specific computed providers.
///
/// **Learning Points for New Developers:**
/// - **Data Transformation**: Converting raw data to UI-friendly formats
/// - **Fallback Logic**: Handling cases where preferred data isn't available
/// - **UI Optimization**: Pre-computing display values for better performance
/// - **Domain Logic**: Encapsulating business rules in providers
///
/// **Business Logic:**
/// 1. Use displayName if available
/// 2. Fall back to email if no displayName
/// 3. Fall back to "User" if neither available
/// 4. Handle null user case gracefully
///
/// **Usage Example:**
/// ```dart
/// class WelcomeMessage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final displayName = ref.watch(userDisplayNameProvider);
///
///     return Text('Welcome back, $displayName!');
///     // Could show: "Welcome back, John Doe!"
///     // Or: "Welcome back, john@example.com!"
///     // Or: "Welcome back, User!"
///   }
/// }
/// ```
@riverpod
String userDisplayName(Ref ref) {
  // Get current user
  final user = ref.watch(currentUserProvider);

  // Handle null user case
  if (user == null) {
    return 'Guest';
  }

  // Use displayName if available, otherwise email, otherwise default
  return user.displayName?.isNotEmpty == true
      ? user.displayName!
      : user.email?.isNotEmpty == true
      ? user.email!
      : 'User';
}

/// **User Email Provider**
///
/// Simple provider that extracts the user's email address.
/// Useful for displaying user info and pre-filling forms.
///
/// **Learning Points for New Developers:**
/// - **Data Extraction**: Getting specific fields from complex objects
/// - **Null Safety**: Handling nullable properties safely
/// - **Provider Granularity**: Creating focused, single-purpose providers
///
/// **Usage Example:**
/// ```dart
/// class ProfileForm extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final email = ref.watch(userEmailProvider);
///
///     return TextFormField(
///       initialValue: email,
///       decoration: InputDecoration(labelText: 'Email'),
///       enabled: false, // Email usually can't be changed
///     );
///   }
/// }
/// ```
@riverpod
String? userEmail(Ref ref) {
  // Get current user and return their email
  final user = ref.watch(currentUserProvider);
  return user?.email;
}

/// **Authentication Loading State Provider**
///
/// This provider tracks whether authentication operations are in progress.
/// Essential for showing loading indicators during auth state changes.
///
/// **Learning Points for New Developers:**
/// - **Loading States**: Managing UI feedback during async operations
/// - **AsyncValue Handling**: Working with Riverpod's async state types
/// - **User Experience**: Providing feedback during state transitions
/// - **State Composition**: Building UI state from data state
///
/// **Usage Example:**
/// ```dart
/// class LoginButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final isLoading = ref.watch(authLoadingProvider);
///
///     return ElevatedButton(
///       onPressed: isLoading ? null : () => performLogin(),
///       child: isLoading
///         ? CircularProgressIndicator()
///         : Text('Sign In'),
///     );
///   }
/// }
/// ```
@riverpod
bool authLoading(Ref ref) {
  // Check if the auth state stream is in loading state
  final authState = ref.watch(authStateProvider);

  return authState.when(
    // Not loading when we have data
    data: (_) => false,

    // Loading when stream is initializing or transitioning
    loading: () => true,

    // Not loading when there's an error (show error instead)
    error: (error, stackTrace) => false,
  );
}

/// **Authentication Error Provider**
///
/// This provider extracts authentication errors for display in the UI.
/// Demonstrates error handling patterns in Riverpod.
///
/// **Learning Points for New Developers:**
/// - **Error Handling**: Extracting and handling errors from async providers
/// - **User Feedback**: Surfacing errors to the UI appropriately
/// - **Error Types**: Working with different error types and messages
/// - **Defensive Programming**: Handling unexpected error states
///
/// **Usage Example:**
/// ```dart
/// class AuthErrorDisplay extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final error = ref.watch(authErrorProvider);
///
///     if (error == null) return SizedBox.shrink();
///
///     return Container(
///       padding: EdgeInsets.all(16),
///       color: Colors.red.shade100,
///       child: Text(
///         error,
///         style: TextStyle(color: Colors.red.shade800),
///       ),
///     );
///   }
/// }
/// ```
@riverpod
String? authError(Ref ref) {
  // Get auth state and extract error if present
  final authState = ref.watch(authStateProvider);

  return authState.when(
    // No error when we have data
    data: (_) => null,

    // No error while loading
    loading: () => null,

    // Extract error message when there's an error
    error: (error, stackTrace) {
      // Handle different error types
      if (error is AuthException) {
        // Our custom auth exceptions have user-friendly messages
        return error.message;
      } else {
        // Generic error message for unexpected errors
        return 'An authentication error occurred. Please try again.';
      }
    },
  );
}
