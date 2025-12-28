# 🔥 Am I Cooked?

A fun, dramatic Flutter app that judges how "cooked" you are based on text or screenshots you provide. Built with a mobile-first approach, featuring smooth animations and a fire/heat aesthetic.

## Features

- **Text Analysis**: Paste any message, email, DM, or code snippet
- **Screenshot Upload**: Upload images to analyze
- **Share Feature**: Generate and share beautiful, branded images of your results
  - Includes cooked percentage, verdict, and key highlights
  - Instagram-optimized dimensions
  - Watermarked with app branding
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
│   ├── analysis_service.dart      # AI analysis integration
│   └── share_service.dart         # Share functionality
├── theme/
│   └── app_theme.dart             # App-wide theme configuration
└── widgets/
    ├── cooked_meter.dart          # Animated circular progress indicator
    └── shareable_result_card.dart # Beautiful share card widget
```

## Tech Stack

- **Flutter SDK**: ^3.10.3
- **Dependencies**:
  - `image_picker`: ^1.0.7 - For screenshot uploads
  - `screenshot`: ^3.0.0 - For generating shareable images
  - `share_plus`: ^10.1.2 - For native sharing functionality
  - `path_provider`: ^2.1.5 - For temporary file storage
  - `http`: ^1.2.0 - For API communication
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
4. **Share**: Tap share to generate a beautiful branded image and share to social media

### Share Feature

The app includes a comprehensive share feature that generates visually appealing images:
- Captures a specially designed `ShareableResultCard` widget
- Includes cooked percentage, verdict, and key highlights
- Branded with "Made with 'Am I Cooked?' app" watermark
- Optimized for social media sharing (Instagram, etc.)

See [SHARE_FEATURE.md](SHARE_FEATURE.md) for detailed documentation.

### Mock AI Analysis

The app uses AI integration via a Cloudflare Worker proxy (`lib/services/analysis_service.dart`) that:
- Connects to Google's Gemini API
- Analyzes text and images for "cooked" level
- Provides humorous verdicts and explanations
- Supports both text and image inputs

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

## Future Features

The following features are planned or stubbed out for future implementation:

- **🔥 Save Me**: AI-powered rewrite suggestions (stub)
- **🎯 Mode Selection**: Analyze in different contexts (school, work, dating, etc.)
- **📊 History**: View past analyses
- **🎨 Customizable Share Cards**: Different templates and styles

## Contributing

This is an MVP ready for further development. Key areas for enhancement:

1. Enhanced AI integration with more analysis modes
2. Rewrite suggestions feature
3. Context mode selection
4. History/saved results
5. More sophisticated analysis
6. Customizable share card templates
7. Analytics and insights

## License

This project is built as an MVP demonstration.

---

Made with 🔥 and Flutter
