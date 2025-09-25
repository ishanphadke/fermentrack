# Fermentrack - The Smart Fermentation Companion

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.2+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Firebase-Backend-orange.svg" alt="Firebase Backend">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green.svg" alt="Platforms">
  <img src="https://img.shields.io/badge/License-Private-red.svg" alt="License">
</p>

A modern, cross-platform mobile application designed for fermentation enthusiasts, from home cooks to serious hobbyists. Built with Flutter and powered by Firebase/GCP backend.

## 🎯 Vision

To provide a seamless and reliable experience for managing fermentation projects with data-driven insights, elevating the craft from guesswork to science.

## ✨ Features

### Free Tier
- **User Account Management** - Secure authentication via Firebase
- **Project Dashboard** - Central view of all active projects (up to 4)
- **Fermentation Templates** - Pre-built templates for common projects
- **Task Management** - Customizable steps with automated reminders
- **Manual Data Entry** - Log temperature, pH, weight, and specific gravity
- **Notes & Photos** - Visual progress tracking with photo logs

### Premium Tier
- **Unlimited Projects** - No limits on active or archived projects
- **Bluetooth Sensor Integration** - Real-time pH and temperature monitoring
- **Data Visualization** - Interactive charts and trend analysis
- **Advanced Analytics** - Fermentation milestone insights
- **Cloud Sync & Backup** - Cross-device synchronization
- **Data Export** - CSV export for external analysis

## 🏗️ Architecture

```
Flutter App (iOS/Android) ←→ Bluetooth pH/Temp Sensor
        ↓                           (Premium)
Firebase/Google Cloud Platform
├── Firebase Authentication
├── Cloud Firestore
├── Cloud Storage
└── Cloud Functions
```

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.9.2+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase/GCP
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Cloud Storage
- **Push Notifications**: Firebase Cloud Messaging
- **Bluetooth**: flutter_blue_plus

## 📁 Project Structure

```
fermentrack/
├── lib/
│   ├── core/           # Core utilities and configurations
│   ├── features/       # Feature-based modules
│   ├── services/       # Business logic services
│   ├── shared/         # Shared widgets and utilities
│   ├── models/         # Data models
│   └── main.dart       # App entry point
├── test/               # Test files
└── pubspec.yaml        # Dependencies
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2+
- Dart SDK 3.0+
- Firebase CLI
- FlutterFire CLI

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fermentation-app/fermentrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI tools
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli

   # Configure Firebase for your project
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **Enable required Firebase services**:
   - Authentication (Email/Password, Google)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Messaging

2. **Set up your IDE**:
   - Install Flutter and Dart plugins
   - Configure code formatting (analysis_options.yaml)

## 📋 Development Phases

### Phase 1: Foundation & Core Features (6-8 weeks) ✅
- [x] Project setup and Firebase integration
- [x] User authentication system
- [ ] Project management and dashboard
- [ ] Notifications and data logging
- [ ] UI/UX polish

### Phase 2: Premium Features (5-7 weeks)
- [ ] Subscription management
- [ ] Bluetooth sensor integration
- [ ] Real-time data streaming
- [ ] Data visualization

### Phase 3: Testing & Refinement (3-4 weeks)
- [ ] QA testing and bug fixes
- [ ] Beta testing program
- [ ] Performance optimization

### Phase 4: Launch (1-2 weeks)
- [ ] App store preparation
- [ ] Official launch

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests (when available)
flutter test integration_test/
```

## 🎯 Target Audience

- Sourdough bakers
- Homebrewers (beer, mead, cider)
- Kombucha and water kefir brewers
- Vegetable fermenters (kimchi, sauerkraut, pickles)
- Artisanal cheese and yogurt makers

## 💰 Monetization

**Freemium Model**:
- Free tier with core functionality and project limits
- Premium subscription ($5.99/month or $59.99/year) for advanced features

## 📊 Key Metrics

- Project limit (Free): 4 active projects
- Target platforms: iOS and Android
- Estimated development: 15-21 weeks
- Backend: Scalable Firebase infrastructure

## 🤝 Contributing

This is currently a private project. Please refer to the development team for contribution guidelines.

## 📄 License

This project is proprietary software. All rights reserved.

## 🔗 Documentation

- [Project Proposal](proposal.md) - Detailed project vision and requirements
- [Phase 1 Guide](phase1.md) - Step-by-step development guide
- [CLAUDE.md](CLAUDE.md) - Engineering guidelines and best practices

## 📞 Support

For development questions or technical support, please contact the development team.

---

Built with ❤️ for the fermentation community
