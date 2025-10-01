# 🔐 Authentication Providers - Developer Guide

This guide provides comprehensive information about the Riverpod authentication providers in the Fermentrack application.

## 📋 Table of Contents

- [Overview](#overview)
- [Provider Architecture](#provider-architecture)
- [Available Providers](#available-providers)
- [Usage Examples](#usage-examples)
- [Testing](#testing)
- [Best Practices](#best-practices)

## 🌟 Overview

The authentication providers in this project create a reactive state management layer for Firebase Authentication using Riverpod. This architecture provides:

- **Reactive UI Updates**: Automatic UI updates when authentication state changes
- **Type Safety**: Full type safety with code generation
- **Testability**: Easy to test with provider overrides
- **Composition**: Computed providers that build on top of each other
- **Performance**: Optimized with auto-dispose and selective rebuilds

## 🏗️ Provider Architecture

```
AuthService (Injectable)
    ↓
authStateProvider (StreamProvider)
    ↓
┌─────────────────────┬─────────────────────┬─────────────────────┐
│                     │                     │                     │
currentUserProvider   isAuthenticatedProvider  authLoadingProvider
│                     │                     │
userDisplayNameProvider  (UI Components)     authErrorProvider
│
userEmailProvider
```

### Key Concepts

- **Base Provider**: `authServiceProvider` - Provides the AuthService instance
- **Stream Provider**: `authStateProvider` - Reactive Firebase auth state
- **Computed Providers**: Derive state from the auth stream
- **Auto-Dispose**: Providers automatically clean up when not used

## 📚 Available Providers

### Core Providers

#### 1. `authServiceProvider`
```dart
@riverpod
AuthService authService(Ref ref)
```
- **Purpose**: Provides AuthService instance
- **Type**: `Provider<AuthService>`
- **Use Case**: Calling auth methods (signIn, signOut, etc.)

#### 2. `authStateProvider`
```dart
@riverpod
Stream<User?> authState(Ref ref)
```
- **Purpose**: Reactive Firebase auth state
- **Type**: `StreamProvider<User?>`
- **Use Case**: Listening to auth state changes

### Computed Providers

#### 3. `currentUserProvider`
```dart
@riverpod
User? currentUser(Ref ref)
```
- **Purpose**: Synchronous access to current user
- **Type**: `Provider<User?>`
- **Use Case**: Quick user info access

#### 4. `isAuthenticatedProvider`
```dart
@riverpod
bool isAuthenticated(Ref ref)
```
- **Purpose**: Boolean authentication status
- **Type**: `Provider<bool>`
- **Use Case**: Conditional UI rendering

#### 5. `userDisplayNameProvider`
```dart
@riverpod
String userDisplayName(Ref ref)
```
- **Purpose**: User display name with fallbacks
- **Type**: `Provider<String>`
- **Use Case**: Showing user name in UI

#### 6. `userEmailProvider`
```dart
@riverpod
String? userEmail(Ref ref)
```
- **Purpose**: User email address
- **Type**: `Provider<String?>`
- **Use Case**: Profile forms, user info

### State Providers

#### 7. `authLoadingProvider`
```dart
@riverpod
bool authLoading(Ref ref)
```
- **Purpose**: Loading state indicator
- **Type**: `Provider<bool>`
- **Use Case**: Loading spinners, disabled buttons

#### 8. `authErrorProvider`
```dart
@riverpod
String? authError(Ref ref)
```
- **Purpose**: Error message extraction
- **Type**: `Provider<String?>`
- **Use Case**: Error displays, notifications

## 💡 Usage Examples

### Basic Authentication Checking

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return isAuthenticated
      ? DashboardScreen()
      : LoginScreen();
  }
}
```

### Reactive Authentication State

```dart
class AuthWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null
        ? HomeScreen(user: user)
        : LoginScreen(),
      loading: () => SplashScreen(),
      error: (error, stack) => ErrorScreen(error: error),
    );
  }
}
```

### User Profile Display

```dart
class UserProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(userDisplayNameProvider);
    final email = ref.watch(userEmailProvider);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        CircleAvatar(
          backgroundImage: user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : null,
          child: user?.photoURL == null
            ? Text(displayName[0].toUpperCase())
            : null,
        ),
        Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
        if (email != null) Text(email),
      ],
    );
  }
}
```

### Loading States

```dart
class LoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authLoadingProvider);
    final authService = ref.read(authServiceProvider);

    return ElevatedButton(
      onPressed: isLoading ? null : () async {
        await authService.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password',
        );
      },
      child: isLoading
        ? CircularProgressIndicator()
        : Text('Sign In'),
    );
  }
}
```

### Error Handling

```dart
class AuthErrorDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(authErrorProvider);

    if (error == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Navigation Guard

```dart
class ProtectedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Redirect to login if not authenticated
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Protected Content')),
      body: Text('Only authenticated users can see this!'),
    );
  }
}
```

### Advanced: Using Multiple Providers

```dart
class NavigationDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final displayName = ref.watch(userDisplayNameProvider);
    final email = ref.watch(userEmailProvider);
    final authService = ref.read(authServiceProvider);

    return Drawer(
      child: Column(
        children: [
          if (isAuthenticated) ...[
            UserAccountsDrawerHeader(
              accountName: Text(displayName),
              accountEmail: email != null ? Text(email) : null,
              currentAccountPicture: CircleAvatar(
                child: Text(displayName[0].toUpperCase()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => context.go('/dashboard'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => context.go('/settings'),
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () async {
                await authService.signOut();
                context.go('/');
              },
            ),
          ] else ...[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64),
                  Text('Welcome to Fermentrack'),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Sign In'),
              onTap: () => context.go('/login'),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Sign Up'),
              onTap: () => context.go('/register'),
            ),
          ],
        ],
      ),
    );
  }
}
```

## 🧪 Testing

### Provider Override Pattern

```dart
// In your test file
void main() {
  testWidgets('should show login when not authenticated', (tester) async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
        child: MyApp(),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
  });
}
```

### Integration Testing

```dart
void main() {
  group('Authentication Flow Integration Tests', () {
    testWidgets('complete sign in flow', (tester) async {
      // Test the complete authentication flow
      await tester.pumpWidget(MyApp());

      // Start unauthenticated
      expect(find.text('Sign In'), findsOneWidget);

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should navigate to sign in form
      expect(find.byType(LoginForm), findsOneWidget);
    });
  });
}
```

## ✅ Best Practices

### 1. **Use Appropriate Providers**
- Use `isAuthenticatedProvider` for simple boolean checks
- Use `currentUserProvider` for user data access
- Use `authStateProvider` for complex auth state handling

### 2. **Optimize Rebuilds**
```dart
// ✅ Good: Only rebuilds when auth status changes
Consumer(
  builder: (context, ref, child) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    return isAuthenticated ? LogoutButton() : LoginButton();
  },
)

// ❌ Avoid: Rebuilds on every auth state change
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.value != null;
    return isAuthenticated ? LogoutButton() : LoginButton();
  },
)
```

### 3. **Handle Loading States**
```dart
class AuthDependentWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(authLoadingProvider);

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return authState.when(
      data: (user) => user != null
        ? AuthenticatedContent()
        : UnauthenticatedContent(),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### 4. **Error Handling**
```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(authErrorProvider);

    // Listen for errors and show snackbar
    ref.listen(authErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      }
    });

    return LoginForm();
  }
}
```

### 5. **Performance Optimization**
```dart
// ✅ Use Consumer for targeted rebuilds
class UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final displayName = ref.watch(userDisplayNameProvider);
        return CircleAvatar(
          child: Text(displayName[0].toUpperCase()),
        );
      },
    );
  }
}
```

## 🚀 Advanced Patterns

### Provider Composition

```dart
// Create custom computed providers
@riverpod
bool canAccessAdminPanel(Ref ref) {
  final user = ref.watch(currentUserProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return isAuthenticated &&
         user?.email?.endsWith('@admin.com') == true;
}
```

### Dependency Injection

```dart
// Override providers for different environments
final container = ProviderContainer(
  overrides: [
    if (kDebugMode)
      authServiceProvider.overrideWithValue(MockAuthService()),
  ],
);
```

## 📝 Migration Notes

If you're migrating from an older authentication setup:

1. **Replace StatefulWidget with ConsumerWidget**
2. **Use providers instead of direct AuthService calls**
3. **Leverage computed providers for derived state**
4. **Update tests to use provider overrides**

## 🔧 Troubleshooting

### Common Issues

1. **Provider not updating**: Ensure you're using `ref.watch()`, not `ref.read()`
2. **Memory leaks**: Auto-dispose providers handle cleanup automatically
3. **Test failures**: Use proper provider overrides in tests
4. **Type errors**: Regenerate code with `flutter packages pub run build_runner build`

### Debug Tips

```dart
// Add logging to providers for debugging
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  final result = user != null;

  if (kDebugMode) {
    print('isAuthenticated: $result, user: ${user?.email}');
  }

  return result;
}
```

---

**Need Help?** Check the [Riverpod documentation](https://riverpod.dev) or review the test files for more examples.