import 'package:flutter/material.dart';

/// Login screen for user authentication
///
/// This is a beginner-level training exercise that demonstrates:
/// - Form validation with GlobalKey<FormState>
/// - TextFormField usage with validators
/// - Loading state management
/// - Async operation handling with mounted check
/// - Basic Material Design principles
///
/// Part of Sub-Issue 2.1.1: Create Basic Login Screen UI
/// Difficulty: Beginner
/// Learning objectives: Flutter form widgets, validation, state management
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      body: Form(
        key: _formKey,
        child: Column(
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
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
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
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
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to password reset (Sub-Issue 2.1.5)
                    debugPrint('Navigate to password reset');
                  },
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to signup (Sub-Issue 2.1.4)
                    debugPrint('Navigate to signup');
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ],
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
  /// - User feedback with SnackBar messages
  ///
  /// Flow:
  /// 1. Validate form fields
  /// 2. Set loading state to true
  /// 3. Simulate async login operation (will be replaced with real AuthService)
  /// 4. Show success/error feedback
  /// 5. Reset loading state in finally block
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
        // Step 3: Perform login operation
        // TODO: Call AuthService here (will be implemented in Sub-Issue 2.1.2)
        // For now, simulate network delay with Future.delayed
        await Future.delayed(const Duration(seconds: 2)); // Mock delay

        // Step 4a: Handle success case
        // Check if widget is still mounted before accessing context
        // This prevents errors if user navigated away during async operation
        if (mounted) {
          // TODO: Navigate to dashboard (will be implemented in Sub-Issue 2.1.7)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        }
      } catch (e) {
        // Step 4b: Handle error case
        // Show error message to user if login fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.toString()}')),
          );
        }
      } finally {
        // Step 5: Reset loading state
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
