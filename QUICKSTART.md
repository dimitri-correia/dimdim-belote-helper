# Quick Start Guide

## Prerequisites
- Flutter SDK 3.0.0 or higher
- For Android: Android SDK and Android Studio
- For Web: Chrome or other modern browser
- For Linux: Linux development tools
- For macOS: Xcode

## Installation

1. Clone the repository:
```bash
git clone https://github.com/dimitri-correia/dimdim-belote-helper.git
cd dimdim-belote-helper
```

2. Install dependencies:
```bash
flutter pub get
```

## Running the App

### Web (Recommended for quick testing)
```bash
flutter run -d chrome
```

### Linux
```bash
flutter run -d linux
```

### Android
```bash
# Connect an Android device or start an emulator
flutter run -d android
```

### macOS
```bash
flutter run -d macos
```

## Testing

Run all tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/carte_test.dart
```

## Code Quality

Analyze code:
```bash
flutter analyze
```

## Building for Production

### Web
```bash
flutter build web
```
Output: `build/web/`

### Android APK
```bash
flutter build apk
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Linux
```bash
flutter build linux
```
Output: `build/linux/x64/release/bundle/`

### macOS
```bash
flutter build macos
```
Output: `build/macos/Build/Products/Release/`

## Using the App

1. **Start**: Click "Nouvelle partie" on the welcome screen

2. **Settings**: Configure your game:
   - Choose end condition (points or plis)
   - Set the target value
   - Select your position at the table
   - Choose rotation direction

3. **Distribution**: Select exactly 8 cards from the available deck

4. **Enchères**: Make your bids:
   - Pass if you don't want to bid
   - Announce with value + color
   - Contre an opposing team's bid
   - Surcontré after a contre

## Project Structure

```
lib/
├── main.dart              # Entry point and home screen
├── models/                # Data models
│   ├── annonce.dart      # Bidding announcements
│   ├── carte.dart        # Cards
│   ├── etat_jeu.dart     # Game state
│   └── position.dart     # Player positions
└── screens/              # UI screens
    ├── distribution_screen.dart
    ├── encheres_screen.dart
    └── parametres_screen.dart
```

## Troubleshooting

### "Flutter command not found"
Make sure Flutter is installed and in your PATH:
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Dependencies issues
Clean and reinstall:
```bash
flutter clean
flutter pub get
```

### Build issues
Update Flutter:
```bash
flutter upgrade
```

## Development Tips

1. Use hot reload during development (press 'r' in terminal)
2. Use hot restart for state changes (press 'R' in terminal)
3. Check the Flutter DevTools for debugging
4. Run tests before committing changes

## Contributing

1. Create a new branch for your feature
2. Make your changes
3. Run tests and ensure they pass
4. Run `flutter analyze` to check for issues
5. Commit your changes with clear messages
6. Create a pull request

## Support

For issues or questions:
- Check the GUIDE.md for detailed documentation
- Check the IMPLEMENTATION.md for technical details
- Review the README.md for general information

## License

This project is open source.