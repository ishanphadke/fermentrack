# Fermentrack: Phase 1

This document outlines the concrete steps for Phase 1: Foundation & Core Features, as detailed in the project proposal. Each step includes links to relevant documentation and examples to guide development.

---

### Milestone 1: Project Setup & Configuration (1 Week)

1.  **Initialize Flutter Project:**
    -   **1.1. Create a new Flutter project:**
        -   Run `flutter create fermentrack` in your terminal.
        -   **Docs:** [Flutter `create` command](https://docs.flutter.dev/reference/flutter-cli)
    -   **1.2. Establish the directory structure:**
        -   Inside the `lib` folder, create the following directories: `features`, `core`, `services`, `shared`, `models`.
        -   This structure helps separate concerns and organize your code.
        -   **Reference:** [Example Flutter Project Structures](https://docs.flutter.dev/app-architecture/guide)

2.  **Setup Firebase Project:**
    -   **2.1. Create a Firebase project:**
        -   Go to the Firebase Console and create a new project.
        -   **Docs:** Create a Firebase Project
    -   **2.2. Enable required services:**
        -   **Authentication:** In the Firebase console, go to Authentication -> Sign-in method and enable **Email/Password** and **Google**.
            -   **Docs:** Enable Sign-in Methods
        -   **Cloud Firestore:** Go to Firestore Database -> Create database. Start in **Test Mode** for initial development.
            -   **Docs:** Get started with Cloud Firestore
        -   **Cloud Storage:** Go to Storage -> Get started. Follow the prompts to set up the default bucket.
            -   **Docs:** Get started with Cloud Storage
        -   **Cloud Messaging (FCM):** No initial setup needed in the console for basic client-side handling, but you can find your server key under Project Settings -> Cloud Messaging if needed later.
            -   **Docs:** About FCM
    -   **2.3. Integrate Firebase with the Flutter app:**
        -   Install the Firebase CLI: `npm install -g firebase-tools` and `dart pub global activate flutterfire_cli`.
        -   Run `flutterfire configure` in your project root to automatically configure your app for Android, iOS, and web.
        -   **Docs:** Add Firebase to your Flutter app

3.  **Dependency Management:**
    -   **3.1. Add Firebase packages:**
        -   Run `flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage firebase_messaging`.
        -   **Docs:** These will be added to your `pubspec.yaml` by `flutterfire configure`, but you can add them manually if needed.
    -   **3.2. Add State Management:**
        -   Run `flutter pub add flutter_riverpod riverpod_annotation`.
        -   **Docs:** Riverpod Official Documentation
    -   **3.3. Add Navigation:**
        -   Run `flutter pub add go_router`.
        -   **Docs:** GoRouter Package and Declarative routing with GoRouter
    -   **3.4. Add Utility Packages:**
        -   Run `flutter pub add intl`.
        -   **Docs:** Intl Package

### Milestone 2: Core Feature Implementation (4-5 Weeks)

1.  **Authentication Flow:**
    -   **1.1. Implement UI Screens:**
        -   Create `login_screen.dart`, `signup_screen.dart`, and `password_reset_screen.dart` inside `lib/features/auth/presentation/`.
        -   Use `TextFormField` for inputs and `ElevatedButton` for actions.
        -   **Docs:** Building forms with validation
    -   **1.2. Develop `AuthService`:**
        -   Create `auth_service.dart` in `lib/services/`.
        -   Implement methods: `signInWithEmail`, `signUpWithEmail`, `signInWithGoogle`, `signOut`, `sendPasswordResetEmail`.
        -   **Docs:** Email & Password Auth, Google Sign-In
    -   **1.3. Create Riverpod Providers for Auth:**
        -   Create `auth_providers.dart` in `lib/features/auth/application/`.
        -   Create a `Provider` for your `AuthService`.
        -   Create a `StreamProvider` that listens to `FirebaseAuth.instance.authStateChanges()` to track the current user globally.
        -   **Docs:** StreamProvider, Combining Providers
    -   **1.4. Set up Protected Routing:**
        -   Configure `GoRouter` with a `redirect` logic that checks the auth state from your Riverpod provider. If the user is not logged in, redirect them to `/login`.
        -   **Docs:** GoRouter Redirects

2.  **Project & Dashboard:**
    -   **2.1. Define Data Models:**
        -   Create `project.dart` and `fermentation_task.dart` in `lib/models/`.
        -   Define classes with properties, and include `toJson`/`fromJson` methods for Firestore serialization.
        -   **Docs:** Structuring Cloud Firestore Data, Serializing JSON in Dart
    -   **2.2. Implement `FirestoreService`:**
        -   Create `firestore_service.dart` in `lib/services/`.
        -   Implement CRUD (Create, Read, Update, Delete) methods for projects and tasks (e.g., `getProjectsStream`, `addProject`, `updateProject`, `deleteProject`).
        -   **Docs:** Get realtime updates, Add and manage data
    -   **2.3. Build the Dashboard UI:**
        -   Create `dashboard_screen.dart` in `lib/features/projects/presentation/`.
        -   Use a Riverpod `StreamProvider` to fetch projects from `FirestoreService`.
        -   Use a `ConsumerWidget` to listen to the provider and display the data in a `ListView.builder`.
        -   **Docs:** Displaying lists, ListView.builder class
    -   **2.4. Create Add/Edit Project UI:**
        -   Create `add_edit_project_screen.dart`.
        -   Build a form to input project details (name, start date, etc.).
        -   On save, call the appropriate `FirestoreService` method.

3.  **Notifications & Logging:**
    -   **3.1. Implement `NotificationService`:**
        -   Create `notification_service.dart` in `lib/services/`.
        -   Use `firebase_messaging` to request notification permissions from the user.
        -   Set up handlers for foreground, background, and terminated messages.
        -   **Docs:** Requesting permissions (Apple), Handling messages
    -   **3.2. Develop Data Entry UI:**
        -   Create a `project_details_screen.dart`.
        -   Within this screen, add a form or section for users to log new entries (temperature, pH, notes).
        -   Add a button to trigger photo uploads.
    -   **3.3. Connect Photo Uploads to Cloud Storage:**
        -   Use a package like `image_picker` to select photos from the camera or gallery.
        -   In your `FirestoreService` or a new `StorageService`, create a method to upload the file to Firebase Storage.
        -   Store the download URL from Storage in the corresponding Firestore document.
        -   **Docs:** Upload files with Cloud Storage, image_picker package

### Milestone 3: Refinement & Foundation for Premium (1-2 Weeks)

1.  **UI/UX Polish:**
    -   **1.1. Implement App Theme:**
        -   Define a `ThemeData` object with your app's color scheme and typography.
        -   Apply it to the `MaterialApp` widget.
        -   **Docs:** Themes Cookbook
    -   **1.2. Create Shared Widgets:**
        -   In `lib/shared/widgets/`, create reusable components like `CustomButton`, `CustomTextField`, `LoadingSpinner`.
        -   This ensures a consistent look and feel and reduces code duplication.
        -   **Docs:** Creating custom widgets
    -   **1.3. Ensure Responsiveness:**
        -   Use widgets like `LayoutBuilder`, `MediaQuery`, and `FittedBox` to adapt your UI to different screen sizes.
        -   Test on various emulators (phone, tablet).
        -   **Docs:** Creating responsive apps

2.  **Prepare for Premium:**
    -   **2.1. Add Future Dependencies:**
        -   Run `flutter pub add flutter_blue_plus` for Bluetooth functionality.
        -   Run `flutter pub add purchases_flutter` for in-app purchases via RevenueCat.
        -   **Docs:** flutter_blue_plus, purchases_flutter
    -   **2.2. Create Placeholder Services:**
        -   Create `bluetooth_service.dart` and `subscription_service.dart` in `lib/services/`.
        -   Define the classes with empty methods (e.g., `Future<void> connectToDevice(String id) {}`).
        -   This sets up the architectural foundation for Phase 2 without needing to implement the full logic now.