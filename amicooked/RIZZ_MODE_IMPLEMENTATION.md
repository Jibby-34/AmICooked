# Rizz Mode Implementation

## Overview
Added a "Rizz Mode" to the app that transforms the theme from fire/cooked to purple/dating/attraction theme.

## Features Implemented

### 1. Rizz Mode State Management
- Created `RizzModeService` using ChangeNotifier for state management
- Persistent storage using SharedPreferences
- Accessible throughout the app via Provider

### 2. UI Changes

#### Home Screen
- **Toggle Switch**: Added in top right corner to switch between modes
  - Shows "💜 Rizz Mode" or "🔥 Cooked Mode"
- **Title Changes**:
  - Cooked Mode: "🔥 Am I Cooked?"
  - Rizz Mode: "💜 Rizz or Miss?"
- **Subtitle Changes**:
  - Cooked Mode: "Paste it. Screenshot it. Face the truth."
  - Rizz Mode: "Check your game. Measure your charm. Know your rizz."
- **Button Text**:
  - Cooked Mode: "Am I Cooked?"
  - Rizz Mode: "Check My Rizz"
- **Typing Examples**: Different placeholder text for each mode
  - Cooked examples: embarrassing situations
  - Rizz examples: dating/attraction scenarios
- **Colors**: Purple gradient in rizz mode (AppTheme.rizzPurple*)

#### Loading Screen
- **Different Quips**:
  - Cooked Mode: Kitchen/cooking themed ("🔍 Consulting the kitchen...")
  - Rizz Mode: Dating themed ("💜 Calculating charm levels...")
- **Purple Theme**: Border and progress indicator colors change

#### Results Screen
- **Meter Label**:
  - Cooked Mode: "COOKED"
  - Rizz Mode: "RIZZ LEVEL"
- **Interpretation**: In rizz mode, high percentage is good (opposite of cooked mode)
- **Emojis**: Different emojis for rizz mode (💜, 😍, 😊, etc.)
- **Button Text**:
  - Cooked Mode: "Save Me"
  - Rizz Mode: "Level Up"
- **Colors**: Purple borders and backgrounds

### 3. Ember/Flame Animation
- Updated `EmberPainter` to use purple colors in rizz mode
- Purple shades: `rizzPurpleDeep`, `rizzPurpleMid`, `rizzPurpleLight`

### 4. Theme Colors
Added new purple color palette to `AppTheme`:
```dart
static const Color rizzPurpleLight = Color(0xFFE0BBE4);
static const Color rizzPurpleMid = Color(0xFFC77DFF);
static const Color rizzPurpleDark = Color(0xFF9D4EDD);
static const Color rizzPurpleDeep = Color(0xFF7209B7);
static const Color rizzPurpleAccent = Color(0xFFD896FF);
```

### 5. API Integration
- Added `rizzMode` parameter to POST request
- Sent as boolean in request body: `{ "rizzMode": true }`

## Files Modified

1. **New Files**:
   - `lib/services/rizz_mode_service.dart`

2. **Modified Files**:
   - `lib/main.dart` - Added Provider setup
   - `lib/theme/app_theme.dart` - Added purple color palette
   - `lib/screens/home_screen.dart` - Added switch, rizz mode UI
   - `lib/screens/loading_screen.dart` - Added rizz mode quips and colors
   - `lib/screens/results_screen.dart` - Added rizz mode display
   - `lib/widgets/cooked_meter.dart` - Added "RIZZ LEVEL" label and purple colors
   - `lib/services/analysis_service.dart` - Added rizzMode parameter to API
   - `pubspec.yaml` - Added provider dependency

## Usage

Users can toggle between modes using the switch in the top right corner of the home screen. The selection is saved and persists across app restarts.

## API Contract

The backend now receives an additional parameter:
```json
{
  "text": "I told her she looked cute and she replied with \"haha thanks\" and nothing else.",
  "imageBase64": "/9j/4AAQSkZJRgABAQAAAQABAAD...FAKE_BASE64_DATA...==",
  "rizzMode": true
}
```

The backend should interpret results differently when `rizzMode` is true:
- High percentages = good rizz/attraction
- Verdicts should be about dating success/attraction rather than being "cooked"

