import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fermentrack/providers/auth/auth_providers.dart';
import 'package:fermentrack/services/auth_service.dart';

/// Password Reset screen for sending password reset emails
///
/// This is a beginner-level training exercise that demonstrates:
/// - Simple form implementation with single field
/// - Email validation with TextFormField
/// - Async operation handling with loading states
/// - User feedback with SnackBar messages
/// - Success state handling and form clearing
/// - Firebase Authentication password reset flow
/// - Navigation between authentication screens
///
/// Part of Sub-Issue 2.1.5: Create Password Reset Screen
/// Difficulty: Beginner
/// Learning objectives: Form validation, async operations, user feedback, Firebase Auth
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  // FORM CONTROLLERS AND STATE

  /// GlobalKey for managing form validation state
  /// Used to trigger validation on the email field
  final _formKey = GlobalKey<FormState>();

  /// Controller for email text field
  /// Manages the email input value and provides access for validation
  final _emailController = TextEditingController();

  /// Loading state flag
  /// Controls UI state during async password reset operation
  /// - true: Shows loading spinner, disables send button
  /// - false: Shows normal send button, enables interaction
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Instructional text to guide the user
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
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
              const SizedBox(height: 24),
              // Send Reset Email Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handlePasswordReset,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Email'),
              ),
              const SizedBox(height: 16),
              // Navigation back to Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LIFECYCLE METHODS

  /// Clean up controller when widget is disposed
  /// Prevents memory leaks by disposing TextEditingController
  /// This is called automatically when the widget is removed from the tree
  @override
  void dispose() {
    _emailController.dispose();
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

  // BUSINESS LOGIC METHODS

  /// Handles the password reset process
  ///
  /// This method demonstrates:
  /// - Form validation using _formKey.currentState!.validate()
  /// - Loading state management with setState()
  /// - Async operation handling with try-catch-finally
  /// - mounted check to prevent setState() on disposed widgets
  /// - Riverpod provider usage (ref.read)
  /// - Firebase Authentication password reset integration
  /// - User feedback with SnackBar messages
  /// - Error handling with AuthException
  /// - Form clearing after successful submission
  ///
  /// Flow:
  /// 1. Validate email field
  /// 2. Set loading state to true
  /// 3. Get AuthService from Riverpod provider
  /// 4. Call sendPasswordResetEmail method
  /// 5. Show success message (always, for security)
  /// 6. Clear the email field
  /// 7. Handle errors appropriately
  /// 8. Reset loading state in finally block
  void _handlePasswordReset() async {
    // Step 1: Validate email field
    // _formKey.currentState!.validate() calls validator() on the TextFormField
    // Returns true if validator returns null, false if it returns an error string
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

        // Step 4: Perform Firebase password reset operation
        // Note: Firebase doesn't reveal if the email exists (security best practice)
        await authService.sendPasswordResetEmail(
          _emailController.text.trim(),
        );

        // Step 5: Handle success case
        // Check if widget is still mounted before accessing context
        // This prevents errors if user navigated away during async operation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Password reset email sent! Please check your inbox.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Step 6: Clear the email field after successful submission
          // This provides visual feedback that the action completed
          _emailController.clear();
        }
      } on AuthException catch (e) {
        // Step 7a: Handle authentication-specific errors
        // AuthException contains user-friendly error messages
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Step 7b: Handle unexpected errors
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
        // Step 8: Reset loading state
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
