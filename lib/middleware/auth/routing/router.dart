import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/auth_providers.dart';
import '../../../frontend/features/auth/presentation/login_screen.dart';
import '../../../frontend/features/auth/presentation/signup_screen.dart';
import '../../../frontend/features/auth/presentation/password_reset_screen.dart';
import '../../../frontend/features/dashboard/presentation/dashboard_screen.dart';

// This part directive tells Riverpod's code generator where to place generated code
part 'router.g.dart';

/// **GoRouter Refresh Notifier**
///
/// This class bridges Riverpod's reactive state system with GoRouter's Listenable
/// requirement. GoRouter needs to be notified when to re-evaluate its redirect
/// logic, and this notifier listens to auth state changes to trigger those
/// re-evaluations.
///
/// **Learning Points for New Developers:**
/// - **ChangeNotifier Pattern**: Flutter's standard way to notify listeners of changes
/// - **Bridge Pattern**: Connecting two different systems (Riverpod and GoRouter)
/// - **Reactive Routing**: Navigation that responds to state changes automatically
/// - **Provider Listening**: Using ref.listen to react to provider changes
///
/// **How it works:**
/// 1. Extends ChangeNotifier to provide the Listenable interface GoRouter needs
/// 2. In constructor, sets up listener on authStateProvider
/// 3. When auth state changes, notifyListeners() is called
/// 4. GoRouter receives the notification and re-runs redirect logic
/// 5. Users are automatically redirected based on new auth state
///
/// **Why this is needed:**
/// - GoRouter was designed before Riverpod 3.0
/// - It expects a ChangeNotifier/Listenable for refresh notifications
/// - Our auth state is a StreamProvider returning AsyncValue<User?>
/// - This class translates between the two systems
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    // Listen to auth state changes
    // When auth state changes (login, logout, etc.), notify GoRouter to re-evaluate routes
    ref.listen(authStateProvider, (previous, next) {
      // Notify all listeners (GoRouter) that state has changed
      // This triggers GoRouter to re-run its redirect logic
      notifyListeners();
    });
  }
}

/// **Router Provider**
///
/// This provider creates and configures the GoRouter instance for the entire app.
/// It sets up all routes, handles authentication-based redirects, and ensures
/// users can only access routes they're authorized to see.
///
/// **Learning Points for New Developers:**
/// - **Declarative Routing**: Routes defined as a configuration tree
/// - **Authentication Guards**: Automatic redirect logic based on auth state
/// - **AsyncValue Handling**: Properly handling loading, data, and error states
/// - **Route Protection**: Keeping unauthenticated users out of protected areas
///
/// **Route Structure:**
/// - Public routes: /login, /signup, /reset-password (accessible without auth)
/// - Protected routes: /dashboard, /profile (require authentication)
///
/// **Redirect Logic:**
/// - Loading state: Allow current route (avoid redirect loops)
/// - Unauthenticated + protected route: Redirect to /login
/// - Authenticated + auth route: Redirect to /dashboard
/// - Error state: Redirect to /login (fail-safe)
///
/// **Usage in main.dart:**
/// ```dart
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final router = ref.watch(routerProvider);
///
///     return MaterialApp.router(
///       routerConfig: router,
///       // ... other config
///     );
///   }
/// }
/// ```
@riverpod
GoRouter router(Ref ref) {
  // Create the refresh notifier that bridges Riverpod and GoRouter
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  return GoRouter(
    // Notify GoRouter when auth state changes
    refreshListenable: refreshNotifier,

    // Initial route - start at login
    // This will be redirected if user is already authenticated
    initialLocation: '/login',

    // Redirect logic - runs on every navigation and when refreshListenable notifies
    redirect: (BuildContext context, GoRouterState state) {
      // Read (don't watch) the current auth state
      // Using read() instead of watch() prevents rebuilding the router
      final authState = ref.read(authStateProvider);

      // Handle all AsyncValue states using when()
      return authState.when(
        // Loading state: Auth check in progress
        loading: () {
          // IMPORTANT: Return null during loading to avoid redirect loops
          // Let the user stay on current route while we check auth status
          // The loading UI will be shown by individual screens if needed
          return null;
        },

        // Data state: Auth state is loaded (user or null)
        data: (user) {
          // Get the current location user is trying to access
          final currentLocation = state.matchedLocation;

          // Define which routes are authentication routes (public routes)
          final isAuthRoute =
              currentLocation == '/login' ||
              currentLocation == '/signup' ||
              currentLocation == '/reset-password';

          // Case 1: User not authenticated and trying to access protected route
          if (user == null && !isAuthRoute) {
            // Redirect to login
            return '/login';
          }

          // Case 2: User authenticated but on auth route (login/signup)
          if (user != null && isAuthRoute) {
            // Redirect to dashboard (they're already logged in)
            return '/dashboard';
          }

          // Case 3: All other cases - allow navigation
          // - Authenticated user accessing protected routes: OK
          // - Unauthenticated user on auth routes: OK
          return null;
        },

        // Error state: Auth check failed
        error: (error, stackTrace) {
          // On error, redirect to login (fail-safe approach)
          // User can attempt to login again
          return '/login';
        },
      );
    },

    // Route definitions
    routes: [
      // Public Routes (Authentication Routes)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) => const PasswordResetScreen(),
      ),

      // Protected Routes (Require Authentication)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        // Note: No need for per-route guards
        // The global redirect logic handles auth protection
      ),
    ],

    // Error handling: Show when route not found
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
