import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class CookedMeter extends StatefulWidget {
  final int percentage;
  final Duration animationDuration;

  const CookedMeter({
    super.key,
    required this.percentage,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<CookedMeter> createState() => _CookedMeterState();
}

class _CookedMeterState extends State<CookedMeter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 0.2) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage < 0.4) {
      return const Color(0xFFFFEB3B); // Yellow
    } else if (percentage < 0.6) {
      return const Color(0xFFFF9800); // Orange
    } else if (percentage < 0.8) {
      return const Color(0xFFFF5722); // Deep Orange
    } else {
      return const Color(0xFFFF3B30); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final percentage = _animation.value;
        final displayPercentage = (percentage * 100).toInt();
        
        return Column(
          children: [
            // Circular meter
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _CircularMeterPainter(
                      percentage: 1.0,
                      color: AppTheme.secondaryBlack,
                      strokeWidth: 20,
                    ),
                  ),
                  
                  // Animated progress circle
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _CircularMeterPainter(
                      percentage: percentage,
                      color: _getColorForPercentage(percentage),
                      strokeWidth: 20,
                    ),
                  ),
                  
                  // Percentage text in center
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$displayPercentage%',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: _getColorForPercentage(percentage),
                        ),
                      ),
                      Text(
                        'COOKED',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Linear gradient bar for additional visual
            Container(
              height: 12,
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: AppTheme.cookedMeterGradient,
              ),
              child: Stack(
                children: [
                  // Indicator at current percentage
                  Positioned(
                    left: percentage * 280 - 6,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: _getColorForPercentage(percentage),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

