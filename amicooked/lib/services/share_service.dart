import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cooked_result.dart';
import '../widgets/shareable_result_card.dart';

/// Service responsible for generating and sharing result images
class ShareService {
  /// Generates a shareable image from the result and shares it using RepaintBoundary
  Future<void> shareResult(BuildContext context, CookedResult result) async {
    try {
      // Create a GlobalKey for the RepaintBoundary
      final GlobalKey repaintKey = GlobalKey();
      
      // Build the widget we want to capture
      final widget = RepaintBoundary(
        key: repaintKey,
        child: ShareableResultCard(result: result),
      );
      
      // Create an overlay to render the widget off-screen
      final OverlayState overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;
      
      overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return Positioned(
            left: -100000,
            top: -100000,
            child: Material(
              color: Colors.transparent,
              child: widget,
            ),
          );
        },
      );
      
      // Insert the overlay
      overlay.insert(overlayEntry);
      
      // Wait for the widget to be built and rendered
      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;
      
      // Wait additional frames for CustomPaint to complete
      await Future.delayed(const Duration(milliseconds: 500));
      await WidgetsBinding.instance.endOfFrame;
      
      // Capture the image
      final RenderRepaintBoundary boundary = repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      // Remove the overlay
      overlayEntry.remove();
      
      if (byteData == null) {
        throw Exception('Failed to capture screenshot');
      }
      
      final Uint8List imageBytes = byteData.buffer.asUint8List();
      
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/am_i_cooked_result_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      // Prepare share text
      final shareText = _generateShareText(result);

      // Share the image with text
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: 'My Am I Cooked? Result',
      );
    } catch (e) {
      print('Error sharing result: $e');
      rethrow;
    }
  }

  /// Generates the text to accompany the shared image
  String _generateShareText(CookedResult result) {
    final emoji = _getEmoji(result.cookedPercent);
    return '$emoji I\'m ${result.cookedPercent}% cooked!\n\nCheck out the "Am I Cooked?" app to find out how cooked you are!';
  }

  String _getEmoji(int percentage) {
    if (percentage >= 90) return '💀';
    if (percentage >= 70) return '🔥';
    if (percentage >= 50) return '😰';
    if (percentage >= 30) return '😅';
    return '✅';
  }
}

