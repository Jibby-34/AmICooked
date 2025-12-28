import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _hasInput = false;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

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
  }

  @override
  void dispose() {
    _textController.dispose();
    _glowController.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Title
              Text(
                '🔥 Am I Cooked?',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Paste it. Screenshot it. Face the truth.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Text Input
              TextField(
                controller: _textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Paste the message, essay, email, code, or DM here...',
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFF333333))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFF333333))),
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
    );
  }

  Widget _buildImageUploadButton() {
    return OutlinedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.upload_file, size: 28),
      label: const Text('Upload Screenshot'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 80),
        side: BorderSide(
          color: AppTheme.textSecondary.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.flameOrange, width: 2),
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
  }
}

