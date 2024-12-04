import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform/web_model.dart' if (dart.library.io) 'platform/mobile_model.dart';

class ModelResult {
  final String label;
  final double confidence;
  final DateTime timestamp;

  ModelResult(this.label, this.confidence, this.timestamp);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlantRecognitionApp());
}

class PlantRecognitionApp extends StatelessWidget {
  const PlantRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bitki Tanıma',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PlantRecognitionScreen(),
    );
  }
}

class PlantRecognitionScreen extends StatefulWidget {
  const PlantRecognitionScreen({super.key});

  @override
  State<PlantRecognitionScreen> createState() => _PlantRecognitionScreenState();
}

class _PlantRecognitionScreenState extends State<PlantRecognitionScreen> {
  XFile? _image;
  Map<String, double>? _results;
  bool _isProcessing = false;
  final PlantModel _model = PlantModel();

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _model.initialize();
    } catch (e) {
      print('Error initializing model: $e');
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _results = null;
    });

    try {
      final results = await _model.processImage(_image!.path);
      setState(() {
        _results = results;
      });
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
          _results = null;
        });
        await _processImage();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = image;
          _results = null;
        });
        await _processImage();
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitki Tanıma'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_image != null) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(_image!.path),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (_isProcessing)
              const CircularProgressIndicator()
            else if (_results != null) ...[
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sonuçlar:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._results!.entries.map((entry) {
                        final confidence = (entry.value * 100).toStringAsFixed(1);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key.replaceAll('_', ' '),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Text(
                                '$confidence%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Fotoğraf Çek'),
              ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeriden Seç'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
