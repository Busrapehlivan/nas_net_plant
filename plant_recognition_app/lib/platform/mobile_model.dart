import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class PlantModel {
  static const int inputSize = 224;
  late Interpreter _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final interpreterOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'assets/plant_classifier_optimized.tflite',
        options: interpreterOptions,
      );
      _isInitialized = true;
      print('Model initialized successfully');
      print('Input shape: ${_interpreter.getInputShape()}');
      print('Output shape: ${_interpreter.getOutputShape()}');
    } catch (e) {
      print('Error initializing model: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> processImage(String imagePath) async {
    if (!_isInitialized) await initialize();

    // Load and preprocess the image
    final imageData = await _preprocessImage(File(imagePath));
    
    // Allocate tensors for quantized model
    final input = [imageData];
    final output = List.filled(1 * 5, 0).reshape([1, 5]); // 5 classes

    try {
      // Run inference
      _interpreter.run(input, output);
      
      // Process results
      final results = Map<String, double>();
      final labels = [
        'Linum_tenuifolium',
        'Medicago_sativa',
        'Ophrys_mammosa',
        'Orchis_pallens',
        'Vaccaria_hispanica'
      ];
      
      // Convert quantized output to probabilities using softmax
      final List<double> probabilities = _softmax(output[0].map((e) => e.toDouble()).toList());
      
      for (var i = 0; i < labels.length; i++) {
        results[labels[i]] = probabilities[i];
      }

      return results;
    } catch (e) {
      print('Error during inference: $e');
      rethrow;
    }
  }

  List<double> _softmax(List<double> inputs) {
    double max = inputs.reduce((a, b) => a > b ? a : b);
    List<double> exp = inputs.map((x) => (x - max).exp()).toList();
    double sum = exp.reduce((a, b) => a + b);
    return exp.map((x) => x / sum).toList();
  }

  Future<List<List<List<int>>>> _preprocessImage(File imageFile) async {
    // Read image
    final imageBytes = await imageFile.readAsBytes();
    var image = img.decodeImage(imageBytes);
    
    if (image == null) throw Exception('Failed to decode image');
    
    // Resize image to match model input size
    image = img.copyResize(image, width: inputSize, height: inputSize);
    
    // Convert to uint8 array and normalize to 0-255 range
    var imageArray = List.generate(
      inputSize,
      (y) => List.generate(
        inputSize,
        (x) => List.generate(3, (c) {
          final pixel = image!.getPixel(x, y);
          int value;
          switch (c) {
            case 0:
              value = img.getRed(pixel);
              break;
            case 1:
              value = img.getGreen(pixel);
              break;
            case 2:
              value = img.getBlue(pixel);
              break;
            default:
              value = 0;
          }
          // Normalize to 0-255 range for quantized model
          return value;
        }),
      ),
    );

    return imageArray;
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
