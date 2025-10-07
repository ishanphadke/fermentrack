import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fermentrack/core/features/auth/presentation/signup_screen.dart';
import 'package:fermentrack/core/features/auth/presentation/password_reset_screen.dart';
import 'package:fermentrack/core/utils/email_validator.dart';
import 'package:fermentrack/providers/auth/auth_providers.dart';
import 'package:fermentrack/services/auth_service.dart';

/// Login screen for user authentication
///
/// This is a beginner-level training exercise that demonstrates:
/// - Form validation with `GlobalKey<FormState>`
/// - TextFormField usage with validators
/// - Loading state management
/// - Async operation handling with mounted check
/// - Riverpod integration for state management
/// - Firebase Authentication integration
/// - Basic Material Design principles
///
/// Part of Sub-Issue 2.1.1: Create Basic Login Screen UI
/// Difficulty: Beginner
/// Learning objectives: Flutter form widgets, validation, state management, Riverpod
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  /// Loading state flag
  /// Controls UI state during async login operation
  /// - true: Shows loading spinner, disables login button
  /// - false: Shows normal login button, enables interaction
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: EmailValidator.validate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // No length requirement for login - Firebase will validate
                  // Only signup enforces password strength requirements
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              // Divider with OR text
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              // Google Sign-In Button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.login, size: 24),
                label: const Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordResetScreen(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
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
    super.dispose();
  }

  // BUSINESS LOGIC METHODS

  /// Handles the login process
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
  ///
  /// Flow:
  /// 1. Validate form fields
  /// 2. Set loading state to true
  /// 3. Get AuthService from Riverpod provider
  /// 4. Call signInWithEmail method
  /// 5. Show success/error feedback
  /// 6. Reset loading state in finally block
  void _handleLogin() async {
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

        // Step 4: Perform Firebase login operation
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Step 5a: Handle success case
        // Check if widget is still mounted before accessing context
        // This prevents errors if user navigated away during async operation
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          // TODO: Navigate to dashboard (will be implemented in Sub-Issue 2.1.7)
          // The authStateProvider will automatically update and trigger navigation
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

  /// Handles Google Sign-In process
  ///
  /// This method demonstrates:
  /// - Third-party authentication integration
  /// - Handling user cancellation (null result)
  /// - Loading state management
  /// - Error handling for OAuth flow
  /// - User feedback with SnackBar
  ///
  /// Flow:
  /// 1. Set loading state
  /// 2. Call AuthService.signInWithGoogle()
  /// 3. Handle null (user cancelled)
  /// 4. Handle success
  /// 5. Handle errors
  /// 6. Reset loading state
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      // Perform Google Sign-In
      final user = await authService.signInWithGoogle();

      // Handle user cancellation
      if (user == null) {
        debugPrint('Google Sign-In cancelled by user');
        return; // Don't show error, user intentionally cancelled
      }

      // Handle success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In successful!')),
        );
        // Navigation will be handled by authStateProvider
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
