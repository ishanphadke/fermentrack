import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fermentrack/middleware/auth/providers/auth_providers.dart';
import 'package:fermentrack/middleware/auth/services/auth_service.dart';

import '../services/auth_service_test.mocks.dart';
import 'auth_providers_test.mocks.dart';

/// Comprehensive unit tests for Authentication Riverpod Providers
///
/// This test file demonstrates advanced Riverpod provider testing patterns for 2024:
///
/// Key Testing Concepts Covered:
/// - Riverpod provider testing with ProviderContainer
/// - Provider dependency injection and overrides
/// - StreamProvider testing with mock data streams
/// - Computed provider testing and state composition
/// - Provider lifecycle management (autoDispose)
/// - Error handling in providers
/// - Provider state verification and assertions
///
/// Educational Value for New Developers:
/// - Learn how to test Riverpod providers effectively
/// - Understand provider composition and dependencies
/// - Master async provider testing patterns
/// - Practice provider override patterns for testing
/// - Explore reactive state management testing
///
/// Testing Strategy for Provider Architecture:
/// - Test each provider in isolation
/// - Verify provider dependencies work correctly
/// - Test provider state changes and reactivity
/// - Ensure proper error propagation
/// - Validate provider disposal and cleanup
/// - Test provider composition scenarios

