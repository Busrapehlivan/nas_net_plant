import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const PlantRecognitionApp());
}

class PlantRecognitionApp extends StatelessWidget {
  const PlantRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitki Tanıma',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
  File? _image;
  final picker = ImagePicker();
  late Interpreter _interpreter;
  bool _isLoading = false;
  String _result = '';

  final List<String> _labels = [
    'Medicago_sativa (Yonca)',
    'Linum_tenuifolium (İnce Yapraklı Keten)',
    'Ophrys_mammosa (Arı Orkidesi)',
    'Orchis_pallens (Solgun Orkide)',
    'Vaccaria_hispanica (Çoban Çantası)',
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/plant_classifier.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: source);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _classifyImage();
        }
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Görüntüyü yükle ve yeniden boyutlandır
      Uint8List imageBytes = await _image!.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');
      
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      var normalizedImageBytes = Float32List(224 * 224 * 3);
      
      int pixelIndex = 0;
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          var pixel = resizedImage.getPixel(x, y);
          normalizedImageBytes[pixelIndex] = (pixel.r / 255.0);
          normalizedImageBytes[pixelIndex + 1] = (pixel.g / 255.0);
          normalizedImageBytes[pixelIndex + 2] = (pixel.b / 255.0);
          pixelIndex += 3;
        }
      }

      var input = [normalizedImageBytes];
      var output = List<double>.filled(5, 0).reshape([1, 5]);

      _interpreter.run(input, output);
      
      var outputList = output[0] as List<double>;
      int maxIndex = 0;
      double maxValue = outputList[0];
      
      for (int i = 1; i < outputList.length; i++) {
        if (outputList[i] > maxValue) {
          maxValue = outputList[i];
          maxIndex = i;
        }
      }

      setState(() {
        _result = _labels[maxIndex];
      });
    } catch (e) {
      setState(() {
        _result = 'Error classifying image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(_image!),
              ),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_result.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
