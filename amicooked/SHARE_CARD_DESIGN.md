# Shareable Card Visual Design Reference

## Layout Structure

```
┌────────────────────────────────────────────────┐
│                                                │
│          🔥 Am I Cooked?                       │
│                                                │
│                                                │
│              ╭───────────╮                     │
│             │   ┌─────┐  │                     │
│             │  │       │ │                     │
│             │ │   85%   │ │                    │
│             │  │COOKED │ │                     │
│             │   └─────┘  │                     │
│              ╰───────────╯                     │
│                                                │
│                                                │
│        🔥  You're Absolutely Cooked            │
│                                                │
│                                                │
│   ┌──────────────────────────────────────┐    │
│   │  ✨ Key Highlights                   │    │
│   │                                       │    │
│   │  • First key point from analysis      │    │
│   │                                       │    │
│   │  • Second key point from analysis     │    │
│   │                                       │    │
│   └──────────────────────────────────────┘    │
│                                                │
│                                                │
│     ✨ Made with "Am I Cooked?" app           │
│                                                │
└────────────────────────────────────────────────┘
```

## Dimensions

- **Width**: 1080px (Instagram post standard)
- **Height**: Variable (auto-adjusts to content)
- **Padding**: 48px all around
- **Aspect Ratio**: Approximately 4:5 (vertical)

## Color Schemes by Result

### Very Cooked (80-100%)
```
Background: Black → Dark Red gradient
Meter Color: Red (#FF3B30)
Border Color: Red (#FF3B30)
```

### Cooked (60-79%)
```
Background: Black → Dark Orange gradient
Meter Color: Deep Orange (#FF5722)
Border Color: Deep Orange (#FF5722)
```

### Warning (40-59%)
```
Background: Black → Dark Orange gradient
Meter Color: Orange (#FF9800)
Border Color: Orange (#FF9800)
```

### Caution (20-39%)
```
Background: Black → Dark Yellow gradient
Meter Color: Yellow (#FFEB3B)
Border Color: Yellow (#FFEB3B)
```

### Safe (0-19%)
```
Background: Black → Dark Green gradient
Meter Color: Green (#4CAF50)
Border Color: Green (#4CAF50)
```

## Typography

### Header ("Am I Cooked?")
- **Font Size**: 42px
- **Font Weight**: Bold
- **Color**: White (#FFFFFF)
- **Letter Spacing**: 1.5px

### Percentage Display
- **Font Size**: 80px
- **Font Weight**: Bold
- **Color**: Dynamic (based on percentage)

### "COOKED" Label
- **Font Size**: 24px
- **Font Weight**: Bold
- **Color**: Gray (#B0B0B0)
- **Letter Spacing**: 4px

### Verdict Text
- **Font Size**: 38px
- **Font Weight**: Bold
- **Color**: White (#FFFFFF)
- **Max Lines**: 2

### Highlights Section
- **Title Font Size**: 26px
- **Content Font Size**: 22px
- **Line Height**: 1.5
- **Color**: White (#FFFFFF)

### Watermark
- **Font Size**: 20px
- **Font Weight**: 500
- **Color**: Gray (#B0B0B0)

## Component Spacing

```
Header to Meter: 60px
Meter to Verdict: 48px
Verdict to Highlights: 40px
Highlights to Watermark: 60px
Watermark to Bottom: 24px
```

## Circular Meter Details

```
┌─────────────────────┐
│                     │
│    ╭─────────╮      │
│   │  ┌─────┐  │     │
│  │  │  85%  │  │    │
│  │  │COOKED │  │    │
│   │  └─────┘  │     │
│    ╰─────────╯      │
│                     │
└─────────────────────┘
```

- **Outer Diameter**: 300px
- **Stroke Width**: 28px
- **Background Circle**: Dark gray (#1A1A1A)
- **Progress Circle**: Dynamic color
- **Start Angle**: -90° (top)
- **Direction**: Clockwise
- **Cap Style**: Round

## Highlights Box Details

```
┌────────────────────────────────────┐
│  ✨ Key Highlights                │
│                                    │
│  •  First highlight text goes     │
│     here and can wrap to          │
│     multiple lines                │
│                                    │
│  •  Second highlight text         │
│                                    │
└────────────────────────────────────┘
```

- **Padding**: 32px all around
- **Border Radius**: 24px
- **Border Width**: 3px
- **Border Color**: Dynamic (based on percentage)
- **Background**: Semi-transparent black (80% opacity)
- **Bullet Style**: Circular dots (10px diameter)
- **Bullet-to-Text Spacing**: 16px

## Watermark Details

```
┌────────────────────────────────────┐
│  ✨ Made with "Am I Cooked?" app  │
└────────────────────────────────────┘
```

- **Padding**: 16px vertical, 24px horizontal
- **Border Radius**: 12px
- **Background**: Semi-transparent black (60% opacity)
- **Icon Size**: 24px
- **Icon-to-Text Spacing**: 12px

## Visual Effects

### Gradients
- **Direction**: Top-left to bottom-right
- **Smoothness**: Linear blend
- **Opacity**: Background color at 10-15%

### Borders
- **Style**: Solid
- **Width**: 2-3px
- **Color**: Matches meter color

### Shadows
None (clean, flat design)

## Content Extraction Rules

### Highlights
1. Split explanation by sentence boundaries (. ! ?)
2. Take first 2 sentences
3. If only 1-2 sentences total, use all
4. Trim whitespace
5. Display as bullet points

### Text Overflow
- Verdict: Max 2 lines, ellipsis
- Highlights: No ellipsis, full text shown
- Watermark: Single line, no wrap

## Export Settings

```
Format: PNG
Pixel Ratio: 3.0 (high DPI)
Quality: Maximum
Color Space: sRGB
Alpha Channel: No
```

## File Naming Convention

```
am_i_cooked_result_[timestamp].png

Example:
am_i_cooked_result_1703786459230.png
```

## Accessibility Notes

- High contrast text (white on dark)
- Large font sizes (minimum 20px)
- Clear visual hierarchy
- Icon + text for watermark
- Color is not the only indicator (text/numbers reinforce meaning)

## Social Media Compatibility

### Instagram
- ✅ Feed Post: 1080x1350px (4:5) - Supported
- ✅ Story: Can be shared, user crops
- ✅ Reels: Can be shared, user adjusts

### Twitter/X
- ✅ Standard: Auto-resizes well
- ✅ Preview: Shows full image

### Facebook
- ✅ Feed: Shows full image
- ✅ Stories: User crops

### Messages/WhatsApp
- ✅ Full quality maintained
- ✅ Preview renders correctly

## Sample Content Examples

### High Cooked (95%)
```
Verdict: "You're Absolutely Cooked"
Emoji: 💀
Highlights:
- Your message reads like a desperate plea
- Recovery is impossible at this point
```

### Medium Cooked (55%)
```
Verdict: "Getting Pretty Warm"
Emoji: 😰
Highlights:
- Some concerning phrases detected
- Still salvageable with edits
```

### Low Cooked (15%)
```
Verdict: "You're Chillin'"
Emoji: ✅
Highlights:
- Professional and well-composed
- Nothing to worry about here
```

---

## Implementation Notes

The card is rendered using Flutter's widget system and captured as a high-resolution PNG. All measurements are in logical pixels, which scale appropriately across devices. The design is optimized for mobile screens but renders well at any size.

The watermark ensures brand visibility while remaining subtle and professional. All text is rendered using the app's existing theme for consistency.


