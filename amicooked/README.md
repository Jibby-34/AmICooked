# 🔥 Am I Cooked?

A fun, dramatic Flutter app that judges how "cooked" you are based on text or screenshots you provide. Built with a mobile-first approach, featuring smooth animations and a fire/heat aesthetic.

## Features

- **Text Analysis**: Paste any message, email, DM, or code snippet
- **Screenshot Upload**: Upload images to analyze
- **Dramatic Animations**: 
  - Glowing button effects
  - Animated loading screen with cycling messages
  - Smooth meter fill animations
  - Page transitions
- **Visual Feedback**: Beautiful circular "Cooked Meter" with color-coded results
- **Dark Theme**: Eye-friendly dark mode with fire-themed gradient accents

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── cooked_result.dart         # Data model for analysis results
├── screens/
│   ├── home_screen.dart           # Main input screen
│   ├── loading_screen.dart        # Animated loading/judgment screen
│   └── results_screen.dart        # Results display with verdict
├── services/
│   └── analysis_service.dart      # Analysis logic (currently mock)
├── theme/
│   └── app_theme.dart             # App-wide theme configuration
└── widgets/
    └── cooked_meter.dart          # Animated circular progress indicator
```

## Tech Stack

- **Flutter SDK**: ^3.10.3
- **Dependencies**:
  - `image_picker`: ^1.0.7 - For screenshot uploads
  - `cupertino_icons`: ^1.0.8 - iOS-style icons

## Getting Started

### Prerequisites

- Flutter SDK installed ([Installation Guide](https://docs.flutter.dev/get-started/install))
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)
- An emulator or physical device

### Installation

1. Navigate to the project directory:
```bash
cd amicooked
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## How It Works

### User Flow

1. **Home Screen**: User pastes text or uploads a screenshot
2. **Loading Screen**: Animated loading messages build anticipation
3. **Results Screen**: Dramatic reveal of the "cooked" percentage with explanation

### Mock AI Analysis

The app currently uses a mock analysis service (`lib/services/analysis_service.dart`) that:
- Simulates a 2-second processing delay
- Generates random "cooked" percentages
- Adjusts scores based on simple text heuristics
- Provides humorous verdicts and explanations

### Integrating Real AI

To integrate a real AI API, modify `lib/services/analysis_service.dart`:

```dart
Future<CookedResult> analyzeInput({
  String? text,
  File? image,
  String mode = 'general',
}) async {
  // Replace the mock logic with actual API call
  final response = await http.post(
    Uri.parse('YOUR_AI_API_ENDPOINT'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'text': text,
      'image': image != null ? base64Encode(image.readAsBytesSync()) : null,
      'mode': mode,
    }),
  );
  
  return CookedResult.fromJson(jsonDecode(response.body));
}
```

## Design Philosophy

### Visual Theme
- **Dark Mode First**: Near-black backgrounds for OLED-friendly display
- **Fire Aesthetic**: Red, orange, and yellow accents
- **Dramatic Typography**: Bold, impactful text
- **Smooth Animations**: All transitions feel polished and intentional

### Color Palette
- Primary Black: `#0A0A0A`
- Secondary Black: `#1A1A1A`
- Flame Red: `#FF3B30`
- Flame Orange: `#FF9500`
- Flame Yellow: `#FFCC00`

### Animations
- **Button Glow**: Pulsing effect when input is present
- **Meter Fill**: Smooth color-coded fill from green to red
- **Loading States**: Cycling text with fade transitions
- **Page Transitions**: Slide and fade effects

## Future Features (Stubs)

The following features are stubbed out for future implementation:

- **🔥 Save Me**: AI-powered rewrite suggestions
- **📱 Share**: Share your verdict to social media
- **🎯 Mode Selection**: Analyze in different contexts (school, work, dating, etc.)

## Contributing

This is an MVP ready for further development. Key areas for enhancement:

1. Real AI integration
2. Share functionality
3. Rewrite suggestions
4. Context mode selection
5. History/saved results
6. More sophisticated analysis

## License

This project is built as an MVP demonstration.

---

Made with 🔥 and Flutter
