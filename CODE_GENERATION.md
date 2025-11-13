# Code Generation Guide

Fermentrack uses code generation extensively to reduce boilerplate and ensure type safety. This document explains the code generation setup and how to use it.

## Overview

The project uses the following code generation tools:

| Tool | Purpose | Files Generated |
|------|---------|-----------------|
| **Freezed** | Immutable data models | `*.freezed.dart` |
| **json_serializable** | JSON serialization | `*.g.dart` |
| **Riverpod Generator** | State management providers | `*.g.dart` |
| **Mockito** | Test mocks | `*.mocks.dart` |

## Quick Start

### One-Time Setup

1. Ensure Flutter is installed:
   ```bash
   flutter --version
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Generate Code

**Option 1: Use the provided script (Recommended)**
```bash
./generate_code.sh
```

**Option 2: Manual generation**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Option 3: Watch mode (for active development)**
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Generated Files

After running code generation, you should see:

```
lib/
  models/
    project.dart
    project.freezed.dart ← Generated
    project.g.dart ← Generated
  middleware/
    auth/
      providers/
        auth_providers.dart
        auth_providers.g.dart ← Generated
      routing/
        router.dart
        router.g.dart ← Generated
    projects/
      providers/
        project_providers.dart
        project_providers.g.dart ← Generated

test/
  models/
    project_test.mocks.dart ← Generated
  middleware/
    services/
      firestore_service_test.mocks.dart ← Generated
    projects/
      providers/
        project_providers_test.mocks.dart ← Generated
```

## Code Generation by Feature

### 1. Freezed (Immutable Models)

**Purpose**: Create immutable data classes with copyWith, equality, toString

**Annotation**: `@freezed`

**Example**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required String name,
    required ProjectType type,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
```

**Generates**: `project.freezed.dart` with copyWith, ==, hashCode, toString

### 2. JSON Serialization

**Purpose**: Convert Dart objects to/from JSON

**Annotation**: Automatic with Freezed + `fromJson` factory

**Example**:
```dart
// Automatically generates toJson/fromJson methods
final project = Project(name: 'Test', type: ProjectType.sourdough);
final json = project.toJson();
final restored = Project.fromJson(json);
```

**Generates**: `project.g.dart` with `_$ProjectFromJson` and `toJson`

### 3. Riverpod Providers

**Purpose**: Generate type-safe providers for state management

**Annotation**: `@riverpod`

**Example**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'project_providers.g.dart';

@riverpod
FirestoreService firestoreService(Ref ref) {
  return FirestoreService();
}

@riverpod
Stream<List<Project>> userProjects(Ref ref) {
  // Provider implementation
}
```

**Generates**: `project_providers.g.dart` with provider definitions

### 4. Mockito Test Mocks

**Purpose**: Generate mock classes for testing

**Annotation**: `@GenerateMocks([ClassToMock])`

**Example**:
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firestore_service_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference])
void main() {
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
  });

  // Use mocks in tests
}
```

**Generates**: `firestore_service_test.mocks.dart` with mock classes

## Configuration

### build.yaml

The `build.yaml` file configures build_runner:

- **Performance**: Specifies which files need generation
- **Options**: Sets defaults for generators (e.g., `explicit_to_json: true`)
- **Exclusions**: Prevents processing already-generated files

### analysis_options.yaml

Contains analyzer configuration:

```yaml
analyzer:
  errors:
    invalid_annotation_target: ignore  # Required for Freezed 3.0+
```

## Troubleshooting

### Problem: "No such file or directory: .freezed.dart"

**Solution**: Run code generation
```bash
./generate_code.sh
```

### Problem: "Conflicting outputs were detected"

**Solution**: Use --delete-conflicting-outputs
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: Generation is very slow

**Solution 1**: Use watch mode instead of rebuilding
```bash
flutter pub run build_runner watch
```

**Solution 2**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: Generated files have errors

**Solution**: Ensure source files are correct first
```bash
flutter analyze
```

Then regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: Mocks not generating

**Solution**: Check `@GenerateMocks` annotation is correct and import statement exists
```dart
@GenerateMocks([ClassToMock])
void main() { ... }

import 'your_test.mocks.dart';  // Import AFTER @GenerateMocks
```

## Best Practices

### 1. Never Commit Generated Files
Generated files are in `.gitignore`:
```
*.g.dart
*.freezed.dart
*.mocks.dart
```

### 2. Run Generation Before Testing
Always generate before running tests:
```bash
./generate_code.sh
flutter test
```

### 3. Use Watch Mode During Development
Keep build_runner watching for changes:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 4. Keep Source Files Clean
- Don't modify generated files
- Only edit source files (without .g.dart, .freezed.dart suffixes)
- Generated files will be recreated

### 5. CI/CD Integration
In your CI/CD pipeline:
```yaml
jobs:
  test:
    steps:
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter test
```

## When to Regenerate

Regenerate code when you:
- ✅ Add/modify a Freezed model
- ✅ Change JSON serialization annotations
- ✅ Add/modify Riverpod providers
- ✅ Add new `@GenerateMocks` in tests
- ✅ Pull changes from git that affect these files
- ✅ See "file not found" errors for `.g.dart` files

Don't need to regenerate when you:
- ❌ Only modify UI code (widgets, screens)
- ❌ Only modify regular Dart files without annotations
- ❌ Only change styles or constants

## Performance Tips

1. **Specify target files** in build.yaml to avoid processing everything
2. **Use watch mode** during active development
3. **Clean rarely** - only when necessary
4. **Cache build_runner** output between CI runs

## Resources

- [build_runner Documentation](https://pub.dev/packages/build_runner)
- [Freezed Package](https://pub.dev/packages/freezed)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [Riverpod Generator](https://pub.dev/packages/riverpod_generator)
- [Mockito](https://pub.dev/packages/mockito)

## Getting Help

If you encounter issues:
1. Check this guide
2. See `TESTING.md` for test-specific issues
3. Review the [Flutter Discord](https://discord.gg/flutter) #code-generation channel
4. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter+code-generation)
