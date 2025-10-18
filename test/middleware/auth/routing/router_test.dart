import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fermentrack/middleware/auth/providers/auth_providers.dart';
import 'package:fermentrack/middleware/auth/routing/router.dart';
import 'package:fermentrack/frontend/features/auth/presentation/login_screen.dart';
import 'package:fermentrack/frontend/features/dashboard/presentation/dashboard_screen.dart';

import '../providers/auth_providers_test.mocks.dart';

void main() {
  /// Shared mock instances across all tests
  late MockAuthService mockAuthService;

  setUp(() {
    // Create mock auth service for all tests
    mockAuthService = MockAuthService();
  });

  tearDown(() {
    // Reset mocks after each test
    reset(mockAuthService);
  });

  group('GoRouter Configuration Tests', () {
    testWidgets('Unauthenticated users are redirected to login', (
      WidgetTester tester,
    ) async {
      // Create a container with auth state returning null (not authenticated)
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      // IMPORTANT: Listen to the stream before reading to avoid timeout
      container.listen(authStateProvider, (previous, next) {});

      // Get the router
      final router = container.read(routerProvider);

      // Build the app with router
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );
    });

    testWidgets(
      'Authenticated users trying to access login are redirected to dashboard',
      (WidgetTester tester) async {
        // Create a mock user using firebase_auth_mocks
        final mockUser = MockUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        // Create a container with auth state returning the user
        final container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
        );
        addTearDown(container.dispose);

        // IMPORTANT: Listen to the stream before reading
        container.listen(authStateProvider, (previous, next) {});

        // Get the router
        final router = container.read(routerProvider);

        // Build the app with router, starting at login
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        // Wait for async operations and redirects
        await tester.pumpAndSettle();

        // Verify we're redirected to dashboard, not login
        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/dashboard',
        );
      },
    );

    testWidgets('Authenticated users can access dashboard', (
      WidgetTester tester,
    ) async {
      // Create a mock user using firebase_auth_mocks
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Create a container with auth state returning the user
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
      );
      addTearDown(container.dispose);

      // IMPORTANT: Listen to the stream before reading
      container.listen(authStateProvider, (previous, next) {});

      // Get the router
      final router = container.read(routerProvider);

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify we're on dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets(
      'Unauthenticated users trying to access dashboard are redirected to login',
      (WidgetTester tester) async {
        // Create a container with auth state returning null
        final container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(container.dispose);

        // IMPORTANT: Listen to the stream before reading
        container.listen(authStateProvider, (previous, next) {});

        // Get the router
        final router = container.read(routerProvider);

        // Build the app
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        // Manually navigate to dashboard
        router.go('/dashboard');
        await tester.pumpAndSettle();

        // Verify we're redirected to login
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/login',
        );
      },
    );

    testWidgets('Loading state allows current route without redirect', (
      WidgetTester tester,
    ) async {
      // Create a stream controller that we DON'T emit on immediately to keep loading state
      final authStateController = StreamController<User?>();

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => authStateController.stream),
        ],
      );
      addTearDown(() {
        authStateController.close();
        container.dispose();
      });

      // IMPORTANT: Listen to the stream before reading
      container.listen(authStateProvider, (previous, next) {});

      // Get the router
      final router = container.read(routerProvider);

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pump();

      // During loading, should stay on initial location (login)
      // No redirect should occur because redirect logic returns null for loading state
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );

      // Now settle to clean up any pending timers
      await tester.pumpAndSettle();
    });

    testWidgets('Error state redirects to login', (WidgetTester tester) async {
      // Create a container with error auth state
      final authStateController = StreamController<User?>();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => authStateController.stream),
        ],
      );
      addTearDown(() {
        authStateController.close();
        container.dispose();
      });

      // IMPORTANT: Listen to the stream before reading
      var future = container.listen(
        authStateProvider.future,
        (previous, next) {},
      );
      // Change auth state (simulate login)
      final mockUser = MockUser(uid: 'test-uid', email: 'test@example.com');
      authStateController.add(mockUser);
      await future.read();

      // Get the router
      final router = container.read(routerProvider);

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Wait for async operations
      await tester.pump();
      // should be logged in
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/dashboard',
      );

      authStateController.add(null);
      await future.read();

      // Verify we're redirected to login on error
      expect(
        '/login',
        router.routerDelegate.currentConfiguration.uri.toString(),
      );
      // Now settle to clean up any pending timers
      await tester.pumpAndSettle();
    });
  });

  group('GoRouterRefreshNotifier Tests', () {
    testWidgets('Notifies GoRouter when auth state changes', (
      WidgetTester tester,
    ) async {
      // Create a stream controller to manually control auth state
      final authStateController = StreamController<User?>.broadcast();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => authStateController.stream),
        ],
      );
      addTearDown(() {
        authStateController.close();
        container.dispose();
      });

      // IMPORTANT: Listen to the stream before reading
      var authFuture = container.listen(
        authStateProvider.future,
        (previous, next) {},
      );

      // Start unauthenticated
      authStateController.add(null);
      await authFuture.read();
      await tester.pumpAndSettle();

      // Get the router (this internally creates the refresh notifier)
      final router = container.read(routerProvider);

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Should be on login
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );

      // Change auth state (simulate login)
      final mockUser = MockUser(uid: 'test-uid', email: 'test@example.com');
      authStateController.add(mockUser);
      await authFuture.read();
      await tester.pumpAndSettle();

      // Should be redirected to dashboard (proves refresh notifier works)
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/dashboard',
      );
    });
  });

  group('Route Navigation Tests', () {
    testWidgets('Can navigate between public routes', (
      WidgetTester tester,
    ) async {
      // Create a stream controller to manually control auth state
      final authStateController = StreamController<User?>.broadcast();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => authStateController.stream),
        ],
      );
      addTearDown(() {
        authStateController.close();
        container.dispose();
      });

      // IMPORTANT: Listen to the stream before reading
      var authFuture = container.listen(
        authStateProvider.future,
        (previous, next) {},
      );

      // Add unauthenticated value
      authStateController.add(null);
      await authFuture.read();
      await tester.pumpAndSettle();

      // Get the router
      var router = container.listen(routerProvider, (_, _) {});

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router.read()),
        ),
      );

      await tester.pumpAndSettle();

      // Start at login
      expect(
        router.read().routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );

      // Navigate to signup
      router.read().go('/signup');
      await tester.pumpAndSettle();
      expect(
        router.read().routerDelegate.currentConfiguration.uri.toString(),
        '/signup',
      );

      // Navigate to password reset
      router.read().go('/reset-password');
      await tester.pumpAndSettle();
      expect(
        router.read().routerDelegate.currentConfiguration.uri.toString(),
        '/reset-password',
      );

      // Navigate back to login
      router.read().go('/login');
      await tester.pumpAndSettle();
      expect(
        router.read().routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );
    });

    testWidgets('Auth state change triggers automatic redirect', (
      WidgetTester tester,
    ) async {
      // Create a mock user using firebase_auth_mocks
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Create a stream controller to simulate login
      final authStateController = StreamController<User?>.broadcast();

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith((ref) => authStateController.stream),
        ],
      );
      addTearDown(() {
        authStateController.close();
        container.dispose();
      });

      // IMPORTANT: Listen to the stream before reading
      var authFuture = container.listen(
        authStateProvider.future,
        (previous, next) {},
      );
      // Add unauthenticated value
      authStateController.add(null);
      await authFuture.read();
      await tester.pumpAndSettle();

      // Get the router
      final router = container.read(routerProvider);

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      // Should be on login
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );

      // Simulate login by changing auth state
      authStateController.add(mockUser);

      await authFuture.read();
      await tester.pumpAndSettle();

      // Should be redirected to dashboard
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/dashboard',
      );
    });
  });
}
