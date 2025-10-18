// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Router Provider**
///
/// This provider creates and configures the GoRouter instance for the entire app.
/// It sets up all routes, handles authentication-based redirects, and ensures
/// users can only access routes they're authorized to see.
///
/// **Learning Points for New Developers:**
/// - **Declarative Routing**: Routes defined as a configuration tree
/// - **Authentication Guards**: Automatic redirect logic based on auth state
/// - **AsyncValue Handling**: Properly handling loading, data, and error states
/// - **Route Protection**: Keeping unauthenticated users out of protected areas
///
/// **Route Structure:**
/// - Public routes: /login, /signup, /reset-password (accessible without auth)
/// - Protected routes: /dashboard, /profile (require authentication)
///
/// **Redirect Logic:**
/// - Loading state: Allow current route (avoid redirect loops)
/// - Unauthenticated + protected route: Redirect to /login
/// - Authenticated + auth route: Redirect to /dashboard
/// - Error state: Redirect to /login (fail-safe)
///
/// **Usage in main.dart:**
/// ```dart
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final router = ref.watch(routerProvider);
///
///     return MaterialApp.router(
///       routerConfig: router,
///       // ... other config
///     );
///   }
/// }
/// ```

@ProviderFor(router)
const routerProvider = RouterProvider._();

/// **Router Provider**
///
/// This provider creates and configures the GoRouter instance for the entire app.
/// It sets up all routes, handles authentication-based redirects, and ensures
/// users can only access routes they're authorized to see.
///
/// **Learning Points for New Developers:**
/// - **Declarative Routing**: Routes defined as a configuration tree
/// - **Authentication Guards**: Automatic redirect logic based on auth state
/// - **AsyncValue Handling**: Properly handling loading, data, and error states
/// - **Route Protection**: Keeping unauthenticated users out of protected areas
///
/// **Route Structure:**
/// - Public routes: /login, /signup, /reset-password (accessible without auth)
/// - Protected routes: /dashboard, /profile (require authentication)
///
/// **Redirect Logic:**
/// - Loading state: Allow current route (avoid redirect loops)
/// - Unauthenticated + protected route: Redirect to /login
/// - Authenticated + auth route: Redirect to /dashboard
/// - Error state: Redirect to /login (fail-safe)
///
/// **Usage in main.dart:**
/// ```dart
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final router = ref.watch(routerProvider);
///
///     return MaterialApp.router(
///       routerConfig: router,
///       // ... other config
///     );
///   }
/// }
/// ```

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// **Router Provider**
  ///
  /// This provider creates and configures the GoRouter instance for the entire app.
  /// It sets up all routes, handles authentication-based redirects, and ensures
  /// users can only access routes they're authorized to see.
  ///
  /// **Learning Points for New Developers:**
  /// - **Declarative Routing**: Routes defined as a configuration tree
  /// - **Authentication Guards**: Automatic redirect logic based on auth state
  /// - **AsyncValue Handling**: Properly handling loading, data, and error states
  /// - **Route Protection**: Keeping unauthenticated users out of protected areas
  ///
  /// **Route Structure:**
  /// - Public routes: /login, /signup, /reset-password (accessible without auth)
  /// - Protected routes: /dashboard, /profile (require authentication)
  ///
  /// **Redirect Logic:**
  /// - Loading state: Allow current route (avoid redirect loops)
  /// - Unauthenticated + protected route: Redirect to /login
  /// - Authenticated + auth route: Redirect to /dashboard
  /// - Error state: Redirect to /login (fail-safe)
  ///
  /// **Usage in main.dart:**
  /// ```dart
  /// class MyApp extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     final router = ref.watch(routerProvider);
  ///
  ///     return MaterialApp.router(
  ///       routerConfig: router,
  ///       // ... other config
  ///     );
  ///   }
  /// }
  /// ```
  const RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'f16ef7dd800cb263fb328ed272ea8d8778fdfad9';
