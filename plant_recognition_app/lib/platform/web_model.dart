import 'dart:async';
import 'dart:html' as html;
import 'package:js/js.dart';
import 'package:universal_html/html.dart' as uni_html;

@JS('tf')
external dynamic get tf;

@JS('mobilenet')
external dynamic get mobilenet;

class WebModel {
  static Future<List<dynamic>> classifyImage(html.File file) async {
    final completer = Completer<List<dynamic>>();
    
    try {
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      
      reader.onLoad.listen((event) async {
        final img = uni_html.ImageElement();
        img.src = reader.result as String;
        
        img.onLoad.listen((event) async {
          final model = await mobilenet.load();
          final predictions = await model.classify(img);
          completer.complete(predictions);
        });
      });
    } catch (e) {
      completer.completeError('Error classifying image: $e');
    }
    
    return completer.future;
  }
}
