import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../middleware/auth/providers/auth_providers.dart';

/// **Dashboard Screen**
///
/// This is the main protected screen that users see after authentication.
/// It demonstrates how to:
/// - Access authenticated user information
/// - Display user-specific data
/// - Handle sign-out functionality
/// - Use GoRouter for navigation
///
/// **Learning Points for New Developers:**
/// - **ConsumerWidget**: Riverpod widget that can read providers
/// - **Protected Route**: Only accessible when authenticated
/// - **Auth State Access**: Reading user info from auth providers
/// - **Sign Out Flow**: Proper logout handling with navigation
///
/// This is a simple implementation for testing the routing system.
/// In a real app, this would show user projects, recent activity, etc.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user display name from provider
    final displayName = ref.watch(userDisplayNameProvider);
    final userEmail = ref.watch(userEmailProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              // Show confirmation dialog
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              // If user confirmed, sign out
              if (shouldSignOut == true && context.mounted) {
                try {
                  await authService.signOut();
                  // GoRouter will automatically redirect to login via redirect logic
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              const Icon(
                Icons.dashboard,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome, $displayName!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (userEmail != null)
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              // Info card about protected routes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Protected Route',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'You can only see this screen because you are authenticated. '
                        'GoRouter automatically protects this route and redirects '
                        'unauthenticated users to the login screen.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Sign out button (alternative to app bar)
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await authService.signOut();
                    // GoRouter will automatically redirect to login
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error signing out: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}