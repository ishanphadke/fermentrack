// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

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

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
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
  const AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'82398d9f38c720e4ddf6b218248f15089fd4f178';

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

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

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

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
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
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'814b2db391ee5ad835843c0a84635f8be1892994';

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

@ProviderFor(currentUser)
const currentUserProvider = CurrentUserProvider._();

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

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
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
  const CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'2a36fa03a4799720726f0a28e6723726e29a77be';

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

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

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

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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
  const IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'ec341d95b490bda54e8278477e26f7b345844931';

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

@ProviderFor(userDisplayName)
const userDisplayNameProvider = UserDisplayNameProvider._();

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

final class UserDisplayNameProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
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
  const UserDisplayNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDisplayNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userDisplayNameHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return userDisplayName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userDisplayNameHash() => r'bcc7406dcf2c25d4838442c0378f4d039604021a';

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

@ProviderFor(userEmail)
const userEmailProvider = UserEmailProvider._();

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

final class UserEmailProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
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
  const UserEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userEmailHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return userEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$userEmailHash() => r'b6b10592fc378ab0e921dc8091f236861e1dec8f';

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

@ProviderFor(authLoading)
const authLoadingProvider = AuthLoadingProvider._();

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

final class AuthLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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
  const AuthLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return authLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authLoadingHash() => r'43fe6de820d482e7f14586cb54783ade0e0ecd69';

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

@ProviderFor(authError)
const authErrorProvider = AuthErrorProvider._();

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

final class AuthErrorProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
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
  const AuthErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authErrorHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return authError(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$authErrorHash() => r'c5d5fc8ed1f3a86ecf544d5454a4573ac1ae4c71';
