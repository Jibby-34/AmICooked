import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _hasInput = false;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _emberController;
  final List<Ember> _embers = [];
  
  // Typing animation
  String _typingText = '';
  int _currentExampleIndex = 0;
  int _currentCharIndex = 0;
  Timer? _typingTimer;
  bool _isDeleting = false;
  
  final List<String> _examples = [
    'My crush just confessed her love to me..',
    'I just cheated on my wife',
    'Sent my boss a text meant for my friend',
    'Told my ex I still have feelings',
    'Posted a drunk tweet at 3am',
    'My side hustle just got exposed',
    'Accidentally liked my ex\'s photo from 2019',
    'Forgot my anniversary... again',
    'Got caught lying about being sick',
    'My DMs just got leaked',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateInputState);
    
    // Set up glow animation for the button
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Set up ember animation
    _emberController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Initialize embers
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _embers.add(Ember(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.3,
        opacity: random.nextDouble() * 0.4 + 0.1,
        color: i % 3 == 0 
          ? AppTheme.flameRed 
          : i % 3 == 1 
            ? AppTheme.flameOrange 
            : AppTheme.flameYellow,
      ));
    }
    
    // Start typing animation
    _startTypingAnimation();
  }
  
  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Only animate if user hasn't typed anything
      if (_textController.text.isEmpty) {
        setState(() {
          final currentExample = _examples[_currentExampleIndex];
          
          if (!_isDeleting) {
            // Typing forward
            if (_currentCharIndex < currentExample.length) {
              _typingText = currentExample.substring(0, _currentCharIndex + 1);
              _currentCharIndex++;
            } else {
              // Pause at the end before deleting
              Future.delayed(const Duration(milliseconds: 2000), () {
                if (mounted) {
                  setState(() {
                    _isDeleting = true;
                  });
                }
              });
            }
          } else {
            // Deleting backward
            if (_currentCharIndex > 0) {
              _currentCharIndex--;
              _typingText = currentExample.substring(0, _currentCharIndex);
            } else {
              // Move to next example
              _isDeleting = false;
              _currentExampleIndex = (_currentExampleIndex + 1) % _examples.length;
            }
          }
        });
      } else {
        // User is typing, clear the animation text
        setState(() {
          _typingText = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.dispose();
    _glowController.dispose();
    _emberController.dispose();
    super.dispose();
  }

  void _updateInputState() {
    setState(() {
      _hasInput = _textController.text.isNotEmpty || _selectedImage != null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasInput = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.flameRed,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _updateInputState();
    });
  }

  void _analyze() {
    if (!_hasInput) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          text: _textController.text.isNotEmpty ? _textController.text : null,
          image: _selectedImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      AppTheme.flameOrange.withOpacity(0.05 * _glowAnimation.value),
                      AppTheme.flameRed.withOpacity(0.03 * _glowAnimation.value),
                      AppTheme.primaryBlack,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating embers
          AnimatedBuilder(
            animation: _emberController,
            builder: (context, child) {
              return CustomPaint(
                painter: EmberPainter(
                  embers: _embers,
                  animation: _emberController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppTheme.flameYellow,
                        AppTheme.flameOrange,
                        AppTheme.flameRed,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '🔥 Am I Cooked?',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle with subtle glow
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Text(
                        'Paste it. Screenshot it. Face the truth.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.7 + _glowAnimation.value * 0.3),
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Text Input with enhanced styling and typing animation
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _textController.text.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: AppTheme.flameOrange.withOpacity(_glowAnimation.value * 0.15),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _textController,
                              maxLines: 10,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: const InputDecoration(
                                hintText: '',
                                alignLabelWithHint: true,
                              ),
                            ),
                            // Custom typing animation overlay
                            if (_textController.text.isEmpty && _typingText.isNotEmpty)
                              Positioned(
                                left: 20,
                                top: 20,
                                right: 20,
                                child: IgnorePointer(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _typingText,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary.withOpacity(0.6),
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                        // Blinking cursor
                                        TextSpan(
                                          text: _isDeleting ? '' : '|',
                                          style: TextStyle(
                                            color: AppTheme.flameOrange.withOpacity(
                                              _glowAnimation.value,
                                            ),
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // OR Divider with gradient
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.flameOrange.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.flameOrange.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.flameOrange.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Image Upload Section
                  if (_selectedImage != null) ...[
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildImageUploadButton(),
                    const SizedBox(height: 16),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Main CTA Button
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _hasInput
                              ? [
                                  BoxShadow(
                                    color: AppTheme.flameOrange.withOpacity(_glowAnimation.value * 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: AppTheme.flameRed.withOpacity(_glowAnimation.value * 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: _hasInput ? _analyze : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasInput ? AppTheme.flameOrange : AppTheme.textSecondary,
                            minimumSize: const Size(double.infinity, 64),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🔥'),
                              const SizedBox(width: 8),
                              Text(
                                'Am I Cooked?',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: _hasInput ? AppTheme.primaryBlack : AppTheme.secondaryBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Hint text
                  if (!_hasInput)
                    Text(
                      'Add text or upload a screenshot to get started',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.flameOrange.withOpacity(0.05),
                AppTheme.flameRed.withOpacity(0.05),
              ],
            ),
          ),
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(
              Icons.upload_file, 
              size: 28,
              color: AppTheme.flameOrange.withOpacity(0.7 + _glowAnimation.value * 0.3),
            ),
            label: Text(
              'Upload Screenshot',
              style: TextStyle(
                color: AppTheme.textPrimary.withOpacity(0.8),
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 80),
              side: BorderSide(
                color: AppTheme.flameOrange.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.flameOrange, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.flameOrange.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.flameRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Ember particle class for floating animation
class Ember {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  Ember({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

// Custom painter for floating embers
class EmberPainter extends CustomPainter {
  final List<Ember> embers;
  final double animation;

  EmberPainter({
    required this.embers,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var ember in embers) {
      final paint = Paint()
        ..color = ember.color.withOpacity(ember.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      // Calculate position with vertical movement
      final yPos = ((ember.y + animation * ember.speed) % 1.0) * size.height;
      final xPos = ember.x * size.width + 
                   math.sin(animation * 2 * math.pi + ember.x * 10) * 20;

      // Draw ember as a small circle
      canvas.drawCircle(
        Offset(xPos, yPos),
        ember.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(EmberPainter oldDelegate) => true;
}

