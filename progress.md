# Fermentrack: Next Steps for Development

This document outlines the concrete steps for Phase 1: Foundation & Core Features, as detailed in the project proposal.

---

### Milestone 1: Project Setup & Configuration (1 Week)

1.  **Initialize Flutter Project: [COMPLETED]**
    -   Created a new Flutter project.
    -   Established the directory structure as outlined in `README.md`.

2.  **Setup Firebase Project:**
    -   Create a new project in the Firebase console.
    -   Configure and enable required services:
        -   **Authentication:** Enable Email/Password and Google Sign-In providers.
        -   **Cloud Firestore:** Initialize in Test Mode for development.
        -   **Cloud Storage:** Set up default bucket.
        -   **Cloud Messaging (FCM):** Note server keys for later use.
    -   Integrate Firebase with the Flutter app using `flutterfire_cli`. Add `firebase_core`, `firebase_auth`, and `cloud_firestore` to `pubspec.yaml`.

3.  **Dependency Management:**
    -   Add essential packages to `pubspec.yaml`:
        -   `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`
        -   `flutter_riverpod` (for state management)
        -   `go_router` (for navigation)
        -   `intl` (for date/time formatting)

### Milestone 2: Core Feature Implementation (4-5 Weeks)

1.  **Authentication Flow:**
    -   Implement UI for Login, Sign-Up, and Password Reset screens.
    -   Develop `AuthService` to handle all Firebase Authentication logic.
    -   Create state management providers (Riverpod) to manage user auth state globally.
    -   Set up routing logic to direct users to the Dashboard on login or the Login screen if logged out.

2.  **Project & Dashboard:**
    -   Define data models (`Project`, `FermentationTask`) in Dart.
    -   Implement `FirestoreService` for CRUD operations on projects and tasks.
    -   Build the Dashboard UI to display a list of active projects.
    -   Create UI for adding/editing a new project, including custom tasks and steps.

3.  **Notifications & Logging:**
    -   Implement `NotificationService` to request permissions and handle basic push notifications via FCM.
    -   Develop UI within the project details screen for manual data entry (temperature, pH, notes) and photo uploads.
    -   Connect photo uploads to `Firebase Cloud Storage`.

### Milestone 3: Refinement & Foundation for Premium (1-2 Weeks)

1.  **UI/UX Polish:**
    -   Implement the app's theme (colors, typography).
    -   Create shared widgets for consistent UI (e.g., custom buttons, input fields).
    -   Ensure the app is responsive and looks good on various screen sizes.

2.  **Prepare for Premium:**
    -   Add the `flutter_blue_plus` and `purchases_flutter` (RevenueCat) packages to `pubspec.yaml`.
    -   Create placeholder services (`BluetoothService`, `SubscriptionService`) to be implemented in Phase 2. This ensures the architecture is ready for the new features.