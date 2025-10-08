import 'package:flutter/material.dart';

/// Password validation utility class
///
/// This utility provides reusable password validation logic that can be used
/// across multiple features (signup, password reset, password change, etc.).
///
/// Key features:
/// - RegExp-based validation for password strength requirements
/// - Password strength calculation (0-5 scale)
/// - Helper methods for UI feedback (labels and colors)
///
/// Example usage:
/// ```dart
/// // In a TextFormField validator
/// validator: (value) => PasswordValidator.validate(value),
///
/// // Calculate strength for UI indicator
/// int strength = PasswordValidator.calculateStrength(password);
/// String label = PasswordValidator.getStrengthLabel(strength);
/// Color color = PasswordValidator.getStrengthColor(strength);
/// ```
class PasswordValidator {
  // Private constructor to prevent instantiation
  PasswordValidator._();

  // REGEX PATTERNS FOR PASSWORD VALIDATION

  /// RegExp for checking uppercase letters (A-Z)
  static final _uppercaseRegex = RegExp(r'[A-Z]');

  /// RegExp for checking lowercase letters (a-z)
  static final _lowercaseRegex = RegExp(r'[a-z]');

  /// RegExp for checking digits (0-9)
  static final _digitRegex = RegExp(r'[0-9]');

  /// RegExp for checking special characters
  static final _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  // VALIDATION METHOD

  /// Validates a password against strength requirements
  ///
  /// Requirements:
  /// - Not empty
  /// - At least 8 characters long
  /// - Contains at least one uppercase letter
  /// - Contains at least one lowercase letter
  /// - Contains at least one digit
  /// - Contains at least one special character
  ///
  /// Parameters:
  /// - [password]: The password string to validate
  ///
  /// Returns:
  /// - `null` if password is valid
  /// - Error message string if password is invalid
  ///
  /// Example:
  /// ```dart
  /// String? error = PasswordValidator.validate('weak');
  /// // Returns: 'Password must be at least 8 characters'
  ///
  /// String? error = PasswordValidator.validate('StrongPass123!');
  /// // Returns: null (valid)
  /// ```
  static String? validate(String? password) {
    // Check if password is empty
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }

    // Check minimum length
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for uppercase letter
    if (!_uppercaseRegex.hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letter
    if (!_lowercaseRegex.hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for digit
    if (!_digitRegex.hasMatch(password)) {
      return 'Password must contain at least one digit';
    }

    // Check for special character
    if (!_specialCharRegex.hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    // All checks passed
    return null;
  }

  // PASSWORD STRENGTH CALCULATION

  /// Calculates password strength score (0-5)
  ///
  /// Awards one point for each criterion met:
  /// - Length >= 8 characters (1 point)
  /// - Contains uppercase letter (1 point)
  /// - Contains lowercase letter (1 point)
  /// - Contains digit (1 point)
  /// - Contains special character (1 point)
  ///
  /// Parameters:
  /// - [password]: The password string to evaluate
  ///
  /// Returns:
  /// - `0`: Empty password
  /// - `1`: Very weak (only 1 criterion)
  /// - `2-3`: Medium strength
  /// - `4-5`: Strong password
  ///
  /// Example:
  /// ```dart
  /// int strength = PasswordValidator.calculateStrength('password');
  /// // Returns: 2 (has length and lowercase)
  ///
  /// int strength = PasswordValidator.calculateStrength('StrongPass123!');
  /// // Returns: 5 (all criteria met)
  /// ```
  static int calculateStrength(String password) {
    int strength = 0;

    // Award points for each criterion
    if (password.length >= 8) strength++;
    if (_uppercaseRegex.hasMatch(password)) strength++;
    if (_lowercaseRegex.hasMatch(password)) strength++;
    if (_digitRegex.hasMatch(password)) strength++;
    if (_specialCharRegex.hasMatch(password)) strength++;

    return strength;
  }

  // UI HELPER METHODS

  /// Gets the strength label for a given strength score
  ///
  /// Parameters:
  /// - [strength]: Password strength score (0-5)
  ///
  /// Returns:
  /// - `"Weak"` for strength 0-1
  /// - `"Medium"` for strength 2-3
  /// - `"Strong"` for strength 4-5
  ///
  /// Example:
  /// ```dart
  /// String label = PasswordValidator.getStrengthLabel(1);
  /// // Returns: "Weak"
  /// ```
  static String getStrengthLabel(int strength) {
    if (strength <= 1) {
      return 'Weak';
    } else if (strength <= 3) {
      return 'Medium';
    } else {
      return 'Strong';
    }
  }

  /// Gets the strength color for a given strength score
  ///
  /// Parameters:
  /// - [strength]: Password strength score (0-5)
  ///
  /// Returns:
  /// - `Colors.red` for strength 0-1 (Weak)
  /// - `Colors.orange` for strength 2-3 (Medium)
  /// - `Colors.green` for strength 4-5 (Strong)
  ///
  /// Example:
  /// ```dart
  /// Color color = PasswordValidator.getStrengthColor(5);
  /// // Returns: Colors.green
  /// ```
  static Color getStrengthColor(int strength) {
    if (strength <= 1) {
      return Colors.red;
    } else if (strength <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
