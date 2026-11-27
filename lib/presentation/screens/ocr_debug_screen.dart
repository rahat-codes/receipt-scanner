import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers.dart';
import '../theme/aurora_background.dart';
import '../theme/glass_panel.dart';

/// TEMPORARY DAY 1 DEBUG SCREEN
/// WHY: Verify ML Kit OCR with Korean script recognizer on real device camera/gallery photos.
class OcrDebugScreen extends ConsumerStatefulWidget {
  const OcrDebugScreen({super.key});

  @override
  ConsumerState<OcrDebugScreen> createState() => _OcrDebugScreenState();
}

class _OcrDebugScreenState extends ConsumerState<OcrDebugScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  String _ocrResultText = 'Select an image to run OCR.';
  bool _isLoading = false;

  Future<void> _pickAndRunOcr(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _imagePath = image.path;
      _isLoading = true;
      _ocrResultText = 'Running ML Kit OCR (Korean script)...';
    });

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final result = await ocrService.read(image.path);
      setState(() {
        _ocrResultText = result.isEmpty ? 'No text recognized.' : result.fullText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ocrResultText = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('🧪 [TEMPORARY] OCR Debug'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Day 1 Debug Screen: Test ML Kit Korean OCR on real receipts.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickAndRunOcr(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickAndRunOcr(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_imagePath != null && File(_imagePath!).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(_imagePath!), height: 200, fit: BoxFit.cover),
                ),
                const SizedBox(height: 24),
              ],
              GlassPanel(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('OCR Result:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(height: 20),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        SelectableText(_ocrResultText, style: const TextStyle(fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
