import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/frontend/utils/password_validator.dart';

/// Unit tests for PasswordValidator utility class
///
/// These tests verify the password validation logic in isolation,
/// separate from UI integration tests in signup_screen_test.dart.
///
/// Test coverage:
/// - validate() method for all password criteria
/// - calculateStrength() for various password combinations
/// - getStrengthLabel() returns correct labels
/// - getStrengthColor() returns correct colors
/// - Edge cases (null, empty, special characters)
void main() {
  group('PasswordValidator', () {
    group('validate() method', () {
      test('should return null for valid strong password', () {
        // Arrange
        const password = 'StrongPass123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull);
      });

      test('should return error for null password', () {
        // Arrange
        const String? password = null;

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, equals('Please enter a password'));
      });

      test('should return error for empty password', () {
        // Arrange
        const password = '';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, equals('Please enter a password'));
      });

      test('should return error for password shorter than 8 characters', () {
        // Arrange
        const password = 'Pass1!'; // Only 6 characters

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, equals('Password must be at least 8 characters'));
      });

      test('should return error for password without uppercase letter', () {
        // Arrange
        const password = 'password123!'; // No uppercase

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(
          result,
          equals('Password must contain at least one uppercase letter'),
        );
      });

      test('should return error for password without lowercase letter', () {
        // Arrange
        const password = 'PASSWORD123!'; // No lowercase

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(
          result,
          equals('Password must contain at least one lowercase letter'),
        );
      });

      test('should return error for password without digit', () {
        // Arrange
        const password = 'Password!'; // No digit

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, equals('Password must contain at least one digit'));
      });

      test('should return error for password without special character', () {
        // Arrange
        const password = 'Password123'; // No special character

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(
          result,
          equals('Password must contain at least one special character'),
        );
      });

      test('should accept password with all required criteria', () {
        // Arrange
        const password = 'MySecure123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull);
      });

      test('should accept password with multiple special characters', () {
        // Arrange
        const password = 'Test@Pass#123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull);
      });

      test('should accept exactly 8 character password with all criteria', () {
        // Arrange
        const password = 'Pass123!'; // Exactly 8 characters

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull);
      });
    });

    group('calculateStrength() method', () {
      test('should return 0 for empty password', () {
        // Arrange
        const password = '';

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(0));
      });

      test('should return 1 for password with only lowercase', () {
        // Arrange
        const password = 'abc'; // Only lowercase, no length

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(1)); // Only lowercase criterion
      });

      test('should return 2 for password with length and lowercase', () {
        // Arrange
        const password = 'password'; // Length + lowercase

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(2)); // Length + lowercase
      });

      test('should return 3 for password with upper, lower, and digit', () {
        // Arrange
        const password =
            'Abc123'; // Upper + lower + digit (no length, no special)

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(3)); // Upper + lower + digit
      });

      test('should return 4 for password missing one criterion', () {
        // Arrange
        const password = 'Password123'; // Missing special char

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(4)); // Length + upper + lower + digit
      });

      test('should return 5 for strong password with all criteria', () {
        // Arrange
        const password = 'StrongPass123!';

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(5)); // All criteria met
      });

      test('should return 5 for very long strong password', () {
        // Arrange
        const password = 'VeryLongAndStrongPassword123!@#';

        // Act
        final strength = PasswordValidator.calculateStrength(password);

        // Assert
        expect(strength, equals(5)); // All criteria met (max is 5)
      });
    });

    group('getStrengthLabel() method', () {
      test('should return "Weak" for strength 0', () {
        // Act
        final label = PasswordValidator.getStrengthLabel(0);

        // Assert
        expect(label, equals('Weak'));
      });

      test('should return "Weak" for strength 1', () {
        // Act
        final label = PasswordValidator.getStrengthLabel(1);

        // Assert
        expect(label, equals('Weak'));
      });

      test('should return "Medium" for strength 2', () {
        // Act
        final label = PasswordValidator.getStrengthLabel(2);

        // Assert
        expect(label, equals('Medium'));
      });

      test('should return "Medium" for strength 3', () {
        // Act
        final label = PasswordValidator.getStrengthLabel(3);

        // Assert
        expect(label, equals('Medium'));
      });

      test('should return "Strong" for strength 4', () {
        // Act
        final label = PasswordValidator.getStrengthLabel(4);

        // Assert
        expect(label, equals('Strong'));
      });

      test('should return "Strong" for strength 5', () {
        // Act
        final label = PasswordValidator.getStrengthLabel(5);

        // Assert
        expect(label, equals('Strong'));
      });
    });

    group('getStrengthColor() method', () {
      test('should return Colors.red for strength 0', () {
        // Act
        final color = PasswordValidator.getStrengthColor(0);

        // Assert
        expect(color, equals(Colors.red));
      });

      test('should return Colors.red for strength 1', () {
        // Act
        final color = PasswordValidator.getStrengthColor(1);

        // Assert
        expect(color, equals(Colors.red));
      });

      test('should return Colors.orange for strength 2', () {
        // Act
        final color = PasswordValidator.getStrengthColor(2);

        // Assert
        expect(color, equals(Colors.orange));
      });

      test('should return Colors.orange for strength 3', () {
        // Act
        final color = PasswordValidator.getStrengthColor(3);

        // Assert
        expect(color, equals(Colors.orange));
      });

      test('should return Colors.green for strength 4', () {
        // Act
        final color = PasswordValidator.getStrengthColor(4);

        // Assert
        expect(color, equals(Colors.green));
      });

      test('should return Colors.green for strength 5', () {
        // Act
        final color = PasswordValidator.getStrengthColor(5);

        // Assert
        expect(color, equals(Colors.green));
      });
    });

    group('Edge cases and special scenarios', () {
      test('should handle password with spaces', () {
        // Arrange
        const password = 'Pass Word 123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull); // Spaces are allowed
      });

      test('should handle password with unicode characters', () {
        // Arrange
        const password = 'Pässwörd123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull); // Unicode is allowed
      });

      test('should handle password with all special characters', () {
        // Arrange
        const password = 'Test!@#\$%^&*()123';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result, isNull);
      });

      test('should correctly calculate strength for edge case passwords', () {
        // Test boundary case: exactly 8 chars with minimal criteria
        expect(PasswordValidator.calculateStrength('Pass123!'), equals(5));

        // Test very short but complex password
        expect(PasswordValidator.calculateStrength('Aa1!'), equals(4));

        // Test long but simple password
        expect(
          PasswordValidator.calculateStrength('passwordpassword'),
          equals(2),
        );
      });
    });
  });
}
