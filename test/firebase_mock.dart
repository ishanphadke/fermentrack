import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock Firebase setup for unit tests
///
/// This utility class helps set up Firebase mocking for unit tests.
/// It prevents the need for actual Firebase initialization during testing.
///
/// Learning Objectives:
/// - How to mock Firebase for unit testing
/// - Platform interface mocking patterns
/// - Test setup best practices
/// - Avoiding external dependencies in unit tests
class MockFirebase {
  /// Setup Firebase mocking for tests
  /// Call this in setUpAll() of your test files
  static void setupFirebaseAuthMocks() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the Firebase Core platform interface
    FirebasePlatform.instance = MockFirebasePlatform();
  }
}

/// Mock implementation of FirebasePlatform
/// This prevents Firebase from trying to initialize real connections
class MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseApp();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseApp()];
}

/// Mock implementation of FirebaseAppPlatform
class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp() : super(
    '[DEFAULT]',
    const FirebaseOptions(
      apiKey: 'mock-api-key',
      appId: 'mock-app-id',
      messagingSenderId: 'mock-sender-id',
      projectId: 'mock-project-id',
    ),
  );
}