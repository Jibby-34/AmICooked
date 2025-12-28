import 'package:flutter/material.dart';
import '../models/cooked_result.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

/// A beautiful card widget designed to be captured and shared
/// Shows the cooked percentage, verdict, and key highlights in an appealing format
class ShareableResultCard extends StatelessWidget {
  final CookedResult result;

  const ShareableResultCard({
    super.key,
    required this.result,
  });

  String _getEmoji(int percentage) {
    if (percentage >= 90) return '💀';
    if (percentage >= 70) return '🔥';
    if (percentage >= 50) return '😰';
    if (percentage >= 30) return '😅';
    return '✅';
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage < 20) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage < 40) {
      return const Color(0xFFFFEB3B); // Yellow
    } else if (percentage < 60) {
      return const Color(0xFFFF9800); // Orange
    } else if (percentage < 80) {
      return const Color(0xFFFF5722); // Deep Orange
    } else {
      return const Color(0xFFFF3B30); // Red
    }
  }

  Color _getBackgroundColor(int percentage) {
    if (percentage >= 70) {
      return AppTheme.flameRed.withValues(alpha: 0.15);
    } else if (percentage >= 50) {
      return AppTheme.flameOrange.withValues(alpha: 0.1);
    } else {
      return const Color(0xFF4CAF50).withValues(alpha: 0.1);
    }
  }

  List<String> _extractHighlights(String explanation) {
    // Extract key phrases (sentences) from the explanation
    final sentences = explanation.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).toList();
    
    // Return up to 3 sentences as highlights
    if (sentences.length <= 2) {
      return sentences.map((s) => s.trim()).toList();
    }
    
    // If there are more than 2 sentences, take the first 2
    return sentences.take(2).map((s) => s.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final highlights = _extractHighlights(result.explanation);
    final primaryColor = _getColorForPercentage(result.cookedPercent);
    
    return Container(
      width: 1080, // Instagram post size width
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlack,
            AppTheme.secondaryBlack,
            _getBackgroundColor(result.cookedPercent),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with app branding
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/icons/logo.png',
                  width: 48,
                  height: 48,
                ),
                SizedBox(width: 16),
                Text(
                  'Am I Cooked?',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 60),
            
            // Circular meter
            _buildCircularMeter(primaryColor),
            
            SizedBox(height: 48),
            
            // Verdict with emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getEmoji(result.cookedPercent),
                  style: TextStyle(fontSize: 56),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: Text(
                    result.verdict,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 40),
            
            // Highlights section
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlack.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primaryColor,
                  width: 3,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: primaryColor,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Key Highlights',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ...highlights.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.only(top: 8, right: 16),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 22,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            SizedBox(height: 60),
            
            // Watermark at the bottom
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlack.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppTheme.flameOrange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Made with "Am I Cooked?" app',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularMeter(Color color) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(300, 300),
            painter: _CircularMeterPainter(
              percentage: 1.0,
              color: AppTheme.secondaryBlack,
              strokeWidth: 28,
            ),
          ),
          
          // Progress circle
          CustomPaint(
            size: Size(300, 300),
            painter: _CircularMeterPainter(
              percentage: result.cookedPercent / 100,
              color: color,
              strokeWidth: 28,
            ),
          ),
          
          // Percentage text in center
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${result.cookedPercent}%',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'COOKED',
                style: TextStyle(
                  fontSize: 24,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularMeterPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;

  _CircularMeterPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw arc from top (-90 degrees) clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularMeterPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

