/// Email validation utility class
///
/// This utility provides reusable email validation logic that can be used
/// across multiple features (login, signup, password reset, profile, etc.).
///
/// Key features:
/// - RegExp-based validation for email format
/// - Consistent error messages across the app
/// - Simple, single-responsibility design
///
/// Example usage:
/// ```dart
/// // In a TextFormField validator
/// validator: (value) => EmailValidator.validate(value),
///
/// // Or with custom error messages
/// validator: (value) {
///   if (value == null || value.isEmpty) {
///     return 'Email is required';
///   }
///   return EmailValidator.validate(value);
/// },
/// ```
class EmailValidator {
  // Private constructor to prevent instantiation
  EmailValidator._();

  // REGEX PATTERN FOR EMAIL VALIDATION

  /// RegExp for basic email format validation
  ///
  /// This pattern checks for:
  /// - At least one non-whitespace character before @
  /// - @ symbol
  /// - At least one non-whitespace character after @ and before .
  /// - . (dot) symbol
  /// - At least one non-whitespace character after the final dot
  /// - No whitespace allowed anywhere in the email
  ///
  /// Note: This is a simple validation pattern. For production apps,
  /// consider using a more comprehensive pattern or the email_validator package.
  /// However, Firebase Auth will perform the final validation on the server.
  static final _emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  // VALIDATION METHOD

  /// Validates an email address format
  ///
  /// Checks:
  /// - Email is not null or empty
  /// - Email contains @ symbol (basic check)
  /// - Email matches a simple email pattern
  ///
  /// Parameters:
  /// - [email]: The email string to validate
  ///
  /// Returns:
  /// - `null` if email is valid
  /// - Error message string if email is invalid
  ///
  /// Example:
  /// ```dart
  /// String? error = EmailValidator.validate('invalid');
  /// // Returns: 'Please enter a valid email'
  ///
  /// String? error = EmailValidator.validate('user@example.com');
  /// // Returns: null (valid)
  /// ```
  static String? validate(String? email) {
    // Check if email is empty
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }

    // Check basic @ presence (quick fail-fast check)
    if (!email.contains('@')) {
      return 'Please enter a valid email';
    }

    // Check email format with regex
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    // All checks passed
    return null;
  }

  /// Validates email format with a simple @ check only
  ///
  /// This is a lighter validation that only checks for @ symbol presence.
  /// Useful for scenarios where you want minimal client-side validation
  /// and rely on server-side validation (Firebase Auth).
  ///
  /// Parameters:
  /// - [email]: The email string to validate
  ///
  /// Returns:
  /// - `null` if email contains @
  /// - Error message string if email is invalid
  ///
  /// Example:
  /// ```dart
  /// String? error = EmailValidator.validateSimple('user@domain');
  /// // Returns: null (contains @)
  /// ```
  static String? validateSimple(String? email) {
    // Check if email is empty
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }

    // Check basic @ presence
    if (!email.contains('@')) {
      return 'Please enter a valid email';
    }

    // Passed simple check
    return null;
  }
}
