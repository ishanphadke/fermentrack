import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/frontend/utils/email_validator.dart';

/// Unit tests for EmailValidator utility class
///
/// These tests verify the email validation logic in isolation,
/// separate from UI integration tests in the auth screen tests.
///
/// Test coverage:
/// - validate() method for various email formats
/// - validateSimple() for basic @ check
/// - Edge cases (null, empty, special characters)
/// - Common valid/invalid email patterns
void main() {
  group('EmailValidator', () {
    group('validate() method', () {
      test('should return null for valid standard email', () {
        // Arrange
        const email = 'user@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should return null for valid email with subdomain', () {
        // Arrange
        const email = 'user@mail.example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should return null for valid email with plus sign', () {
        // Arrange
        const email = 'user+tag@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should return null for valid email with dots', () {
        // Arrange
        const email = 'first.last@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should return null for valid email with numbers', () {
        // Arrange
        const email = 'user123@example456.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should return error for null email', () {
        // Arrange
        const String? email = null;

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter your email'));
      });

      test('should return error for empty email', () {
        // Arrange
        const email = '';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter your email'));
      });

      test('should return error for email without @', () {
        // Arrange
        const email = 'userexample.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should return error for email without domain', () {
        // Arrange
        const email = 'user@';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should return error for email without local part', () {
        // Arrange
        const email = '@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should return error for email without top-level domain', () {
        // Arrange
        const email = 'user@example';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should return error for email with multiple @ symbols', () {
        // Arrange
        const email = 'user@@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should return error for email with spaces', () {
        // Arrange
        const email = 'user @example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should accept email starting with dot', () {
        // Arrange
        const email = '.user@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        // Note: This passes the simple regex but would fail Firebase validation
        // The simple regex is intentionally permissive, relying on server validation
        expect(result, isNull);
      });

      test('should accept email with hyphen in domain', () {
        // Arrange
        const email = 'user@my-domain.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should accept email with underscore', () {
        // Arrange
        const email = 'user_name@example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });
    });

    group('validateSimple() method', () {
      test('should return null for email with @', () {
        // Arrange
        const email = 'user@example.com';

        // Act
        final result = EmailValidator.validateSimple(email);

        // Assert
        expect(result, isNull);
      });

      test('should return null for minimal email with @', () {
        // Arrange - Even invalid format passes if it has @
        const email = 'a@b';

        // Act
        final result = EmailValidator.validateSimple(email);

        // Assert
        expect(result, isNull); // Simple validation only checks for @
      });

      test('should return error for null email', () {
        // Arrange
        const String? email = null;

        // Act
        final result = EmailValidator.validateSimple(email);

        // Assert
        expect(result, equals('Please enter your email'));
      });

      test('should return error for empty email', () {
        // Arrange
        const email = '';

        // Act
        final result = EmailValidator.validateSimple(email);

        // Assert
        expect(result, equals('Please enter your email'));
      });

      test('should return error for email without @', () {
        // Arrange
        const email = 'userexample.com';

        // Act
        final result = EmailValidator.validateSimple(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should be more permissive than validate()', () {
        // Arrange - Email missing TLD
        const email = 'user@example';

        // Act
        final simpleResult = EmailValidator.validateSimple(email);
        final fullResult = EmailValidator.validate(email);

        // Assert - Simple passes, full validation fails
        expect(simpleResult, isNull); // Has @, so simple validation passes
        expect(fullResult, isNotNull); // Doesn't match full regex pattern
      });
    });

    group('Edge cases and special scenarios', () {
      test('should handle very long valid email', () {
        // Arrange
        const email = 'very.long.email.address.name@subdomain.example.com';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should handle single letter local and domain parts', () {
        // Arrange
        const email = 'a@b.c';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should handle email with multiple dots in domain', () {
        // Arrange
        const email = 'user@mail.example.co.uk';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should reject email with only whitespace', () {
        // Arrange
        const email = '   ';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, equals('Please enter a valid email'));
      });

      test('should handle email with numbers only', () {
        // Arrange
        const email = '123@456.789';

        // Act
        final result = EmailValidator.validate(email);

        // Assert
        expect(result, isNull);
      });

      test('should reject completely malformed inputs', () {
        // Test various malformed inputs
        expect(EmailValidator.validate('not an email'), isNotNull);
        expect(EmailValidator.validate('missing.at.symbol'), isNotNull);
        expect(EmailValidator.validate('@nodomain'), isNotNull);
        expect(EmailValidator.validate('no@domain@allowed.com'), isNotNull);
      });

      test('should accept common real-world email formats', () {
        // Test common real-world email formats
        expect(EmailValidator.validate('john.doe@company.com'), isNull);
        expect(EmailValidator.validate('jane_smith@example.org'), isNull);
        expect(EmailValidator.validate('contact+spam@website.co'), isNull);
        expect(EmailValidator.validate('admin@localhost.local'), isNull);
      });
    });
  });
}