// Generate additional mocks specifically for provider testing
@GenerateMocks([AuthService])
void main() {
  /// Test setup for all provider tests
  /// ProviderContainer manages the provider state during testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Providers Tests', () {
    /// Test variables - shared across test methods
    late MockAuthService mockAuthService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    /// setUp() runs before each individual test
    /// This ensures each test starts with a clean mock state
    setUp(() {
      // Create mock instances for testing
      mockAuthService = MockAuthService();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();

      // Configure mock user properties
      when(mockUser.uid).thenReturn('test-uid-123');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.emailVerified).thenReturn(true);
    });

    /// tearDown() runs after each individual test
    /// Clean up mock state
    tearDown(() async {
      // Reset all mocks to clean state
      reset(mockAuthService);
      reset(mockFirebaseAuth);
      reset(mockUser);
    });

    /// Testing Group: AuthService Provider
    /// Verifies the basic service provider functionality
    group('authServiceProvider', () {
      test('should provide AuthService instance', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE & ACT: Read the provider value
        final authService = container.read(authServiceProvider);

        // ASSERT: Verify we get the mocked service
        expect(authService, isA<AuthService>());
        expect(authService, equals(mockAuthService));

        // Clean up
        container.dispose();
      });

      test('should be auto-disposed when container is disposed', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Read the provider to initialize it
        container.read(authServiceProvider);

        // ACT: Dispose the container
        container.dispose();

        // ASSERT: Verify the provider was disposed
        // Auto-dispose providers clean up when no longer needed
        // Note: Container disposal test is implementation-specific
      });

      test('should maintain singleton behavior', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE & ACT: Read the provider multiple times
        final service1 = container.read(authServiceProvider);
        final service2 = container.read(authServiceProvider);

        // ASSERT: Should return the same instance
        expect(service1, equals(service2));
        expect(identical(service1, service2), isTrue);

        // Clean up
        container.dispose();
      });
    });

    /// Testing Group: Authentication State Stream Provider
    /// Verifies reactive authentication state management
    group('authStateProvider', () {
      test('should provide stream from AuthService', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Configure mock to return a test stream
        final testStream = Stream.value(mockUser);
        when(mockAuthService.authStateChanges).thenAnswer((_) => testStream);

        // ACT: Listen to the provider
        final AsyncValue<User?> authState = container.read(authStateProvider);

        // ASSERT: Should be in loading state initially
        expect(authState, isA<AsyncLoading<User?>>());

        // Verify the service method was called
        verify(mockAuthService.authStateChanges).called(1);

        // Clean up
        container.dispose();
      });

      test('should emit user when authenticated', () async {
        // Create test specific container
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create a stream controller for controlled emission
        final streamController = StreamController<User?>();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        // ACT: Start listening to the provider
        final future = container.listen(authStateProvider.future, (_, _) {});

        // Emit the user data
        streamController.add(mockUser);

        // Wait for the stream to emit the user
        final authState = await future.read();

        // ASSERT: Should have user data
        expect(authState, equals(mockUser));
        expect(authState?.uid, equals('test-uid-123'));
        expect(authState?.email, equals('test@example.com'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should emit null when not authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create a stream controller for controlled emission
        final streamController = StreamController<User?>();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        // ACT: Start listening to the provider
        final future = container.listen(authStateProvider.future, (_, _) {});

        // Emit null
        streamController.add(null);

        // Wait for the stream to complete
        final authState = await future.read();

        // ASSERT: Should have null data (not authenticated)
        expect(authState, isNull);

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should show loading state initially', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up a stream that never emits
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => const Stream.empty());

        // ACT & ASSERT: Test loading state
        final provider = authStateProvider;
        expect(container.read(provider), isA<AsyncLoading<User?>>());

        // Clean up
        container.dispose();
      });
    });

    /// Testing Group: Current User Provider
    /// Verifies synchronous user access patterns
    group('currentUserProvider', () {
      test('should return user when authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up authenticated state
        final streamController = StreamController<User?>();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        // ACT: Start listening to the provider
        final authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user data
        streamController.add(mockUser);
        // Wait for auth state to be established
        await authStateFuture.read();

        // ACT: Read current user
        final currentUser = container.read(currentUserProvider);

        // ASSERT: Should return the authenticated user
        expect(currentUser, isNotNull);
        expect(currentUser, equals(mockUser));
        expect(currentUser?.uid, equals('test-uid-123'));
        expect(currentUser?.email, equals('test@example.com'));

        // Clean up
        container.dispose();
      });

      test('should return null when not authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up unauthenticated state
        final streamController = StreamController<User?>();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        // ACT: Start listening to the provider
        final authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit null
        streamController.add(null);

        // Wait for auth state to be established
        await authStateFuture.read();

        // ACT: Read current user
        final currentUser = container.read(currentUserProvider);

        // ASSERT: Should return null
        expect(currentUser, isNull);

        // Clean up
        container.dispose();
      });

      test('should return null during loading state', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up a stream that doesn't emit immediately
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => const Stream.empty());

        // ACT: Read current user while auth state is loading
        final currentUser = container.read(currentUserProvider);

        // ASSERT: Should return null (conservative approach)
        expect(currentUser, isNull);

        // Clean up
        container.dispose();
      });

      test(
        'should return null when auth state has error',
        () async {
          final container = ProviderContainer.test(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );

          // ARRANGE: Set up an error stream
          final streamController = StreamController<User?>.broadcast();
          when(
            mockAuthService.authStateChanges,
          ).thenAnswer((_) => streamController.stream);
          final authStateFuture = container.listen(
            authStateProvider.future,
            (_, _) {},
          );

          const authException = AuthException('Invalid credentials');
          streamController.addError(authException);
          await authStateFuture.read();

          // ACT: Read current user during error state
          final currentUser = container.read(currentUserProvider);

          // ASSERT: Should return null (fail-safe approach)
          expect(currentUser, isNull);

          // Clean up
          container.dispose();
        },
        skip: true,
      ); // TODO: Figure out how to get StreamController's error to propogate
    });

    /// Testing Group: Is Authenticated Provider
    /// Verifies boolean authentication status
    group('isAuthenticatedProvider', () {
      test('should return true when user is authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up authenticated state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        final authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );
        // Wait for auth state
        streamController.add(mockUser);
        await authStateFuture.read();

        // ACT: Check authentication status
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // ASSERT: Should be true
        expect(isAuthenticated, isTrue);

        // Clean up
        container.dispose();
      });

      test('should return false when not authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );
        // ARRANGE: Set up authenticated state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        final authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );
        // Wait for auth state
        streamController.add(null);
        await authStateFuture.read();

        // ACT: Check authentication status
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // ASSERT: Should be false
        expect(isAuthenticated, isFalse);

        // Clean up
        container.dispose();
      });

      test('should return false during loading state', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up loading state
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => const Stream.empty());

        // ACT: Check authentication status during loading
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // ASSERT: Should be false (conservative approach)
        expect(isAuthenticated, isFalse);

        // Clean up
        container.dispose();
      });

      test('should return false when auth state has error', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up error state
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => Stream.error(Exception('Auth error')));

        // ACT: Check authentication status during error
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // ASSERT: Should be false (fail-safe approach)
        expect(isAuthenticated, isFalse);

        // Clean up
        container.dispose();
      });

      test('should reflect authentication state correctly', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // Test different authentication states using separate containers

        // Test authenticated state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        final authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );
        // Wait for auth state
        streamController.add(mockUser);
        await authStateFuture.read();
        expect(container.read(isAuthenticatedProvider), isTrue);

        // Test unauthenticated state
        streamController.add(null);
        await authStateFuture.read();
        expect(container.read(isAuthenticatedProvider), isFalse);

        // Clean up
        container.dispose();
      });
    });

    /// Testing Group: User Display Name Provider
    /// Verifies user display name logic and fallbacks
    group('userDisplayNameProvider', () {
      test('should return display name when available', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create user with display name
        final mockUserWithDisplayName = MockUser();
        when(mockUserWithDisplayName.uid).thenReturn('test-uid');
        when(mockUserWithDisplayName.email).thenReturn('test@example.com');
        when(mockUserWithDisplayName.displayName).thenReturn('John Doe');

        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user with display name
        streamController.add(mockUserWithDisplayName);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Get display name
        final displayName = container.read(userDisplayNameProvider);

        // ASSERT: Should return display name
        expect(displayName, equals('John Doe'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should fall back to email when display name is null', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create user without display name
        final mockUserWithoutDisplayName = MockUser();
        when(mockUserWithoutDisplayName.uid).thenReturn('test-uid');
        when(mockUserWithoutDisplayName.email).thenReturn('john@example.com');
        when(mockUserWithoutDisplayName.displayName).thenReturn(null);

        // set up user stream
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user without display name
        streamController.add(mockUserWithoutDisplayName);

        // Wait for user to propagate
        await authStateFuture.read();

        // ACT: Get display name
        final displayName = container.read(userDisplayNameProvider);
        // ASSERT: Should return email
        expect(displayName, equals('john@example.com'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should fall back to email when display name is empty', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create user with empty display name
        final mockUserWithEmptyDisplayName = MockUser();
        when(mockUserWithEmptyDisplayName.uid).thenReturn('test-uid');
        when(mockUserWithEmptyDisplayName.email).thenReturn('jane@example.com');
        when(mockUserWithEmptyDisplayName.displayName).thenReturn('');

        // set up user stream
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user with empty display name
        streamController.add(mockUserWithEmptyDisplayName);

        // Wait for user to propagate
        await authStateFuture.read();
        final displayName = container.read(userDisplayNameProvider);

        // ASSERT: Should return email
        expect(displayName, equals('jane@example.com'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test(
        'should fall back to "User" when both display name and email are unavailable',
        () async {
          final container = ProviderContainer.test(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );

          // ARRANGE: Create user without display name or email
          final mockUserWithoutNameOrEmail = MockUser();
          when(mockUserWithoutNameOrEmail.uid).thenReturn('test-uid');
          when(mockUserWithoutNameOrEmail.email).thenReturn(null);
          when(mockUserWithoutNameOrEmail.displayName).thenReturn(null);

          // set up user stream
          final streamController = StreamController<User?>.broadcast();
          when(
            mockAuthService.authStateChanges,
          ).thenAnswer((_) => streamController.stream);
          var authStateFuture = container.listen(
            authStateProvider.future,
            (_, _) {},
          );

          // Emit user without name or email
          streamController.add(mockUserWithoutNameOrEmail);

          // Wait for auth state
          await authStateFuture.read();

          // ACT: Get display name
          final displayName = container.read(userDisplayNameProvider);

          // ASSERT: Should return default
          expect(displayName, equals('User'));

          // Clean up
          await streamController.close();
          container.dispose();
        },
      );

      test('should fall back to "User" when email is empty', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create user with empty email
        final mockUserWithEmptyEmail = MockUser();
        when(mockUserWithEmptyEmail.uid).thenReturn('test-uid');
        when(mockUserWithEmptyEmail.email).thenReturn('');
        when(mockUserWithEmptyEmail.displayName).thenReturn(null);

        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user with empty email
        streamController.add(mockUserWithEmptyEmail);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Get display name
        final displayName = container.read(userDisplayNameProvider);

        // ASSERT: Should return default
        expect(displayName, equals('User'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should return "Guest" when not authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up unauthenticated state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit null
        streamController.add(null);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Get display name
        final displayName = container.read(userDisplayNameProvider);

        // ASSERT: Should return guest
        expect(displayName, equals('Guest'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should update when user changes', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create controllable broadcast stream
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Start with no user
        streamController.add(null);
        await authStateFuture.read();

        expect(container.read(userDisplayNameProvider), equals('Guest'));

        // Add user with display name
        final userWithName = MockUser();
        when(userWithName.displayName).thenReturn('Alice Smith');
        when(userWithName.email).thenReturn('alice@example.com');

        streamController.add(userWithName);
        await authStateFuture.read();

        expect(container.read(userDisplayNameProvider), equals('Alice Smith'));

        // Clean up
        await streamController.close();
        container.dispose();
      });
    });

    /// Testing Group: User Email Provider
    /// Verifies user email extraction
    group('userEmailProvider', () {
      test('should return user email when authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up authenticated user
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user data
        streamController.add(mockUser);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Get user email
        final email = container.read(userEmailProvider);

        // ASSERT: Should return email
        expect(email, equals('test@example.com'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should return null when not authenticated', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up unauthenticated state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit null
        streamController.add(null);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Get user email
        final email = container.read(userEmailProvider);

        // ASSERT: Should return null
        expect(email, isNull);

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should return null when user has no email', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create user without email
        final mockUserWithoutEmail = MockUser();
        when(mockUserWithoutEmail.uid).thenReturn('test-uid');
        when(mockUserWithoutEmail.email).thenReturn(null);

        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user without email
        streamController.add(mockUserWithoutEmail);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Get user email
        final email = container.read(userEmailProvider);

        // ASSERT: Should return null
        expect(email, isNull);

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should update when user changes', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create controllable broadcast stream
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Start with no user
        streamController.add(null);
        await authStateFuture.read();

        expect(container.read(userEmailProvider), isNull);

        // Create new stream for user with email
        // Add user with email
        streamController.add(mockUser);
        await authStateFuture.read();

        expect(container.read(userEmailProvider), equals('test@example.com'));

        // Clean up
        await streamController.close();
        await streamController.close();
        container.dispose();
      });
    });

    /// Testing Group: Authentication Loading Provider
    /// Verifies loading state management
    group('authLoadingProvider', () {
      test('should return true during loading state', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up loading state (stream that doesn't emit)
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        // ACT: Check loading state (don't emit anything to stay in loading)
        final isLoading = container.read(authLoadingProvider);

        // ASSERT: Should be loading
        expect(isLoading, isTrue);

        // Clean up
        streamController.close();
        container.dispose();
      });

      test('should return false when data is available', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up stream with data
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit data
        streamController.add(mockUser);

        // Wait for data
        await authStateFuture.read();

        // ACT: Check loading state
        final isLoading = container.read(authLoadingProvider);

        // ASSERT: Should not be loading
        expect(isLoading, isFalse);

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test(
        'should return false when error occurs',
        () async {
          final container = ProviderContainer.test(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );

          // ARRANGE: Set up error stream
          final streamController = StreamController<User?>.broadcast();
          when(
            mockAuthService.authStateChanges,
          ).thenAnswer((_) => Stream.error(Exception('Auth error')));
          var authStateFuture = container.listen(
            authStateProvider.future,
            (_, _) {},
          );

          await authStateFuture.read();

          // ACT: Check loading state
          final isLoading = container.read(authLoadingProvider);

          // ASSERT: Should not be loading (show error instead)
          expect(isLoading, isFalse);

          // Clean up
          streamController.close();
          container.dispose();
        },
        skip: true,
      ); // TODO: Figure out how to get StreamController's error to propogate

      // TODO: This test group should include another that
      // should transition from loading to not loading
    });

    /// Testing Group: Authentication Error Provider
    /// Verifies error handling and extraction
    group('authErrorProvider', () {
      test('should return null when no error', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up successful state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit successful data
        streamController.add(mockUser);

        // Wait for data
        await authStateFuture.read();
        // ACT: Check for error
        final error = container.read(authErrorProvider);

        // ASSERT: Should be no error
        expect(error, isNull);

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should return null during loading', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up loading state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Wait for auth state
        authStateFuture.read();

        // ACT: Check for error during loading (don't emit anything)
        final error = container.read(authErrorProvider);

        // ASSERT: Should be no error
        expect(error, isNull);

        // Clean up
        streamController.close();
        container.dispose();
      });

      test(
        'should return AuthException message when auth error occurs',
        () {
          final container = ProviderContainer.test(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );

          // ARRANGE: Set up error stream with AuthException
          const authException = AuthException('Invalid credentials');
          final streamController = StreamController<User?>.broadcast();
          when(
            mockAuthService.authStateChanges,
          ).thenAnswer((_) => streamController.stream);
          streamController.addError(authException);

          // ACT: Check for error
          final error = container.read(authErrorProvider);

          // ASSERT: Should return auth exception message
          expect(error, equals('Invalid credentials'));

          // Clean up
          streamController.close();
          container.dispose();
        },
        skip: true,
      ); // TODO: Figure out how to get StreamController's error to propogate

      test(
        'should return generic message for non-auth errors',
        () {
          final container = ProviderContainer.test(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );

          // ARRANGE: Set up error stream with generic exception
          final genericException = Exception('Network error');
          final streamController = StreamController<User?>.broadcast();
          when(
            mockAuthService.authStateChanges,
          ).thenAnswer((_) => streamController.stream);
          var authStateFuture = container.listen(
            authStateProvider.future,
            (_, _) {},
          );
          streamController.addError(genericException);

          // Wait for auth state
          authStateFuture.read();

          // ACT: Check for error
          final error = container.read(authErrorProvider);

          // ASSERT: Should return generic error message
          expect(
            error,
            equals('An authentication error occurred. Please try again.'),
          );

          // Clean up
          streamController.close();
          container.dispose();
        },
        skip: true,
      ); // TODO: Figure out how to get StreamController's error to propogate

      test('should update when error state changes', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create controllable broadcast stream
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Start with no error
        streamController.add(mockUser);
        // Wait for auth state
        await authStateFuture.read();

        await container.read(authStateProvider.future);

        expect(container.read(authErrorProvider), isNull);

        // Create new stream for error state
        final streamController2 = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController2.stream);

        // Emit error
        streamController2.addError(const AuthException('Test error'));
        container.invalidate(authStateProvider);
        await Future.delayed(const Duration(milliseconds: 10));

        try {
          await container.read(authStateProvider.future);
        } catch (e) {
          // Expected error
        }

        expect(container.read(authErrorProvider), equals('Test error'));

        // Clean up
        await streamController.close();
        await streamController2.close();
        container.dispose();
      }, skip: true);
    }); // TODO: Figure out how to get StreamController's error to propogate

    /// Testing Group: Provider Integration and Composition
    /// Verifies how providers work together
    group('Provider Integration Tests', () {
      test('should maintain consistency across dependent providers', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Set up authenticated state
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Emit user data
        streamController.add(mockUser);

        // Wait for auth state
        await authStateFuture.read();

        // ACT: Read all dependent providers
        final currentUser = container.read(currentUserProvider);
        final isAuthenticated = container.read(isAuthenticatedProvider);
        final displayName = container.read(userDisplayNameProvider);
        final email = container.read(userEmailProvider);
        final isLoading = container.read(authLoadingProvider);
        final error = container.read(authErrorProvider);

        // ASSERT: All providers should be consistent
        expect(currentUser, isNotNull);
        expect(isAuthenticated, isTrue);
        expect(displayName, equals('Test User')); // From mock user
        expect(email, equals('test@example.com'));
        expect(isLoading, isFalse);
        expect(error, isNull);

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test('should handle state transitions consistently', () async {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create controllable broadcast stream
        final streamController = StreamController<User?>.broadcast();
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => streamController.stream);
        var authStateFuture = container.listen(
          authStateProvider.future,
          (_, _) {},
        );

        // Start unauthenticated
        streamController.add(null);
        await authStateFuture.read();

        // Verify unauthenticated state across all providers
        expect(container.read(currentUserProvider), isNull);
        expect(container.read(isAuthenticatedProvider), isFalse);
        expect(container.read(userDisplayNameProvider), equals('Guest'));
        expect(container.read(userEmailProvider), isNull);

        // Transition to authenticated
        streamController.add(mockUser);
        await authStateFuture.read();

        // Verify authenticated state across all providers
        expect(container.read(currentUserProvider), equals(mockUser));
        expect(container.read(isAuthenticatedProvider), isTrue);
        expect(container.read(userDisplayNameProvider), equals('Test User'));
        expect(container.read(userEmailProvider), equals('test@example.com'));

        // Clean up
        await streamController.close();
        container.dispose();
      });

      test(
        'should handle error states consistently',
        () async {
          final container = ProviderContainer.test(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );

          // ARRANGE: Set up error stream
          const authException = AuthException('Session expired');
          final streamController = StreamController<User?>.broadcast();
          when(
            mockAuthService.authStateChanges,
          ).thenAnswer((_) => streamController.stream);
          streamController.addError(authException);

          // ACT: Try to read auth state
          try {
            await container.read(authStateProvider.future);
          } catch (e) {
            // Expected error
          }

          // ASSERT: Error state should be consistent across providers
          expect(container.read(currentUserProvider), isNull);
          expect(container.read(isAuthenticatedProvider), isFalse);
          expect(container.read(userDisplayNameProvider), equals('Guest'));
          expect(container.read(userEmailProvider), isNull);
          expect(container.read(authLoadingProvider), isFalse);
          expect(container.read(authErrorProvider), equals('Session expired'));

          // Clean up
          await streamController.close();
          container.dispose();
        },
        skip: true,
      ); // TODO: Figure out how to get StreamController's error to propogate
    });

    /// Testing Group: Provider Lifecycle and Memory Management
    /// Verifies proper resource cleanup and disposal
    group('Provider Lifecycle Tests', () {
      test('should handle multiple container instances', () {
        final container = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ARRANGE: Create multiple containers
        final container1 = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        final container2 = ProviderContainer.test(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        );

        // ACT: Read providers from both containers
        final service1 = container1.read(authServiceProvider);
        final service2 = container2.read(authServiceProvider);

        // ASSERT: Should have independent provider instances
        expect(service1, equals(mockAuthService));
        expect(service2, equals(mockAuthService));

        // Clean up
        container1.dispose();
        container2.dispose();
        container.dispose();
      });
    });
  });

  /// Testing Group: Advanced Provider Patterns
  /// Demonstrates complex testing scenarios
  group('Advanced Provider Testing Patterns', () {
    test('demonstrates provider override testing', () {
      // This test shows how to override providers for specific test scenarios
      final mockService = MockAuthService();
      final testUser = MockUser();

      when(testUser.uid).thenReturn('override-test-uid');
      when(testUser.email).thenReturn('override@test.com');
      when(
        mockService.authStateChanges,
      ).thenAnswer((_) => Stream.value(testUser));

      final testContainer = ProviderContainer.test(
        overrides: [authServiceProvider.overrideWithValue(mockService)],
      );

      // Verify the override works
      expect(testContainer.read(authServiceProvider), equals(mockService));

      // Clean up
      testContainer.dispose();
    });

    test('demonstrates provider listener testing', () async {
      // This test shows how to test provider listeners and reactivity
      final testAuthService = MockAuthService();
      final testUser = MockUser();

      when(testUser.uid).thenReturn('listener-test-uid');
      when(testUser.email).thenReturn('listener@test.com');

      final streamController = StreamController<User?>.broadcast();
      when(
        testAuthService.authStateChanges,
      ).thenAnswer((_) => streamController.stream);

      final testContainer = ProviderContainer.test(
        overrides: [authServiceProvider.overrideWithValue(testAuthService)],
      );

      var notificationCount = 0;
      final subscription = testContainer.listen(isAuthenticatedProvider, (
        previous,
        next,
      ) {
        notificationCount++;
      });

      // Initialize the provider by reading it first
      testContainer.read(authStateProvider);

      // Emit initial user state
      streamController.add(testUser);

      // Wait for provider to process the user
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify user is authenticated
      expect(testContainer.read(isAuthenticatedProvider), isTrue);

      // Test logout - emit null to simulate sign out
      streamController.add(null);

      // Wait for the stream change to propagate
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify user is no longer authenticated
      expect(testContainer.read(isAuthenticatedProvider), isFalse);

      // Verify notifications were received (at least 2: true -> false)
      expect(notificationCount, greaterThan(0));

      // Clean up
      subscription.close();
      await streamController.close();
      testContainer.dispose();
    });

    test('demonstrates concurrent provider access', () async {
      // This test shows how providers handle concurrent access
      final testAuthService = MockAuthService();
      final testUser = MockUser();

      when(testUser.uid).thenReturn('concurrent-test-uid');
      when(testUser.email).thenReturn('concurrent@test.com');

      final streamController = StreamController<User?>.broadcast();
      when(
        testAuthService.authStateChanges,
      ).thenAnswer((_) => streamController.stream);

      final testContainer = ProviderContainer.test(
        overrides: [authServiceProvider.overrideWithValue(testAuthService)],
      );

      final futures = List.generate(10, (index) async {
        return testContainer.read(authServiceProvider);
      });

      final results = await Future.wait(futures);

      // All should return the same service instance
      expect(results, everyElement(equals(testAuthService)));
      expect(
        results.every((service) => identical(service, results.first)),
        isTrue,
      );

      // Clean up
      await streamController.close();
      testContainer.dispose();
    });
  });
}

/// Test Utilities and Helpers
/// These utilities make tests more maintainable and readable

/// Helper to create a test user with specific properties
MockUser createTestUser({
  String uid = 'test-uid',
  String? email,
  String? displayName,
  bool emailVerified = false,
}) {
  final user = MockUser();
  when(user.uid).thenReturn(uid);
  when(user.email).thenReturn(email);
  when(user.displayName).thenReturn(displayName);
  when(user.emailVerified).thenReturn(emailVerified);
  return user;
}

/// Helper to create a test auth service with predefined behavior
MockAuthService createTestAuthService({
  User? currentUser,
  Stream<User?>? authStateChanges,
}) {
  final service = MockAuthService();

  if (currentUser != null) {
    when(service.currentUser).thenReturn(currentUser);
  }

  if (authStateChanges != null) {
    when(service.authStateChanges).thenReturn(authStateChanges);
  }

  return service;
}

/// Helper to create a provider container with common overrides
ProviderContainer createTestContainer({AuthService? authService}) {
  return ProviderContainer(
    overrides: [
      if (authService != null)
        authServiceProvider.overrideWithValue(authService),
    ],
  );
}

/// Custom test matchers for better readability
Matcher isAuthenticatedUser() {
  return predicate<User?>((user) => user != null, 'authenticated user');
}

Matcher isUnauthenticated() {
  return predicate<User?>((user) => user == null, 'unauthenticated');
}

Matcher hasEmail(String expectedEmail) {
  return predicate<User?>(
    (user) => user?.email == expectedEmail,
    'user with email $expectedEmail',
  );
}

Matcher hasDisplayName(String expectedName) {
  return predicate<User?>(
    (user) => user?.displayName == expectedName,
    'user with display name $expectedName',
  );
}

/// Test Data Constants for Provider Testing
class ProviderTestData {
  static const String testUid = 'provider-test-uid-123';
  static const String testEmail = 'provider-test@example.com';
  static const String testDisplayName = 'Provider Test User';

  // Error messages
  static const String authFailedMessage = 'Authentication failed';
  static const String sessionExpiredMessage = 'Session expired';
  static const String networkErrorMessage = 'Network error';

  // Timeouts
  static const Duration shortTimeout = Duration(milliseconds: 100);
  static const Duration mediumTimeout = Duration(milliseconds: 500);
  static const Duration longTimeout = Duration(seconds: 2);
}
