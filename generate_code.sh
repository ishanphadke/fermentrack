#!/bin/bash

# Code Generation Script for Fermentrack
# This script runs build_runner to generate:
# - Freezed files (.freezed.dart)
# - JSON serialization files (.g.dart)
# - Mockito mock files (.mocks.dart)
# - Riverpod provider files (.g.dart)

set -e

echo "🔧 Starting code generation for Fermentrack..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "📦 Step 1: Getting dependencies..."
flutter pub get

echo ""
echo "🏗️  Step 2: Running build_runner..."
echo "This will generate .freezed.dart, .g.dart, and .mocks.dart files"
echo ""

# Run build_runner with delete-conflicting-outputs flag
# This ensures any existing generated files are properly replaced
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Code generation complete!"
echo ""
echo "Generated files:"
echo "  - lib/models/project.freezed.dart"
echo "  - lib/models/project.g.dart"
echo "  - lib/middleware/auth/providers/auth_providers.g.dart"
echo "  - lib/middleware/auth/routing/router.g.dart"
echo "  - lib/middleware/projects/providers/project_providers.g.dart"
echo "  - test/**/*.mocks.dart files"
echo ""
echo "🧪 You can now run tests with: flutter test"
