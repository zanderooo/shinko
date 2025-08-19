# Shinkō (進行)

<div align="center">

# 🎋 Shinkō - 進行

**Aesthetic, elegant, and addictive gamification app for habits, productivity, studying, and self-improvement**

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-blue.svg)](https://flutter.dev)

</div>

## ✨ Features

### 🎯 Core Functionality
- **Habit Creation** - Add daily habits, study sessions, or personal goals
- **Daily Streaks** - Track consecutive days of habit completion
- **XP/Level System** - Gain experience points and level up through consistent progress
- **Achievement System** - Unlock rewards and achievements as you grow
- **Progress Tracking** - Visual charts and statistics for long-term growth
- **Local Notifications** - Gentle reminders to maintain your habits
- **Daily Dashboard** - Central hub for today's tasks and streaks

### 🎨 Japanese-Inspired Design
- **Dark Theme** with purple accents and neon glow effects
- **Glass-like Cards** with subtle transparency and rounded corners
- **Minimalist Typography** using Material 3 design principles
- **Smooth Animations** and transitions throughout the app
- **No External Assets** - All UI generated purely in Flutter code

### 🎮 Gamification Elements
- **Positive Reinforcement** - Confetti effects and glowing feedback
- **Streak Pressure** - "Don't break the chain" motivation
- **Progress Visualization** - XP bars and level progression
- **Achievement Unlocks** - Milestone celebrations
- **Daily Perfect Days** - Track days when all habits are completed

## 📱 Screenshots

*Screenshots will be added here once the app is complete*

| Daily Dashboard | Habit Creation | Progress Charts | Achievements |
|-----------------|----------------|------------------|--------------|
| *Coming Soon*  | *Coming Soon*  | *Coming Soon*    | *Coming Soon* |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/shinko.git
   cd shinko
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ Full Support | Primary target platform |
| iOS      | ✅ Compatible   | Tested on iOS 14+ |
| Web      | ✅ Compatible   | Basic functionality |

## 🏗️ Architecture

The app follows **Clean Architecture** with MVVM pattern:

```
lib/
├── src/
│   ├── core/                 # Core utilities and constants
│   ├── data/                 # Data layer (repositories, models)
│   ├── domain/               # Domain layer (entities, use cases)
│   └── presentation/         # Presentation layer (UI, providers)
│       ├── providers/        # State management with Provider
│       ├── screens/          # Individual screens
│       └── theme/            # App theming and styling
└── main.dart                 # App entry point
```

### Tech Stack

- **State Management**: Provider pattern
- **Local Storage**: SQLite with sqflite
- **Charts**: fl_chart for progress visualization
- **Notifications**: flutter_local_notifications
- **Animations**: Built-in Flutter animations
- **Icons**: Material Icons (no external icon packs)

## 🎯 Usage Guide

### Adding Your First Habit

1. Open the app and tap the **+** button
2. Enter a habit name (e.g., "Morning Meditation")
3. Select a category and difficulty level
4. Save your habit
5. Complete it daily to build your streak!

### Understanding XP and Levels

- **Easy habits**: 10 XP per completion
- **Medium habits**: 20 XP per completion  
- **Hard habits**: 30 XP per completion
- **Expert habits**: 50 XP per completion

Level progression follows an exponential curve, making each level more meaningful.

### Achievements System

| Achievement | Requirement | Reward |
|-------------|-------------|---------|
| First Steps | Create your first habit | 50 XP |
| Week Warrior | 7-day streak | 100 XP |
| Habit Master | Complete 50 habits | 200 XP |
| Perfect Day | Complete all daily habits | Varies |

## 🛠️ Development

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/habit_provider_test.dart

# Generate coverage report
flutter test --coverage
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Code Style

The project uses:
- **Flutter Lints** for code analysis
- **Effective Dart** style guide
- **Consistent naming conventions**
- **Comprehensive documentation**

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code of Conduct

Please note that this project follows a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

## 📊 Project Status

- ✅ Core architecture
- ✅ Data models
- ✅ State management
- ✅ Japanese-inspired UI theme
- ✅ Daily dashboard
- ✅ Habit creation and management
- ✅ Gamification features
- ✅ Sample data and seed content
- 🔄 Progress charts (in development)
- 🔄 Local notifications (in development)
- 🔄 Advanced animations (in development)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Japanese Design Philosophy** for minimalist inspiration
- **Gamification Research** for behavior design principles
- **Open Source Community** for continuous support

## 📞 Support

If you have any questions or need help:

- 📧 Email: [your-email@example.com](mailto:your-email@example.com)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/shinko/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/shinko/discussions)

---

<div align="center">

**Made with ❤️ and Flutter**

*進行 (Shinkō) - Progress through dedication*

</div>
