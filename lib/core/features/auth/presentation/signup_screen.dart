import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fermentrack/providers/auth/auth_providers.dart';
import 'package:fermentrack/services/auth_service.dart';
import 'package:fermentrack/core/utils/password_validator.dart';

/// Signup screen for user registration
///
/// This is a beginner-level training exercise that demonstrates:
/// - Multi-field form validation with `GlobalKey<FormState>`
/// - Password strength validation with RegExp
/// - Password confirmation matching validation
/// - Real-time visual feedback (password strength indicator)
/// - Loading state management
/// - Riverpod integration for state management
/// - Firebase Authentication integration
/// - Navigation between authentication screens
///
/// Part of Sub-Issue 2.1.4: Create Signup Screen UI
/// Difficulty: Beginner
/// Learning objectives: Form validation, RegExp, password strength, user feedback, Riverpod
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // FORM CONTROLLERS AND STATE

  /// GlobalKey for managing form validation state
  /// Used to trigger validation across all form fields
  final _formKey = GlobalKey<FormState>();

  /// Controller for email text field
  /// Manages the email input value and provides access for validation
  final _emailController = TextEditingController();

  /// Controller for password text field
  /// Manages the password input value and provides access for validation
  final _passwordController = TextEditingController();

  /// Controller for confirm password text field
  /// Manages the password confirmation input and provides access for validation
  final _confirmPasswordController = TextEditingController();

  /// Loading state flag
  /// Controls UI state during async signup operation
  /// - true: Shows loading spinner, disables signup button
  /// - false: Shows normal signup button, enables interaction
  bool _isLoading = false;

  /// Password strength score (0-5)
  /// Used to calculate and display password strength indicator
  /// 0: Empty, 1: Very weak, 2-3: Medium, 4-5: Strong
  /// Calculated using PasswordValidator.calculateStrength()
  int _passwordStrength = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: _validatePassword,
                onChanged: (value) {
                  // Update password strength in real-time using PasswordValidator
                  setState(() {
                    _passwordStrength = PasswordValidator.calculateStrength(value);
                  });
                },
              ),
              const SizedBox(height: 8),
              // Password Strength Indicator
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 16),
              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 24),
              // Create Account Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              // Navigation to Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LIFECYCLE METHODS

  /// Clean up controllers when widget is disposed
  /// Prevents memory leaks by disposing TextEditingControllers
  /// This is called automatically when the widget is removed from the tree
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // VALIDATION METHODS

  /// Validates email field
  ///
  /// Checks:
  /// - Email is not empty
  /// - Email contains @ symbol (basic format validation)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password field with strength requirements
  ///
  /// Delegates to PasswordValidator utility for validation logic.
  /// See PasswordValidator.validate() for detailed requirements.
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  String? _validatePassword(String? value) {
    return PasswordValidator.validate(value);
  }

  /// Validates confirm password field
  ///
  /// Checks:
  /// - Confirm password is not empty
  /// - Confirm password matches password field
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Builds password strength indicator widget
  ///
  /// Visual feedback showing password strength using PasswordValidator helpers:
  /// - Red: Weak (0-1 criteria met)
  /// - Orange: Medium (2-3 criteria met)
  /// - Green: Strong (4-5 criteria met)
  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get strength label and color from PasswordValidator utility
    final strengthColor = PasswordValidator.getStrengthColor(_passwordStrength);
    final strengthText = PasswordValidator.getStrengthLabel(_passwordStrength);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: _passwordStrength / 5,
              backgroundColor: Colors.grey[300],
              color: strengthColor,
              minHeight: 4,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            strengthText,
            style: TextStyle(
              color: strengthColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // BUSINESS LOGIC METHODS

  /// Handles the signup process
  ///
  /// This method demonstrates:
  /// - Form validation using _formKey.currentState!.validate()
  /// - Loading state management with setState()
  /// - Async operation handling with try-catch-finally
  /// - mounted check to prevent setState() on disposed widgets
  /// - Riverpod provider usage (ref.read)
  /// - Firebase Authentication integration
  /// - User feedback with SnackBar messages
  /// - Error handling with AuthException
  /// - Navigation after successful signup
  ///
  /// Flow:
  /// 1. Validate form fields
  /// 2. Set loading state to true
  /// 3. Get AuthService from Riverpod provider
  /// 4. Call signUpWithEmail method
  /// 5. Show success/error feedback
  /// 6. Navigate back to login on success
  /// 7. Reset loading state in finally block
  void _handleSignup() async {
    // Step 1: Validate all form fields
    // _formKey.currentState!.validate() calls validator() on each TextFormField
    // Returns true if all validators return null, false if any return error string
    if (_formKey.currentState!.validate()) {
      // Step 2: Set loading state to show spinner and disable button
      setState(() {
        _isLoading = true;
      });

      try {
        // Step 3: Get AuthService from Riverpod provider
        // ref.read is used for one-time reads (like calling a method)
        // ref.watch would be used for reactive updates
        final authService = ref.read(authServiceProvider);

        // Step 4: Perform Firebase signup operation
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Step 5a: Handle success case
        // Check if widget is still mounted before accessing context
        // This prevents errors if user navigated away during async operation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to login screen
          // Use pop() since signup is shown modally over login
          Navigator.pop(context);
        }
      } on AuthException catch (e) {
        // Step 5b: Handle authentication-specific errors
        // AuthException contains user-friendly error messages
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Step 5c: Handle unexpected errors
        // Show generic error message for any other exceptions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Step 6: Reset loading state
        // This runs regardless of success/failure
        // Always check mounted before calling setState()
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
