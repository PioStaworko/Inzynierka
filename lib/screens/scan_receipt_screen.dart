// lib/screens/scan_receipt_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/receipt_parser.dart';

import '../screens/verify_receipt_screen.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  File? _imageFile;
  String _scannedText = "";
  bool _isScanning = false;

  // Instancja OCR
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void dispose() {
    _textRecognizer.close(); // Ważne: zamykamy zasoby
    super.dispose();
  }

  // 1. Wybór i przycięcie zdjęcia
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      // Przycinanie (Crop)
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Przytnij paragon',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
          _scannedText = ""; // Resetujemy tekst
        });
        // Automatycznie uruchom skanowanie po wybraniu
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

  // 2. Przetwarzanie OCR
  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _scannedText = recognizedText.text;
      });
    } catch (e) {
      setState(() {
        _scannedText = "Błąd OCR: $e";
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanuj Paragon')),
      body: Column(
        children: [
          // Podgląd zdjęcia
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey[200],
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.contain)
                : const Center(
                    child: Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  ),
          ),
          
          // Przyciski sterowania
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
          
          // Wynik skanowania (na razie surowy tekst)
          Expanded(
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Wynik OCR (Surowe dane):",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_scannedText.isEmpty ? "Zrób zdjęcie, aby zobaczyć tekst" : _scannedText),
                        
                        if (_scannedText.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          // Przycisk "Dalej" dodamy w następnym kroku, jak napiszemy parser
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                if (_scannedText.isEmpty) return;
                                  // Debugowanie w konsoli
                                  print("--- SUROWY TEKST Z OCR ---");
                                  print(_scannedText);
                                  print("--------------------------");

                                  final items = ReceiptParser.parse(_scannedText); // items to teraz List<ParsedItem>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerifyReceiptScreen(parsedItems: items), // VerifyReceiptScreen oczekuje List<ParsedItem>
                                    ),
                                  );

                                  print("--- ZNALEZIONE PRODUKTY (${items.length}) ---");
                                  for (var item in items) {
                                    print("Produkt: '${item.name}' | Cena: ${item.amount}");
                                  }
                                  print("--------------------------");

                                  if (items.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Nie udało się odczytać produktów. Spróbuj poprawić kadrowanie.")),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerifyReceiptScreen(parsedItems: items),
                                    ),
                                  );
                              },
                              child: const Text("Przeanalizuj paragon"),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}