// lib/screens/scan_receipt_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../utils/receipt_parser.dart';
import '../screens/verify_receipt_screen.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  File? _imageFile;
  RecognizedText? _rawOcrResult;
  String _debugText = ""; // Zmienna do przechowywania tekstu do wyświetlenia
  bool _isScanning = false;

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Przytnij paragon',
            toolbarColor: const Color.fromARGB(255, 1, 114, 44),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
          _rawOcrResult = null;
          _debugText = "";
        });
        _processImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd kamery: $e')),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // Preprocess image first (resize/grayscale/etc.) to improve OCR
      File imageToUse = _imageFile!;
      try {
        final pre = await _preprocessImage(_imageFile!);
        if (pre != null) imageToUse = pre;
      } catch (_) {
        // If preprocessing fails, fallback to original file
      }

      final inputImage = InputImage.fromFile(imageToUse);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _rawOcrResult = recognizedText;
        _debugText = recognizedText.text; // Do podglądu
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Błąd OCR: $e")));
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  // Simple preprocessing: decode, resize if large, convert to grayscale and
  // save to temporary file. Keep this conservative to avoid heavy CPU use.
  Future<File?> _preprocessImage(File input) async {
    try {
      final bytes = await input.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize if too large to reduce OCR time and memory
      const int maxDim = 1600;
      if (image.width > maxDim) {
        image = img.copyResize(image, width: maxDim);
      }

      // Convert to grayscale to reduce noise for OCR
      image = img.grayscale(image);

      // A gentle contrast adjustment can help; keep it small
      try {
        image = img.adjustColor(image, contrast: 1.08);
      } catch (_) {
        // ignore if adjustColor not available on older package versions
      }

      // Use explicit JpegEncoder for compatibility with different package versions
      final jpg = img.JpegEncoder(quality: 90).encode(image!);
      final tempDir = await getTemporaryDirectory();
      final outFile = File('${tempDir.path}/preprocessed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await outFile.writeAsBytes(jpg);
      return outFile;
    } catch (e) {
      return null;
    }
  }

  void _analyzeReceipt() {
    if (_rawOcrResult == null) return;

    final items = ReceiptParser.parse(_rawOcrResult!);

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie udało się odczytać produktów.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyReceiptScreen(parsedItems: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanuj Paragon')),
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[200],
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.contain)
                : const Center(
                    child: Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Aparat'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: _rawOcrResult != null
                      ? SingleChildScrollView( // Żeby się mieściło na małych ekranach
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                "Paragon zeskanowany pomyślnie!", 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 8),
                              
                              // === PODGLĄD TEKSTU ===
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Text(
                                  _debugText.split('\n').take(2).join('\n') + "...", // Pokaż tylko 2 linie
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ),
                              
                              TextButton.icon(
                                icon: const Icon(Icons.text_snippet_outlined),
                                label: const Text("Pokaż pełny tekst"),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Surowe dane OCR"),
                                      content: SingleChildScrollView(
                                        child: Text(_debugText),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("Zamknij"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // ======================

                              const SizedBox(height: 24),
                              SizedBox(
                                width: 200,
                                child: FilledButton(
                                  onPressed: _analyzeReceipt,
                                  child: const Text("Przeanalizuj"),
                                ),
                              )
                            ],
                          ),
                        )
                      : const Text("Zrób zdjęcie paragonu, aby rozpocząć"),
                  ),
          ),
        ],
      ),
    );
  }
}