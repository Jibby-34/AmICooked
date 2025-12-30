# Share Feature Documentation

## Overview
The "Am I Cooked?" app includes a comprehensive share feature that allows users to share their results in a visually appealing format. The share feature generates a beautiful, branded image that includes:

- The user's "cooked" percentage with a circular meter
- An emoji and verdict headline
- Key highlights from the analysis
- A watermark: "Made with 'Am I Cooked?' app"

## Implementation Details

### Architecture

The share feature consists of three main components:

1. **ShareService** (`lib/services/share_service.dart`)
   - Handles screenshot generation using the `screenshot` package
   - Manages file saving to temporary storage
   - Coordinates sharing via the `share_plus` package
   - Generates appropriate share text

2. **ShareableResultCard** (`lib/widgets/shareable_result_card.dart`)
   - A specially designed widget optimized for sharing
   - Fixed width (1080px) for social media compatibility
   - Beautiful gradient background with theme colors
   - Highlights key points from the analysis
   - Includes app branding and watermark

3. **Results Screen Integration** (`lib/screens/results_screen.dart`)
   - Share button in the results screen
   - Modal dialog for share generation
   - User feedback during the share process

### Dependencies

The following packages are used:

```yaml
screenshot: ^3.0.0      # For capturing widget as image
share_plus: ^10.1.2     # For native sharing functionality
path_provider: ^2.1.5   # For temporary file storage
```

### User Flow

1. User completes an analysis and arrives at the results screen
2. User taps the "Share" button
3. A dialog appears showing "Generating shareable image..."
4. The app captures a screenshot of the `ShareableResultCard` widget
5. The image is saved to temporary storage
6. The native share sheet opens with the generated image
7. User selects their preferred sharing method (social media, messaging, etc.)

### Design Features

#### ShareableResultCard Design
- **Dimensions**: 1080px width (Instagram-friendly)
- **Background**: Gradient from black to a color based on "cooked" level
- **Header**: App branding (🔥 Am I Cooked?)
- **Circular Meter**: Large, prominent percentage display
- **Verdict**: Emoji + headline
- **Highlights Box**: 
  - Bordered container with theme color
  - Bullet points of key analysis highlights
  - Extracted from the explanation text
- **Watermark**: Bottom-aligned, subtle branding

#### Color Scheme
The share card adapts its colors based on the "cooked" percentage:
- 0-20%: Green (safe)
- 20-40%: Yellow (caution)
- 40-60%: Orange (warning)
- 60-80%: Deep Orange (danger)
- 80-100%: Red (cooked!)

### Technical Considerations

#### Screenshot Generation
- Uses `ScreenshotController` from the `screenshot` package
- Captures at 3x pixel ratio for high-quality images
- Widget is rendered off-screen (using `Offstage`) to avoid UI flash

#### File Management
- Images are saved to the temporary directory
- Filename includes timestamp to avoid conflicts
- Format: `am_i_cooked_result_[timestamp].png`

#### Platform Support
- **iOS**: Works out of the box
- **Android**: Works out of the box
- **Web/Desktop**: Supported by `share_plus` with fallbacks

### Future Enhancements

Potential improvements for the share feature:

1. **Customization Options**
   - Allow users to choose different templates
   - Add/remove specific highlights
   - Custom background colors or themes

2. **Additional Share Formats**
   - Story format (9:16 aspect ratio) for Instagram/Snapchat
   - Square format (1:1) for other social media
   - Landscape format for X/Twitter

3. **Share Analytics**
   - Track share counts
   - Popular sharing platforms

4. **Rich Metadata**
   - Open Graph tags for web sharing
   - Preview images for messaging apps

## Usage Example

```dart
// In results screen
final ShareService _shareService = ShareService();

void _shareVerdict() async {
  try {
    await _shareService.shareResult(context, widget.result);
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to share: $e')),
    );
  }
}
```

## Testing

To test the share feature:

1. Complete an analysis flow
2. Navigate to results screen
3. Tap the "Share" button
4. Verify the generated image looks correct
5. Confirm the native share sheet opens
6. Test sharing to various platforms (Messages, Social Media, etc.)

### Test Cases

- [ ] Share with high cooked percentage (>80%)
- [ ] Share with medium cooked percentage (40-60%)
- [ ] Share with low cooked percentage (<20%)
- [ ] Share with long explanations (text truncation)
- [ ] Share with short explanations
- [ ] Share on iOS
- [ ] Share on Android
- [ ] Verify watermark is visible
- [ ] Verify image quality is high

## Troubleshooting

### Common Issues

**Issue**: "Failed to capture screenshot"
- **Cause**: Widget not rendered yet
- **Solution**: Ensure widget is fully built before capture

**Issue**: Share sheet doesn't open
- **Cause**: Platform not supported or permissions issue
- **Solution**: Check platform compatibility and app permissions

**Issue**: Image quality is poor
- **Cause**: Low pixel ratio
- **Solution**: Increase `pixelRatio` in `capture()` call (currently 3.0)

**Issue**: Text is cut off in share image
- **Cause**: Long explanation text
- **Solution**: Text is automatically truncated to 2 sentences; adjust in `_extractHighlights()`

## Performance Considerations

- Screenshot capture takes ~500ms-1s
- Image file size: typically 200-500KB
- Memory usage: Minimal, cleaned up after share
- No impact on app performance when not in use

## Security & Privacy

- Images are stored in temporary directory
- Files are automatically cleaned by OS over time
- No server upload required
- User controls final sharing destination
- No analytics or tracking in the share flow


