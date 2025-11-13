# Fermentrack Quick Start Guide

## Initial Setup (One-time)

```bash
# 1. Clone the repository (if not already done)
git clone https://github.com/ishanphadke/fermentrack.git
cd fermentrack

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate required code files
./generate_code.sh

# 4. Run the app
flutter run
```

## Daily Development Workflow

### Start Development
```bash
# Open watch mode for automatic code generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

Keep this running in a terminal. It will automatically regenerate files when you modify source files.

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/project_test.dart

# Run tests with coverage
flutter test --coverage
```

### Check Code Quality
```bash
# Analyze for errors
flutter analyze

# Format code
dart format .

# Check formatting without changing files
dart format --set-exit-if-changed .
```

### Rebuild Everything (if needed)
```bash
flutter clean
flutter pub get
./generate_code.sh
```

## Common Commands

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install/update dependencies |
| `./generate_code.sh` | Generate all code files |
| `flutter pub run build_runner build --delete-conflicting-outputs` | Manual code generation |
| `flutter pub run build_runner watch` | Auto-regenerate on file changes |
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter analyze` | Check for code issues |
| `dart format .` | Format all Dart files |
| `flutter run` | Run app on connected device |
| `flutter run -d chrome` | Run app in Chrome |
| `flutter clean` | Clean build artifacts |

## Git Workflow

```bash
# 1. Create a new branch
git checkout -b feature/your-feature-name

# 2. Make changes and test
# ... edit files ...
./generate_code.sh
flutter test

# 3. Stage and commit
git add .
git commit -m "Description of changes"

# 4. Push to remote
git push -u origin feature/your-feature-name

# 5. Create PR on GitHub
```

## Troubleshooting

### "Cannot find .freezed.dart or .g.dart"
```bash
./generate_code.sh
```

### "Conflicting outputs"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Tests failing
```bash
# 1. Regenerate code
./generate_code.sh

# 2. Check for errors
flutter analyze

# 3. Run tests again
flutter test
```

### App won't build
```bash
# Clean and rebuild
flutter clean
flutter pub get
./generate_code.sh
flutter run
```

## Project Structure

```
fermentrack/
├── lib/
│   ├── models/              # Data models (Freezed)
│   ├── middleware/
│   │   ├── services/        # Business logic services
│   │   └── projects/
│   │       └── providers/   # Riverpod state management
│   └── frontend/
│       ├── features/        # Feature-based screens
│       └── shared/          # Shared widgets
├── test/                    # Test files mirror lib/
├── generate_code.sh         # Code generation script
├── CODE_GENERATION.md       # Detailed code gen guide
├── TESTING.md               # Testing guide
└── CLAUDE.md                # Project engineering guidelines
```

## Important Files

- **pubspec.yaml**: Dependencies configuration
- **analysis_options.yaml**: Linter and analyzer rules
- **build.yaml**: Code generation configuration
- **.gitignore**: Files to exclude from git (includes generated files)
- **generate_code.sh**: Convenience script for code generation

## Getting Help

1. Check documentation:
   - `CODE_GENERATION.md` - Code generation details
   - `TESTING.md` - Testing guide
   - `CLAUDE.md` - Project conventions

2. Online resources:
   - [Flutter Documentation](https://docs.flutter.dev/)
   - [Riverpod Documentation](https://riverpod.dev/)
   - [Freezed Package](https://pub.dev/packages/freezed)

3. Community:
   - [Flutter Discord](https://discord.gg/flutter)
   - [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

## Tips for Success

✅ **Always run code generation before testing**
✅ **Use watch mode during active development**
✅ **Never edit generated files**
✅ **Run `flutter analyze` before committing**
✅ **Write tests alongside your code**
✅ **Follow the project conventions in CLAUDE.md**
✅ **Keep generated files out of git**

## Next Steps

1. Read `CLAUDE.md` for project engineering guidelines
2. Review `CODE_GENERATION.md` for in-depth code gen info
3. Check `TESTING.md` for testing best practices
4. Explore the codebase structure
5. Start building features!

Happy coding! 🚀
